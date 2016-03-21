defmodule ComoVaRegistrar do
    def start do
        :net_kernel.start([nodename, :longnames])
        case Node.ping(String.to_atom("comova@"<>get_ip)) do
            :pang   ->  IO.puts "comova@"<>get_ip<>" no responde"
                        Process.exit(self, :kill)
            _       -> :seguir
        end
        :global.sync
        p = :global.whereis_name(:main)
        send p, {:master_quien, self}
        recibir
    end

    def recibir do
        receive do
            {:master, master_ip}    -> IO.puts "Master es " <> master_ip
            after 1000 ->
                IO.puts "No llego nada"
        end
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
