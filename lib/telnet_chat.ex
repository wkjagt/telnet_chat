require Logger
require IEx

defmodule TelnetChat do
  use Application

  def start(_type, _args) do
    ip = Application.get_env :telnet_chat, :ip, {127,0,0,1}
    port = Application.get_env :telnet_chat, :port, 4040
    pool_size = Application.get_env :telnet_chat, :port, 1000

    TelnetChat.Supervisor.start_link([ip, port, pool_size])
  end
end