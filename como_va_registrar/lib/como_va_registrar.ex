defmodule ComoVaRegistrar.Worker do
    use GenServer

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

    def handle_info({:master, val}, state) do
        masternode = String.to_atom("comova@"<>val)
        IO.puts "El nodo maestro es #{inspect masternode}"
        #ret = Node.ping(masternode)
        #IO.inspect ret
        case Node.ping(masternode) do
            :pong   ->  IO.inspect Node.list
            :pang   -> :ignore
        end
        {:noreply, {}}
    end

    def handle_info(_, state) do
        {:noreply, state}
    end

    
    def send_msg_local(nodo) do
        IO.puts "Hablo con #{nodo}"
        :global.sync
        p = :global.whereis_name(:main)
        send p, {:master_quien, self}
    end

    def schedule_work do
        Process.send_after(self(), :work, 1000)
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

