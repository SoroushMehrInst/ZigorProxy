defmodule ZigorProxy.BitConverterTest do
  use ExUnit.Case
  import ZigorProxy.BitConverter

  test ".converting int to bytes and bytes to ints is working with negative numbers?" do
    num = :rand.uniform(1_000_000)
    data = int32_bytes(num)
    num_back = get_int32(data)
    assert num == num_back
  end

  test ".converting int to bytes and bytes to ints is working with positive numbers?" do
    num = -1 * :rand.uniform(1_000_000)
    data = int32_bytes(num)
    num_back = get_int32(data)
    assert num == num_back
  end
end
