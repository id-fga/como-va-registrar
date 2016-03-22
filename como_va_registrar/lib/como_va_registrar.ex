defmodule ComoVaRegistrar.Worker do
    use GenServer

    def start_link do
        :net_kernel.start([nodename, :longnames])
        :erlang.set_cookie(node, :"de-chocolate")
        GenServer.start_link(__MODULE__, 0, name: :server_prueba)
    end

    def init(inicio) do
        
        master_node = String.to_atom("comova@"<>get_ip)

        case Node.ping(master_node) do
          :pong   ->  {:ok, master_node}
          :pang   ->  {:ok, master_node, 1000}
        end
    end

    def handle_info(:timeout, state) do
      IO.puts "TIMEOUT: Reintento a #{inspect state}"
      case Node.ping(state) do
        :pong   ->  {:noreply, state}
        :pang   ->  {:noreply, state, 1000}
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

defmodule ComoVaRegistrar do
  use Application

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
