defmodule ZigorProxy.Server do
  @moduledoc """
  This module handles the tcp listener(s) and distributing tcp connections in Tasks.
  """

  @doc """
  Starts listening for sockets on a specified port.
  This call is never ending!

  Whenever a client connects, handle_zigor_client will fire from ZigorProxy.Handler
  """
  def start_listen(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])
    loop_acceptor(socket)
  end

  @doc """
  This function will accept sockets and hand them off to socket handlers asynchronously
  """
  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(ZigorProxy.ClientSupervisor, ZigorProxy.Handler, :handle_zigor_client, [client: client])
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end
end
