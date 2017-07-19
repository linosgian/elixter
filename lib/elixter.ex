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
  def hello do
    PortScanner.scan_ports("83.212.100.68", [80, 443, 8000, 22, 1000, 33])
  end
end
