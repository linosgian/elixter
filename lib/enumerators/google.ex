defmodule Elixter.Enumerator.GoogleEnum do
  @headers Application.get_env(:elixter, :headers)
  @timeout Application.get_env(:elixter, :timeout)
  
  alias Elixter.Helpers
  
  def enumerate(domain) do
    subdomains =
      case domain do
        "www" <> _rest ->
          MapSet.new 
        _ ->        
          MapSet.new(["www." <> domain])
      end
    query(domain, subdomains, 0)
  end
  
  defp query(domain, subdomains, findings_num) do
    if findings_num >= 100, do: subdomains # If we reached the 10th page, return.

    request = build_query(domain, subdomains, findings_num)
    response = HTTPoison.get(request, @headers, [follow_redirect: true, recv_timeout: @timeout])

    case parse_response(response) do
      {:ok, recv_subdoms} ->
        # If we found 0 new subdomains, move on to the next page
        if MapSet.subset?(recv_subdoms, subdomains) do
          :timer.sleep(2000)
          IO.inspect(subdomains)
          query(domain, subdomains, findings_num + 10)
        else
          updated_subdoms = MapSet.union(subdomains, recv_subdoms)
          IO.inspect(updated_subdoms)
          :timer.sleep(2000)
          query(domain, updated_subdoms, findings_num)              
        end
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