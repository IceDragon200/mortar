defmodule Mortar.Z do
  @moduledoc """
  Any compression related utility functions are found here.
  """

  @spec zip_deflate(binary(), Keyword.t()) :: {:ok, iodata()}
  def zip_deflate(blob, options \\ []) do
    z = :zlib.open()
    try do
      with :ok <- :zlib.deflateInit(z, :default),
           iodata <- :zlib.deflate(z, blob, :finish),
           :ok <- :zlib.deflateEnd(z) do
        case Keyword.get(options, :return, :binary) do
          :iodata ->
            {:ok, iodata}

          :binary ->
            {:ok, IO.iodata_to_binary(iodata)}
        end
      end
    after
      :zlib.close(z)
    end
  end

  @spec zip_deflate!(binary(), Keyword.t()) :: iodata()
  def zip_deflate!(blob, options \\ []) do
    {:ok, blob} = zip_deflate(blob, options)
    blob
  end

  @spec zip_inflate(binary(), Keyword.t()) :: {:ok, iodata()}
  def zip_inflate(blob, options \\ []) do
    z = :zlib.open()
    try do
      with :ok <- :zlib.inflateInit(z),
           iodata <- :zlib.inflate(z, blob),
           :ok <- :zlib.inflateEnd(z) do
        case Keyword.get(options, :return, :binary) do
          :iodata ->
            {:ok, iodata}

          :binary ->
            {:ok, IO.iodata_to_binary(iodata)}
        end
      end
    after
      :zlib.close(z)
    end
  end

  @spec zip_inflate!(binary(), Keyword.t()) :: iodata()
  def zip_inflate!(blob, options \\ []) do
    {:ok, blob} = zip_inflate(blob, options)
    blob
  end
end
