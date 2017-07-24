defmodule Elixter do
  @moduledoc """
    Documentation for Elixter.
  """
  alias Elixter.Helpers
  alias Elixter.MainSupervisor

  def main(args) do
    domain = parse_args(args)
    MainSupervisor.start_link(domain) 
    poke_cache()
  end
  
  # Temp function to test pipeline
  defp poke_cache() do
    IO.inspect GenServer.call(CacheServer, :get_state)
    :timer.sleep(3000)
    poke_cache()
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
              Helpers.error("Domain name cannot be resolved with error: "
                            <> to_string(reason))
            {:ok, _results} ->
              domain
          end
        _ ->
          Helpers.error("Please enter domain")
          System.halt(0)
    end
  end
end
