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
  def handle_zigor_client(client) do
    Logger.debug "new client connected"
    {:ok, origin} = origin_chan_create

    pid = spawn(ZigorProxy.Handler, :pass_packet, [origin, client])
    :ok = :gen_tcp.controlling_process(origin, pid)

    pass_packet(client, origin)
  end

  def pass_packet(listen_socket, write_socket) do
    listen_socket |>
      read_packet |>
      write_packet(write_socket)

    pass_packet(listen_socket, write_socket)
  end

  @doc """
  awaits pseudo on socket and then reads a packet from socket returns it from packet_Id
  """
  def read_packet(socket) do
    :ok = await_zigor_pseudo socket
    pack_len = read_int32(socket)

    read_bytes(socket, pack_len)
  end

  @doc """
  writes pseudo, packet_length and packet data to a given socket
  first argument is packet ans second argument is socket (for sake of using |> operator)
  """
  def write_packet(packet, socket) do
    :ok = write_pseudo socket
    :ok = write_int32(socket, byte_size(packet))
    :ok = write_bytes(socket, packet)
    :ok
  end

  def write_packet(nil, _socket) do
    :ok
  end

  defp write_pseudo(socket) do
    socket |>
      write_bytes(<<255, 255, 254, 255>>)
  end

  defp origin_chan_create do
    addr = Application.get_env(:zigor_proxy, :proxy_addr)
    port = Application.get_env(:zigor_proxy, :proxy_port)

    connect_to(addr, port)
  end

  @doc """
  connects to a tcp server using gen_tcp and default zigor socket opts
  returns {:ok, socket} in term of success and {:error, reason} in case of error
  """
  def connect_to(addr, port) do
    :gen_tcp.connect(addr, port, [:binary, packet: :raw, active: false])
  end

  defp await_zigor_pseudo(socket, index \\ 0) do
    pseitem = read_byte(socket)
    case {index, pseitem} do
      {0, 255} -> await_zigor_pseudo(socket, 1)
      {1, 255} -> await_zigor_pseudo(socket, 2)
      {2, 254} -> await_zigor_pseudo(socket, 3)
      {3, 255} -> :ok
      _ -> await_zigor_pseudo(socket, 0)
    end
  end
end
