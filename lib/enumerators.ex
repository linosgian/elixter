defmodule GoogleEnum do
  def run(domain) do
    headers = [
      {"User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"},
      {"Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"},
      {"Accept-Language", "en-US,en;q=0.8"},
    ]
    query = "site:" <> domain <> "%20-www." <> domain
    request = "https://www.google.com/search?q=" <> query <> "&btnG=Search&hl=en-US&biw=&bih=&gbv=1&start=0&filter=0"
    resp = HTTPoison.get(request, headers, [follow_redirect: true])
    case resp do
      {:ok, %HTTPoison.Response{status_code: 200,body: body}} ->
        body
        |> Floki.find("cite")
        |> Enum.map(&elem(&1, 2))
        |> Enum.map(&to_string/1)
        |> Enum.map(parse)
        |> IO.inspect 
    end
  end

  defp parse(unparsed_url) do
    url = URI.parse(unparsed_url)
    case url do
      %URI{scheme: nil, host: nil} ->
        url
        |> String.split("/")
        |> List.first
    end
  end
end