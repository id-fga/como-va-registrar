defmodule ComoVaRegistrar do
    use GenServer

    def start_link do
        GenServer.start_link(__MODULE__, 0, name: __MODULE__)
    end

    def init(inicio) do
        IO.puts "El inicio"
        :net_kernel.start([nodename, :longnames])
        :erlang.set_cookie(node, :"de-chocolate")
        case Node.ping(String.to_atom("comova@"<>get_ip)) do
            :pang   ->  IO.puts "comova@"<>get_ip<>" no responde"
                        Process.exit(self, :kill)
            _       -> :seguir
        end
        :global.sync
        p = :global.whereis_name(:main)
        {:ok, p}
    end

    def prueba do
        GenServer.call(__MODULE__, :prueba)
    end

    def handle_call(:prueba, _from, state) do
        IO.inspect state
        {:reply, state, state}
    end

    def nodename do
        String.to_atom "como-va-registrar@"<>get_ip
    end

    def get_ip do
        {:ok, val} = :inet.getif() 
        elem(hd(val), 0)
        |> Tuple.to_list
        |> Enum.join(".")
    end

end
