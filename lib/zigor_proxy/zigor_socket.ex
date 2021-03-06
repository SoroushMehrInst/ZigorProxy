defmodule ZigorProxy.ZigorSocket do
  @moduledoc """
  This module is holder of ZigorSocket struct.
  ZigorSocket holds a socket and its transport module. transport module should implement:
    - connect/3
    - recv/3
    - send/2
    - controlling_proccess/2

  ``ZigorSocket`` is made to make read & write to different types of socket easier. e.g: ZigCrypt, SSL and...
  """

  import ZigorProxy.BitConverter

  @enforce_keys [:socket, :transport]
  defstruct [:socket, :transport]

  @read_timeout 7000

  ###
  # Socket Read Operations
  ###

  @doc """
  Reads 4 bytes from socket and converts it to signed number

  ## Parameters
    - socket: a TCP socket to read data from
  """
  def read_int32(socket) do
    socket
    |> read_bytes(4)
    |> get_int32
  end

  # TODO: Handle {:error, :closed} on socket read
  @doc """
  reads ``count`` bytes from ``socket`` and returns it as binary

  ## Parameters
    - socket: a TCP socket to read data from
    - count: count of bytes to read from `socket`
  """
  def read_bytes(socket, count) do
    case socket.transport.recv(socket.socket, count, @read_timeout) do
      {:ok, data} -> data
      {:error, :closed} -> {:error, :closed}
      other ->
        nil
    end
  end

  @doc """
  reads a single byte form socket and returns it as number

  ## Parametes
    - socket: a TCP socket to read data from
  """
  def read_byte(socket) do
    case socket.transport.recv(socket.socket, 1, @read_timeout) do
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
    socket.transport.send(socket.socket, data)
  end

  @doc """
  writes a single byte to socket as a single element binary

  ## Parameters
    - socket: a TCP socket to write data to
    - byte: a single byte to write to socket
  """
  def write_byte(socket, byte) do
    socket.transport.send(socket.socket, <<byte>>)
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
