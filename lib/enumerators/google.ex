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
    Process.send_after(self(), {domain, 0}, 0)
    {:ok, domain}
  end
  
  def handle_info({domain, findings_num}, state) do
    subdomains = GenServer.call(CacheServer, :get_state)
    args = {domain, subdomains, findings_num}
    query_task = Task.Supervisor.async_nolink(QueryTask, __MODULE__, :query, [args])
    
    case Task.yield(query_task, 10000) do
      {:ok, {:ok, recv_subdoms}} ->
        IO.puts :here
        # If we found 0 new subdomains, move on to the next page
        if MapSet.subset?(recv_subdoms, subdomains) do
          schedule_work({domain, findings_num + 10})
        else
          GenServer.cast(CacheServer, {:merge, recv_subdoms})
          schedule_work({domain, 0})
        end
      {:ok, :done} ->
        IO.puts "Google Search is done..."
      {:ok, :blocked} ->
        Helpers.error ~S("Google has blocked the "site:" searches, try again later")
      {:ok, {:error, reason}} ->
        IO.inspect reason
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
    if findings_num >= 10 do
     :done # If we reached the 9th page, return.
    else
      IO.puts findings_num
      request = build_query(domain, subdomains, findings_num)
      options = [follow_redirect: true, recv_timeout: @timeout]
      response = HTTPoison.get(request, @headers, options)

      parse_response(response)
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
          :done 
        else
          new_subdomains =
            body
            |> Floki.find("cite")
            |> Enum.map(&elem(&1, 2))
            |> Enum.map(&to_string/1)
            |> Enum.map(&parse_url/1)
            |> Enum.uniq
            |> MapSet.new
          {:ok, new_subdomains}
        end
      {:ok, %HTTPoison.Response{body: body}} ->
        IO.puts body  
        :blocked
      {:error, reason} ->
        {:error, reason}
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