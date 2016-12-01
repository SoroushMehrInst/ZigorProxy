defmodule ZigorProxy.BitConverter do
  @moduledoc """
  This module handles standard binary operations
  """

  @doc """
  Converts binary of 4 bytes into an signed integer.
  First byte is considered as signature of number.

  ## Examples
    iex> ZigorProxy.BitConverter.get_int32(<<255,255,255,255>>)
    -1

    iex> ZigorProxy.BitConverter.get_int32(<<0,0,0,10>>)
    10
  """
  def get_int32(data) do
    <<sign::size(1), num::size(31)>> = data
    if sign == 1 do
      -1 * (2147483648 - num)
    else
      num
    end
  end

  @doc """
  Converts a number into binary.
  this function handles negative and positive numbers.

  ### Examples
    iex> ZigorProxy.BitConverter.int32_bytes(-1)
    <<255,255,255,255>>

    iex> ZigorProxy.BitConverter.int32_bytes(1)
    <<0,0,0,1>>
  """
  def int32_bytes(number) do
    <<number::32>>
  end
end
