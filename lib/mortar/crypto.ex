defmodule Mortar.Crypto do
  @doc """
  Generates HMAC SHA1 digest from given key and blob
  """
  @spec hmac_sha1(binary(), binary()) :: binary()
  def hmac_sha1(key, blob) when is_binary(key) and is_binary(blob) do
    :crypto.mac(:hmac, :sha, key, blob)
  end

  @doc """
  Generates HMAC SHA256 digest from given key and blob
  """
  @spec hmac_sha256(binary(), binary()) :: binary()
  def hmac_sha256(key, blob) when is_binary(key) and is_binary(blob) do
    :crypto.mac(:hmac, :sha256, key, blob)
  end

  @doc """
  Generates HMAC SHA512 digest from given key and blob
  """
  @spec hmac_sha512(binary(), binary()) :: binary()
  def hmac_sha512(key, blob) when is_binary(key) and is_binary(blob) do
    :crypto.mac(:hmac, :sha512, key, blob)
  end
end
