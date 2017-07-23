defmodule Elixter.Helpers do
  @moduledoc """
    Provides a bunch of helper functions 
    for other modules
  """
  def error(message) do
    IO.puts IO.ANSI.red <> message <> IO.ANSI.reset
  end
end
