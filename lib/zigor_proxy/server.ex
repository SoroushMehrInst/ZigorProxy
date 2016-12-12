defmodule ZigorProxy.Server do
  @moduledoc """
  This module handles the tcp listener(s) and distributing tcp connections in Tasks.
  """
  require Logger

  @doc """
  Starts listening for sockets on a specified port.
  This call is never ending!

  Whenever a client connects, handle_zigor_client will fire from ZigorProxy.Handler
  """
  def start_listen(port, ip, server_port, server_ip) do
    Logger.debug "Starting service on #{port}"
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :raw, ip: ip, active: false, reuseaddr: true, keepalive: true])
    Logger.debug "listener successfully started on #{port}"
    loop_acceptor(socket, server_port, server_ip)
  end

  #TODO: Supervise server socket for reconnecting without client notice
  defp loop_acceptor(socket, server_port, server_ip) do
    {:ok, client} = :gen_tcp.accept(socket)
    pid = spawn(ZigorProxy.Handler, :handle_zigor_client, [client, server_port, server_ip])
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket, server_port, server_ip)
  end
end
