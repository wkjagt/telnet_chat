defmodule ClientRegistry do
  use GenServer

  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add_client(client_pid, client_socket) do
    GenServer.cast(:client_registry, {:add_client, client_pid, client_socket})
  end

  def broadcast(line) do
    GenServer.cast(:client_registry, {:broadcast, line, self()})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:broadcast, line, exclude_pid}, clients) do
    Enum.each clients, fn {pid, client_socket} ->
      unless exclude_pid == pid do
        :gen_tcp.send(client_socket, line)
      end
    end
    {:noreply, clients}
  end

  def handle_cast({:add_client, client_pid, client_socket}, clients) do
    {:noreply, Map.put(clients, client_pid, client_socket)}
  end
end