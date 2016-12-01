defmodule BitConverter do
  def get_int32(data) do
    :binary.decode_unsigned(data)
  end

  def int32_bytes(number) do
    data = <<number::32>>
  end
end
