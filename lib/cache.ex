defmodule Elixter.Cache do
  use GenServer

  # Interface
  
  def update_state(set) do
    GenServer.cast(__MODULE__, {:merge, set})
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  # GenServer Callbacks

  def start_link(domain) do
    GenServer.start_link(__MODULE__, domain, name: __MODULE__)
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
  end 

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:merge, set}, state) do
    {:noreply, MapSet.union(set, state)}
  end
end