defmodule Elixter do
  # require PortScanner
  @moduledoc """
  Documentation for Elixter.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Elixter.hello
      :world

  """
  def main(args) do
    IO.puts "hello world"
    parse_args(args)
  end
  defp parse_args(args) do
    {opts, _, _} = OptionParser.parse(args,
        switches: [foo: :string]
      )
    IO.inspect opts
  end

  def hello do
    PortScanner.scan_ports("83.212.100.68", [80, 443, 8000, 22, 1000, 33])
  end
end
