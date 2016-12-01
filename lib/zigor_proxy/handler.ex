defmodule ZigorProxy.Handler do
  @doc """
  handles an incomming socket before handshake and init encrypt
  """
  import SocketUtils

  def handle_zigor_client(client) do
    {:ok, origin} = origin_chan_create

  end

  defp pass_packet(listen_socket, write_socket) do
    listen_socket |>
      read_packet |>
      write_packet(write_socket)
  end

  defp read_packet(socket) do
    :ok = await_zigor_pseudo socket
    pack_len = read_int32(socket)
    read_bytes(socket, pack_len)
  end

  defp write_packet(packet, socket) do

  end

  defp write_pseudo(socket) do
    write_bytes(socket, <<255, 254, 255, 255>>)
    
  end

  defp origin_chan_create do
    addr = Application.get_env(:zigor_proxy, :proxy_addr)
    port = Application.get_env(:zigor_proxy, :proxy_port)

    :gen_tcp.connect(addr, port, [:binary, packet: :raw, buffer: 128])
  end

  defp await_zigor_pseudo(socket, index \\ 0) do
    case {index, read_byte(socket)} do
      {0, 255} -> await_zigor_pseudo(socket, 1)
      {1, 254} -> await_zigor_pseudo(socket, 2)
      {2, 255} -> await_zigor_pseudo(socket, 3)
      {3, 255} -> :ok
      _ -> await_zigor_pseudo(socket, 0)
    end
  end
end
