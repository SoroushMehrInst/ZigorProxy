defmodule ZigorProxy.Handler do
  @moduledoc """
  This module handles Zigor connections and whole ZigorSocket Operations.
  """
  import ZigorProxy.SocketUtils
  require Logger

  @doc """
  this function will handle a zigor client connecting to socket.
  everytime a user connects this function will be fired from the socket listener
  """
  def handle_zigor_client(client, server_port, server_ip) do
    Logger.debug "--- New client connected"
    {:ok, origin} = connect_to(server_ip, server_port)

    pid = spawn(ZigorProxy.Handler, :pass_packet, [origin, client])
    :ok = :gen_tcp.controlling_process(origin, pid)

    pass_packet(client, origin)

    :gen_tcp.close(client)
    :gen_tcp.close(origin)

    Process.exit(pid, :kill)

    Logger.debug "-x- a client disconnected!"
  end

  @doc false
  def pass_packet(listen_socket, write_socket, nilpacks \\ 0) do
    case listen_socket |>
      read_packet |>
      write_packet(write_socket) do
        :ok -> pass_packet(listen_socket, write_socket, 0)
        :nil_packet when nilpacks <= 5 -> pass_packet(listen_socket, write_socket, nilpacks + 1)
        :nil_packet when nilpacks > 5 -> {:error, :nodata}
        :sopih -> {:error, :node_died} # Shoot other Peer In the Head
      end
  end

  @doc """
  awaits pseudo on socket and then reads a packet from socket returns it from packet_Id
  """
  def read_packet(socket) do
    case await_zigor_pseudo socket do
        :ok ->
          pack_len = read_int32(socket)
          read_bytes(socket, pack_len)
        _  -> nil
    end

  end

  @doc """
  writes pseudo, packet_length and packet data to a given socket
  first argument is packet ans second argument is socket (for sake of using |> operator)
  """
  def write_packet(packet, socket) when is_nil(packet) == false do
    :ok = write_pseudo socket
    :ok = write_int32(socket, byte_size(packet))
    :ok = write_bytes(socket, packet)
    :ok
  end

  def write_packet(nil, _socket) do
    :nil_packet
  end

  def write_packet({:error, _reason}, _socket) do
    :sopih # Shoot other Peer In the Head
  end

  defp write_pseudo(socket) do
    socket |>
      write_bytes(<<255, 255, 254, 255>>)
  end

  @doc """
  connects to a tcp server using gen_tcp and default zigor socket opts
  returns {:ok, socket} in term of success and {:error, reason} in case of error
  """
  def connect_to(addr, port) do
    :gen_tcp.connect(addr, port, [:binary, packet: :raw, active: false, keepalive: true])
  end

  defp await_zigor_pseudo(socket, index \\ 0) do
    case {index, read_byte(socket)} do
      {0, 255} -> await_zigor_pseudo(socket, 1)
      {1, 255} -> await_zigor_pseudo(socket, 2)
      {2, 254} -> await_zigor_pseudo(socket, 3)
      {3, 255} -> :ok
      {_, {:error, _}} -> :error
      {_, nil} -> :error
      _ -> await_zigor_pseudo(socket, 0)
    end
  end
end
