defmodule ComoVaRegistrar do
    def start do
        :net_kernel.start([nodename, :longnames])
        :erlang.set_cookie(node, :"de-chocolate")
        case Node.ping(String.to_atom("comova@"<>get_ip)) do
            :pang   ->  IO.puts "comova@"<>get_ip<>" no responde"
                        Process.exit(self, :kill)
            _       -> :seguir
        end
        :global.sync
        p = :global.whereis_name(:main)
        recibir p
    end

    def recibir(p) do
        send p, {:master_quien, self}
        receive do
            {:master, master_ip}    ->  IO.puts "Master es " <> master_ip
                                        Node.ping(String.to_atom("como-va-registrar@"<>master_ip))
                                        IO.inspect Node.list
                                        :timer.sleep 2000
            after 1000 ->
                IO.puts "No llego nada"
        end
        p = :global.whereis_name(:main)
        recibir p
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

ComoVaRegistrar.start
