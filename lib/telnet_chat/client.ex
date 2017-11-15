defmodule TelnetChat.Client do
  def receive({socket, packet}) do
    IO.inspect packet, label: "Packet received"
    :gen_tcp.send socket, "Command received \n"
  end
end