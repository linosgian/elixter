defmodule PortScanner do
    def scan_ports(ip, ports) do
        ports 
        |> Enum.each(fn port -> spawn_link(PortScanner, :scan_port, [ip, port, self()]) end)
        receive_messages(length(ports))
    end
    defp receive_messages(ports_left) do
        case ports_left do
            0 -> 
                nil
            _ ->
                receive do
                    {:open, port} -> 
                        IO.puts "open " <> Integer.to_string(port)
                        receive_messages(ports_left-1)
                    {:closed, port} ->
                        IO.puts "closed " <> Integer.to_string(port)
                        receive_messages(ports_left-1)
                end
        end
        
    end
    def scan_port(ip, port, caller) do
        case :gen_tcp.connect(String.to_char_list(ip), port, [], 2000) do
            {:error, _} ->
                send(caller, {:closed, port})
            {:ok, conn} ->
                :gen_tcp.close(conn)
                send(caller, {:open, port})
        end
    end
end