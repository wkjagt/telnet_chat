defmodule TelnetChat.Client do
  defstruct [:socket, :pid, :name]

  def receive(client, "/iam " <> name) do
    trimmed_name = String.trim(name)
    TelnetChat.ClientRegistry.broadcast(client, trimmed_name <> " has identified themselves\n")
    %{client | name: trimmed_name}
  end

  def receive(client, line) do
    TelnetChat.ClientRegistry.broadcast(client, line)
    client
  end

  def write(client, %TelnetChat.Client{name: nil}, line) do
    write(client, line)
  end

  def write(client, sender, line) do
    write(client, sender.name <> ": " <> line)
  end

  def write(client, line) do
    :gen_tcp.send(client.socket, line)
    client
  end
end