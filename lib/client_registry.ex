defmodule TelnetChat.ClientRegistry do
  use GenServer

  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add_client(server, client_pid, client_socket) do
    GenServer.cast(server, {:add_client, client_pid, client_socket})
  end

  def for_all_clients(server, callback) do
    GenServer.cast(server, {:do, callback})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:do, callback}, clients) do
    Enum.each clients, fn {_pid, client_socket} -> callback.(client_socket) end
    {:noreply, clients}
  end

  def handle_cast({:add_client, client_pid, client_socket}, clients) do
    if Map.has_key?(clients, client_pid) do
      {:noreply, clients}
    else
      {:noreply, Map.put(clients, client_pid, client_socket)}
    end
  end
end