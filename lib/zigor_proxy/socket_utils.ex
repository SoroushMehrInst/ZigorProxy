defmodule SocketUtils do
  @moduledoc """
  This module helps with read and write from or to a Zigor socket.
  """

  ###
  # Socket Read Operations
  ###

  def read_int32(socket) do
    data = socket |>
    read_bytes(4) |>
    BitConverter.get_int32
  end

  def read_bytes(socket, count) do
    {:ok, data} = :gen_tcp.recv(socket, count)
    data
  end

  def read_byte(socket) do
    {:ok, << single >>} = :gen_tcp.recv(socket, 1)
    single
  end

  ###
  # Socket Write Operations
  ###

  def write_bytes(socket, data) do
    :gen_tcp.send(socket, data)
  end

  def write_byte(socket, byte) do
    :gen_tcp.send(socket, <<byte>>)
  end

  def write_int32(socket, number) do
    socket |>
    write_bytes(BitConverter.int32_bytes number)
  end
end
