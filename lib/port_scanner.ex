defmodule PortScanner do
  def scan_ports(ip, ports) do
    ports 
    |> Enum.map(&Task.async(PortScanner, :scan_port, [ip, &1]))
    |> Enum.map(&Task.await/1)
    |> Enum.filter(&is_integer/1)
  end
    
  def scan_port(ip, port) do
    case :gen_tcp.connect(String.to_char_list(ip), port, [], 2000) do
      {:error, _} ->
        nil
      {:ok, conn} ->
        :gen_tcp.close(conn)
        port
    end
  end
end 