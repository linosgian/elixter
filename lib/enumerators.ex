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
        |> IO.inspect 
    end
  end
end