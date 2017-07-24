defmodule Elixter.Cache do
  use GenServer

  def start_link(domain) do
    GenServer.start_link(__MODULE__, domain, name: CacheServer)
  end 

  def init(domain) do
    subdomains =
      case domain do
        "www" <> _rest ->
          MapSet.new
        _ ->        
          MapSet.new(["www." <> domain])
      end
    {:ok, subdomains}
    GenServer.start_link(__MODULE__, MapSet.new([domain]), name: CacheServer)
  end 

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:merge, set}, state) do
    {:noreply, MapSet.union(set, state)}
  end
end