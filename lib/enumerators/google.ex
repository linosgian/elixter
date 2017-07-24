defmodule Elixter.Enumerator.Google do
  @headers Application.get_env(:elixter, :headers)
  @timeout Application.get_env(:elixter, :timeout)
  
  alias Elixter.Helpers

  ##############################################################################
  ########################## GenServer Callbacks ###############################
  ##############################################################################
  
  def start_link(domain) do
    GenServer.start_link(__MODULE__, domain)
  end

  def init(domain) do
    Task.Supervisor.start_link(name: QueryTask)
    subdomains =
      case domain do
        "www" <> _rest ->
          MapSet.new 
        _ ->        
          MapSet.new(["www." <> domain])
      end
    Process.send_after(self(), {domain, subdomains, 0}, 0)
    {:ok, domain}
  end
  
  def handle_info({domain, subdomains, findings_num}, state) do
    args = {domain, subdomains, findings_num}
    task = Task.Supervisor.async_nolink(QueryTask, __MODULE__, :query, [args])
    
    case Task.yield(task, 10000) do
      {:ok, {:ok, recv_subdoms}} ->
        IO.inspect recv_subdoms
        # If we found 0 new subdomains, move on to the next page
        if MapSet.subset?(recv_subdoms, subdomains) do
          schedule_work({domain, subdomains, findings_num + 10})
        else
          updated_subdoms = MapSet.union(subdomains, recv_subdoms)
          schedule_work({domain, updated_subdoms, findings_num})
        end
      {:exit, reason} ->
        IO.inspect reason
    end
    {:noreply, state}
  end

  def terminate(reason, _state) do
    IO.inspect reason
    :normal
  end
  
  ##############################################################################
  ########################## Private Module Functions ##########################
  ##############################################################################
  
  defp schedule_work(state) do
    Process.send_after(self(), state, 5000)
  end
  
  def query({domain, subdomains, findings_num}) do
    if findings_num >= 100, do: subdomains # If we reached the 10th page, return.

    request = build_query(domain, subdomains, findings_num)
    options = [follow_redirect: true, recv_timeout: @timeout]
    response = HTTPoison.get(request, @headers, options)

    case parse_response(response) do
      {:ok, recv_subdoms} ->
        {:ok, recv_subdoms}
      :blocked ->
        Helpers.error ~S("Google has blocked the "site:" searches, try again later")
        {:blocked, subdomains}
      :empty ->
        IO.puts "Google Search is done..."
        {:done, subdomains}
    end
  end

  defp build_query(domain, subdomains, findings_num) do
    subdomains_query = 
    subdomains 
    |> MapSet.to_list
    |> Enum.map(&("-" <> &1)) # prepend "-" to each subdomain
    |> Enum.join("%20")       # add a url encoded space between subdomains
    query_str = "site:" <> domain <> "%20" <> subdomains_query
    
    "https://www.google.com/search?q=" <> query_str <>
    "&btnG=Search&hl=en-US&biw=&bih=&gbv=1&start=" <> to_string(findings_num)    
  end

  defp parse_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        if body =~ "did not match any documents" do
          :empty 
        else
          new_subdoms =
            body
            |> Floki.find("cite")
            |> Enum.map(&elem(&1, 2))
            |> Enum.map(&to_string/1)
            |> Enum.map(&parse_url/1)
            |> Enum.uniq
            |> MapSet.new
          {:ok, new_subdoms}
        end
      {:ok, %HTTPoison.Response{body: body}} ->
        IO.inspect body
        :blocked  
      {:error, reason} ->
        IO.inspect reason
    end
  end

  defp parse_url(unparsed_url) do
    case URI.parse(unparsed_url) do
      %URI{scheme: nil, host: nil, path: path} ->
        path
        |> String.split("/")
        |> List.first
      %URI{host: host} ->
        host
    end
  end
end