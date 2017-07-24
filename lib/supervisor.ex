defmodule Elixter.MainSupervisor do
  use Supervisor

  @engines Application.get_env(:elixter, :engines)

  def start_link(domain) do
    Supervisor.start_link(__MODULE__, domain)
  end 


  def init(domain) do
    engine_workers = 
     @engines
     |> Enum.map(&(worker(&1, [domain], restart: :transient)))
    children = [worker(Elixter.Cache, [domain]) | engine_workers]
    
    supervise(children, strategy: :one_for_one)
  end
end