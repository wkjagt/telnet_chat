defmodule TelnetChat.Application do
  use Application

  def start(_type, _args) do
    children = [
      {TelnetChat.ClientRegistry, name: TelnetChat.ClientRegistry},
      {Task.Supervisor, name: TelnetChat.TaskSupervisor}, # the accepted clients tasks
      Supervisor.child_spec({Task, fn -> TelnetChat.accept(4000) end}, restart: :permanent) # the main server task
    ]

    opts = [strategy: :one_for_one, name: TelnetChat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
