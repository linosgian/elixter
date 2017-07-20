defmodule Elixter do
  # require PortScanner
  @moduledoc """
  Documentation for Elixter.
  """  
  def main(args) do
    domain = parse_args(args)
    GoogleEnum.run(domain)
  end
  
  defp parse_args(args) do 
    {opts, _, _} = OptionParser.parse(
      args,
      switches: [
        domain: :string,
      ],
      aliases: [
        d: :domain,
      ]
    )
    opts = Enum.into(opts, %{})

    case opts do
        %{domain: domain} ->
          case :inet.gethostbyname(String.to_char_list(domain)) do
            {:error, reason} ->
              Helpers.error("Domain name cannot be resolved with error: " <> to_string(reason))
            {:ok, _results} ->
              domain
          end
        _ ->
          Helpers.error("Please enter domain")
          System.halt(0)
    end
  end
end
