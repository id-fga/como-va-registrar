defmodule ComoVaRegistrar.Worker do
    use GenServer

    defmodule Config do
        defstruct register_name: "huayra-compartir"
    end

    def start_link do
        GenServer.start_link(__MODULE__, 0, name: :server_prueba)
    end

    def init(inicio) do
        :net_kernel.start([nodename, :longnames])
        :erlang.set_cookie(node, :"de-chocolate")
        
        schedule_work()
        {:ok, {}}
    end

    def handle_info(:work, state) do
        IO.puts "------------------------------"
        IO.puts "Loopeando, loopeando"

        local = String.to_atom("comova@"<>get_ip)
        case Node.ping(local) do
            :pong   ->  send_msg_local(local)
            _       -> :ignore
        end

        schedule_work()
        {:noreply, {}}
    end

    def handle_info({:master, master_ip}, state) do
        IO.puts "El nodo maestro esta en #{inspect master_ip}"
        masternode = String.to_atom("comova@"<>master_ip)

        global_process = String.to_atom("main-"<>master_ip)
        p = :global.whereis_name(global_process)

        case Node.ping(masternode) do
            :pong   ->  IO.puts "Le pido la lista a #{inspect master_ip}"
                        send p, {:traer_lista, %Config{}.register_name, self}
            :pang   -> :ignore
        end

        {:noreply, {}}
    end

    def handle_info({:lista, lista}, state) do
        IO.puts "Me llega la lista #{inspect lista}"
        {:noreply, {}}
    end

    def handle_info(_, state) do
        {:noreply, state}
    end

    
    def send_msg_local(nodo) do
        IO.puts "Hablo con #{nodo}"
        :global.sync

        global_process = String.to_atom("main-"<>get_ip)
        p = :global.whereis_name(global_process)
        send p, {:master_quien, self}
    end

    def schedule_work do
        Process.send_after(self(), :work, 1000)
    end


    def nodename do
        #String.to_atom "como-va-registrar@"<>get_ip
        rn = %Config{}.register_name
        String.to_atom rn<>"@"<>get_ip
    end

    def get_ip do
        {:ok, val} = :inet.getif() 
        elem(hd(val), 0)
        |> Tuple.to_list
        |> Enum.join(".")
    end

end

defmodule ComoVaRegistrar do
  use Application

    def main(argv) do
        :timer.sleep(:infinity)
    end

    # See http://elixir-lang.org/docs/stable/elixir/Application.html
    # for more information on OTP Applications
    def start(_type, _args) do
        import Supervisor.Spec, warn: false

        children = [
        # Define workers and child supervisors to be supervised
            worker(ComoVaRegistrar.Worker, []),
        ]

        # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
        # for other strategies and supported options

        opts = [strategy: :one_for_one, name: ComoVaRegistrar.Supervisor]
        Supervisor.start_link(children, opts)
    end

end

