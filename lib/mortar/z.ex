defmodule Mortar.Z do
  @moduledoc """
  Any compression related utility functions are found here.
  """

  @spec zip_deflate!(binary(), Keyword.t()) :: binary()
  def zip_deflate!(blob, options \\ []) do
    z = :zlib.open()
    :ok = :zlib.deflateInit(z, :default)
    iodata = :zlib.deflate(z, blob, :finish)
    :ok = :zlib.deflateEnd(z)
    :zlib.close(z)

    case Keyword.get(options, :return, :binary) do
      :iodata ->
        iodata

      :binary ->
        IO.iodata_to_binary(iodata)
    end
  end

  def zip_inflate!(blob, options \\ []) do
    z = :zlib.open()
    :ok = :zlib.inflateInit(z)
    iodata = :zlib.inflate(z, blob)
    :ok = :zlib.inflateEnd(z)
    :zlib.close(z)

    case Keyword.get(options, :return, :binary) do
      :iodata ->
        iodata

      :binary ->
        IO.iodata_to_binary(iodata)
    end
  end
end
