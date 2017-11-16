require IEx

defmodule TelnetChat.ClientConnection do
  use GenServer

  def start_link(listen_socket) do
    GenServer.start_link(__MODULE__, [listen_socket])
  end

  def init([listen_socket]) do
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    TelnetChat.ClientRegistry.register_client(self())

    {:ok, %{client_socket: client_socket}}
  end

  def handle_info({:tcp, _, line}, client_info) do
    TelnetChat.ClientRegistry.broadcast(line)
    {:noreply, client_info}
  end

  def handle_info({:write, line}, client_info) do
    :gen_tcp.send(client_info[:client_socket], line)
    {:noreply, client_info}
  end

  def handle_info({:tcp_closed, _}, client_info) do
    IO.inspect "Socket has been closed"
    {:noreply, client_info}
  end

  def handle_info({:tcp_error, _, reason}, client_info) do
    IO.inspect reason
    {:noreply, client_info}
  end
end