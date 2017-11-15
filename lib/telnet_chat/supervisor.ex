defmodule TelnetChat.Supervisor do
  use Supervisor

  def start_link(server_config) do
    Supervisor.start_link(__MODULE__, server_config, name: __MODULE__)
  end

  def init(server_config = [_, _, _]) do
    children = [
      supervisor(TelnetChat.ClientRegistry, [[name: :client_registry]]),
      supervisor(Task.Supervisor, [[name: TelnetChat.ClientsSupervisor]]),
      supervisor(TelnetChat.ServerSupervisor, server_config)
    ]

    opts = [strategy: :one_for_all]

    supervise(children, opts)
  end
end