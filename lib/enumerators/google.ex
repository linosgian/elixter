defmodule GoogleEnum do
  def enumerate(domain) do
    headers = Application.get_env(:elixter, :headers)
    timeout = Application.get_env(:elixter, :timeout)
    query(domain, headers, timeout, 3, MapSet.new, 0)
  end
  
  defp query(domain, headers, timeout, retries, subdomains, page_num) do

    if page_num >= 30 or retries == 0, do: subdomains
    query = "site:" <> domain <> "%20-www." <> domain
    request = "https://www.google.com/search?q=" <> query <>
              "&btnG=Search&hl=en-US&biw=&bih=&gbv=1&start=" <> to_string(page_num)
    IO.puts request
    IO.puts page_num
    IO.puts retries
    response = HTTPoison.get(request, headers, [follow_redirect: true, recv_timeout: timeout])

    case parse_response(response) do
      {:ok, new_subdoms} ->
        IO.inspect new_subdoms
        updated_subdoms = MapSet.union(subdomains, new_subdoms)
        :timer.sleep(1000)
        query(domain, headers, timeout, 3, updated_subdoms, page_num + 10)      
      :blocked ->
        subdomains
      :empty ->
        :timer.sleep(1000)
        query(domain, headers, timeout, retries-1, subdomains, page_num)
    end
  end
  
  defp parse_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        if (body =~ "did not match any documents") do
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
        IO.puts body
        :blocked  
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