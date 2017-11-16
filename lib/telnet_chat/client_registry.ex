require IEx

defmodule TelnetChat.ClientRegistry do
  use GenServer

  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def register_client(client) do
    GenServer.cast(:client_registry, {:register_client, client})
  end

  def unregister_client(client) do
    GenServer.cast(:client_registry, {:unregister_client, client})
  end

  def broadcast(line) do
    GenServer.cast(:client_registry, {:broadcast, line, self()})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, MapSet.new}
  end

  def handle_cast({:broadcast, line, exclude_pid}, client_pids) do
    Enum.each client_pids, fn client_pid ->
      unless exclude_pid == client_pid do
        send(client_pid, {:write, line})
      end
    end
    {:noreply, client_pids}
  end

  def handle_cast({:register_client, client}, client_pids) do
    send(client.pid, {:write, "Welcome \n"})
    {:noreply, MapSet.put(client_pids, client.pid)}
  end

  def handle_cast({:unregister_client, client}, client_pids) do
    {:noreply, MapSet.delete(client_pids, client.pid)}
  end
end