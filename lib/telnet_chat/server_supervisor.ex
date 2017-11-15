defmodule TelnetChat.ServerSupervisor do
  use Supervisor

  def start_link(ip, port, pool_size) do
    Supervisor.start_link(__MODULE__, [ip, port, pool_size], [name: __MODULE__])
  end

  def init([ip, port, pool_size]) do
    IO.puts "---------------------------------"
    IO.puts "Telnet Server started"
    IO.puts "Port: " <> Integer.to_string(port)
    IO.puts "Pool size: " <> Integer.to_string(pool_size)
    IO.puts "---------------------------------"

    tcp_config = [:binary, packet: :line, active: true, ip: ip, reuseaddr: true]
    {:ok, listen_socket} = :gen_tcp.listen(port, tcp_config)

    opts = [
      strategy: :one_for_one,
      max_restarts: 5,
      max_seconds: 5
    ]

    children = Enum.map 1..pool_size, fn counter ->
      worker(TelnetChat.Acceptor, [listen_socket], [id: counter])
    end

    supervise(children, opts)
  end
end