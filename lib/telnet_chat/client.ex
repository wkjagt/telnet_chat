defmodule TelnetChat.Client do
  defstruct [:socket, :pid, name: "?"]

  def receive(client, "/iam " <> name) do
    %{client | name: String.trim(name)}
  end

  def receive(client, line) do
    TelnetChat.ClientRegistry.broadcast(client, line)
    client
  end

  def write(client, sender, line) do
    :gen_tcp.send(client.socket, sender.name <> ": " <> line)
    client
  end
end