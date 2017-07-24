defmodule Elixter.Cache do
  use GenServer

  def start_link(domain) do
    GenServer.start_link(__MODULE__, MapSet.new([domain]), name: CacheServer)
  end 

  def init(state) do
    {:ok, state}
  end 


  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end