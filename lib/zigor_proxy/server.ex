defmodule ZigorProxy.Server do
  @moduledoc """
  This module handles the tcp listener(s) and distributing tcp connections in Tasks.
  """
  require Logger
  alias ZigorProxy.ZigorSocket

  @doc """
  Starts listening for sockets on a specified port over TCP.
  This call is never ending!

  Whenever a client connects, handle_client will fire from ZigorProxy.Handler

  ## Parameters
    - port: port number of the listener bindings
    - ip: ip address of the listener bindings
    - server_port: port of real end zigor server
    - server_ip: IP address of real end zigor server
  """
  def start_listen(port, ip, server_port, server_ip) do
    Logger.info "Starting ZigCrypt listener on port #{port}"
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :raw, ip: ip, active: false, reuseaddr: true])
    Logger.info "ZigCrypt listener successfully started on port #{port}"

    # Normal TCP socket acceptance in an anonymous function
    accept_func = fn(socket) -> :gen_tcp.accept(socket) end

    loop_acceptor(%ZigorSocket{socket: socket, transport: :gen_tcp},
     server_port,
     server_ip,
     accept_func)
  end

  @doc """
  Starts listening for sockets on a specific port via SSL transport over TCP.
  This call is never ending!

  Whenever a client connects, handle_client will be fired from ZigorProxy.Handler

  ## Parameters:
    - port: port number of the listener bindings
    - ip: ip address of the listener bindings
    - server_port: port of real end zigor server
    - server_ip: IP address of real end zigor server
    - cert: ssl certificate public key filename
    - key: ssl certificate private key filename
  """
  def start_listen_ssl(port, ip, server_port, server_ip, cert, key) do
    Logger.info "Starting SSL listener on port #{port}"
    :ssl.start() # Start SSL module
    {:ok, socket} = :ssl.listen(port, [:binary, packet: :raw, certfile: cert, keyfile: key, ip: ip, active: false, reuseaddr: true])
    Logger.info "SSL listener successfully started on port #{port}"

    # The ssl acceptance of a socket in an anonymous function
    accept_func = fn(socket) ->
      case :ssl.transport_accept(socket) do
        {:ok, soc} ->
          case :ssl.ssl_accept(soc) do
            :ok ->
              {:ok, soc}
            _ ->
              {:error, :ssl_accept_error}
          end

        _ ->
          {:error, :ssl_error}
      end
    end

    loop_acceptor(%ZigorSocket{socket: socket, transport: :ssl},
     server_port,
     server_ip,
     accept_func)
  end

  defp loop_acceptor(zigor_socket, server_port, server_ip, accept_func) do
    case accept_func.(zigor_socket.socket) do
      {:ok, client} ->
        zg_client = %ZigorSocket{socket: client, transport: zigor_socket.transport}
        pid = spawn(ZigorProxy.Handler, :handle_client, [zg_client, server_port, server_ip])
        zigor_socket.transport.controlling_process(client, pid)
        loop_acceptor(zigor_socket, server_port, server_ip, accept_func)
      _ ->
        loop_acceptor(zigor_socket, server_port, server_ip, accept_func)
    end
  end
end
