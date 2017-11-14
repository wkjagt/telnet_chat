require Logger
require IEx

defmodule TelnetChat do
  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    #
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    accept_client(socket)
    loop_acceptor(socket)
  end

  defp accept_client(socket) do
    {:ok, client_socket} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(TelnetChat.TaskSupervisor, fn -> serve(client_socket) end)
    :ok = :gen_tcp.controlling_process(client_socket, pid)

    TelnetChat.ClientRegistry.add_client(TelnetChat.ClientRegistry, pid, client_socket)
  end

  defp serve(client_socket) do
    line = read_line(client_socket)

    TelnetChat.ClientRegistry.for_all_clients TelnetChat.ClientRegistry, fn other_client_socket ->
      unless other_client_socket == client_socket do
        write_line(line, other_client_socket)
      end
    end

    serve(client_socket)
  end

  defp read_line(client_socket) do
    case :gen_tcp.recv(client_socket, 0) do
      {:ok, data} -> data
      {:error, :closed} ->
        TelnetChat.ClientRegistry.for_all_clients TelnetChat.ClientRegistry, fn other_client_socket ->
          unless other_client_socket == client_socket do
            write_line("Someone went offline", other_client_socket)
          end
        end
        Process.exit(self(), :normal)
    end
  end

  defp write_line(line, client_socket) do
    :gen_tcp.send(client_socket, line)
  end
end