require IEx

defmodule TelnetChat.ClientConnection do
  use GenServer

  def start_link(listen_socket) do
    GenServer.start_link(__MODULE__, [listen_socket])
  end

  def init([listen_socket]) do
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    client = %TelnetChat.Client{
      pid: self(),
      socket: client_socket
    }
    TelnetChat.ClientRegistry.register_client(client)

    {:ok, client}
  end

  def handle_info({:tcp, _, line}, client) do
    TelnetChat.ClientRegistry.broadcast(line)
    {:noreply, client}
  end

  def handle_info({:write, line}, client) do
    :gen_tcp.send(client.socket, line)
    {:noreply, client}
  end

  def handle_info({:tcp_closed, _}, client) do

    {:noreply, client}
  end

  def handle_info({:tcp_error, _, reason}, client) do
    IO.inspect reason
    {:noreply, client}
  end
end