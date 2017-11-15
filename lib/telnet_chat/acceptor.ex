defmodule TelnetChat.Acceptor do
  use GenServer

  def start_link(listen_socket) do
    GenServer.start_link(__MODULE__, [listen_socket])
  end

  def init([listen_socket]) do
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    TelnetChat.ClientRegistry.register_client(self(), client_socket)

    {:ok, %{client_socket: client_socket}}
  end

  def handle_info({:tcp, client_socket, packet}, state) do
    TelnetChat.ClientRegistry.broadcast(packet)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _client_socket}, state) do
    IO.inspect "Socket has been closed"
    {:noreply, state}
  end

  def handle_info({:tcp_error, client_socket, reason}, state) do
    IO.inspect client_socket, label: "connection closed dut to #{reason}"
    {:noreply, state}
  end
end