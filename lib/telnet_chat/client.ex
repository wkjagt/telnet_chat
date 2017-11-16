defmodule TelnetChat.Client do
  defstruct [:socket, :pid]

  def write(client, line) do
    :gen_tcp.send(client.socket, line)
  end
end