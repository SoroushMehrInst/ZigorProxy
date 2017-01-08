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

  @enforce_keys [:socket, :transport]
  defstruct [:socket, :transport]
end
