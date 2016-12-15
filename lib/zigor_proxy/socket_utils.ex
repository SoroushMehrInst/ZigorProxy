defmodule ZigorProxy.SocketUtils do
  import ZigorProxy.BitConverter
  @moduledoc """
  This module helps with read and write from or to a Zigor socket.
  """

  ###
  # Socket Read Operations
  ###

  @doc """
  Reads 4 bytes from socket and converts it to signed number

  ## Parameters
    - socket: a TCP socket to read data from
  """
  def read_int32(socket) do
    socket |>
    read_bytes(4) |>
    get_int32
  end

  # TODO: Handle {:error, :closed} on socket read
  @doc """
  reads \"count\" bytes from \"socket\" and returns it as binary

  ## Parameters
    - socket: a TCP socket to read data from
    - count: count of bytes to read from `socket`
  """
  def read_bytes(socket, count) do
    case :gen_tcp.recv(socket, count, 1000) do
      {:ok, data} -> data
      {:error, :closed} -> {:error, :closed}
      _ -> nil
    end
  end

  @doc """
  reads a single byte form socket and returns it as number

  ## Parametes
    - socket: a TCP socket to read data from
  """
  def read_byte(socket) do
    case :gen_tcp.recv(socket, 1, 1000) do
      {:ok, << single >>} -> single
      {:error, :closed} -> {:error, :closed}
      _ -> nil
    end
  end

  ###
  # Socket Write Operations
  ###

  @doc """
  writes data to socket

  ## Parameters
    - socket: a TCP socket to write data to
    - data: a binary formatted data to write to socket
  """
  def write_bytes(socket, data) do
    :gen_tcp.send(socket, data)
  end

  @doc """
  writes a single byte to socket as a single element binary

  ## Parameters
    - socket: a TCP socket to write data to
    - byte: a single byte to write to socket
  """
  def write_byte(socket, byte) do
    :gen_tcp.send(socket, <<byte>>)
  end

  @doc """
  writes an int32 to socket as a little endian binary

  ## Parameters
    - socket: a TCP socket to write data to
    - number: number to write to TCP socket
  """
  def write_int32(socket, number) do
    socket |>
    write_bytes(int32_bytes number)
  end
end
