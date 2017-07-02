defmodule ZigorProxy.Handler do
  @moduledoc """
  This module handles Zigor connections and whole ZigorSocket Operations.
  """
  import ZigorProxy.ZigorSocket
  require Logger

  @doc """
  this function will handle a zigor client connecting to socket.
  everytime a user connects this function will be fired from the socket listener

  ## Parameters
    - client: the client socket which connected to server listener bindings
    - server_port: real end of proxy port
    - server_ip: read end of proxy ip address
  """
  def handle_client(zg_client, server_port, server_ip) do
    Logger.debug "Client recieved"
    case connect_to(server_ip, server_port, zg_client.transport) do
      {:ok, zg_origin} ->

        Logger.debug "Client connected!"

        pid = spawn(ZigorProxy.Handler, :pass_packet, [zg_origin, zg_client])
        zg_client.transport.controlling_process(zg_origin.socket, pid)

        pipe_resp = pass_packet(zg_client, zg_origin)

        Logger.debug "Client disconnected! #{inspect pipe_resp}"

        zg_client.transport.close(zg_client.socket)
        zg_client.transport.close(zg_origin.socket)
      _ ->
        Logger.error "Server #{server_ip}:#{server_port} is not accessible"
        :server_diconn
    end
  end

  @doc false
  def pass_packet(from, to, nils \\ 0) do
    pipe_resp = pipe_packet(from, to)
    case pipe_resp do
        :ok -> pass_packet(from, to, 0)
        :nil_packet when nils <= 2 -> pass_packet(from, to, nils + 1)
        :nil_packet when nils > 2 -> {:error, :nodata}
        :sopih -> {:error, :node_died} # Shoot other Peer In the Head
        _ -> {:error, :unknown}
      end
  end

  defp pipe_packet(from, to) do
    from |>
    read_packet |>
    write_packet(to)
  end

  @doc """
  awaits pseudo on socket and then reads a packet from socket returns it from packet_Id

  ## Parameters
    - socket: TCP socket to read from
  """
  def read_packet(socket) do
    case await_zigor_pseudo(socket) do
        :ok ->
          pack_len = read_int32(socket)
          read_bytes(socket, pack_len)
        _  -> nil
    end
  end

  @doc false
  def write_packet(nil, _socket) do
    :nil_packet
  end

  @doc false
  def write_packet({:error, _reason}, _socket) do
    :sopih # Shoot other Peer In the Head
  end

  @doc """
  writes pseudo, packet_length and packet data to a given socket
  first argument is packet ans second argument is socket (for sake of using |> operator)

  ## Parameters
    - packet: packet in form of binary to write to a TCP socket (should not include `pseudo` or `size`)
    - socket: a TCP socket to write the packet to
  """
  def write_packet(packet, socket) do
    write_pseudo(socket)
    write_int32(socket, byte_size(packet))

    case write_bytes(socket, packet) do
      :ok -> :ok
      _ -> :nil_packet
    end
  end

  defp write_pseudo(socket) do
    socket |>
      write_bytes(<<255, 255, 254, 255>>)
  end

  @doc """
  connects to a tcp server using gen_tcp and default zigor socket opts
  returns {:ok, socket} in term of success and {:error, reason} in case of error

  ## Parameters
    - addr: the IP address of a remote TCP binding to connect to
    - port: the port of a remote TCP binding to connect to
  """
  def connect_to(addr, port, transport) do
    extra_opts =
      case transport do
        :ssl ->
          [{:versions, [:'tlsv1.2']}, {:mode, :binary}]
        _ ->
          []
      end

    case transport.connect(addr, port, [:binary, {:packet, :raw}, {:active, false} | extra_opts]) do
      {:ok, socket} -> {:ok, %ZigorProxy.ZigorSocket{socket: socket, transport: transport}}
      error -> error
    end
  end

  # First strike to read zigor pseudo, if match failed, we go old school!
  defp await_zigor_pseudo(socket) do
    case read_bytes(socket, 4) do
      <<255, 255, 254, 255>> ->
        :ok
      nil ->
        await_zigor_pseudo(socket)
      data ->
        Logger.debug "Zigor pseudo first strike failed with #{inspect data}"
        await_zigor_pseudo(socket, 0)
    end
  end

  defp await_zigor_pseudo(socket, index, tries \\ 0) do
    case {index, read_byte(socket)} do
      {0, 255} -> await_zigor_pseudo(socket, 1)
      {1, 255} -> await_zigor_pseudo(socket, 2)
      {2, 254} -> await_zigor_pseudo(socket, 3)
      {3, 255} -> :ok
      {_, {:error, _}} -> :error
      {_, nil} -> :error
      _ ->
        if tries > 1024 do

        end
        await_zigor_pseudo(socket, 0, tries + 1)
    end
  end
end
