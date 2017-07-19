defmodule Helpers do
  def error(message) do
    IO.puts IO.ANSI.red <> message <> IO.ANSI.reset
  end
end

