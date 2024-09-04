defmodule Mortar.Random do
  import Mortar.String, only: [atom_to_gql_enum: 1]

  @doc """
  Takes an enum module and randomly returns one of its valid values
  """
  @spec random_enum_value(module()) :: any()
  def random_enum_value(enum) do
    [{value, _}] = Enum.take_random(enum.__enum_map__, 1)
    value
  end

  @doc """
  random_enum_value but the returned value is transformed into a valid GraphQL enum value
  """
  @spec random_enum_value_gql(module()) :: any()
  def random_enum_value_gql(enum) do
    case random_enum_value(enum) do
      value when is_binary(value) ->
        String.upcase(value)

      value when is_atom(value) ->
        atom_to_gql_enum(value)
    end
  end

  @doc """
  Generates a random string of digits
  """
  @spec generate_random_digits(len::integer()) :: String.t()
  def generate_random_digits(0) do
    ""
  end

  def generate_random_digits(len) when is_integer(len) and len > 0 do
    (1..len)
    |> Enum.map(fn _ ->
      ?0 + :rand.uniform(10) - 1
    end)
    |> IO.iodata_to_binary()
  end

  @moduledoc """
  Utility module for generating random strings, for various thing-ma-bobs.
  """
  @spec generate_random_base16(non_neg_integer, Keyword.t()) :: String.t()
  def generate_random_base16(len, options \\ [])

  def generate_random_base16(0, _options) do
    ""
  end

  def generate_random_base16(len, options) when is_integer(len) and len > 0 do
    len
    |> :crypto.strong_rand_bytes()
    |> Base.encode16(options)
    |> binary_part(0, len)
  end

  @spec generate_random_base32(non_neg_integer, Keyword.t()) :: String.t()
  def generate_random_base32(len, options \\ [])

  def generate_random_base32(0, _options) do
    ""
  end

  def generate_random_base32(len, options) when is_integer(len) and len > 0 do
    (len * 2)
    |> :crypto.strong_rand_bytes()
    |> Base.encode32(options)
    |> binary_part(0, len)
  end

  @spec generate_random_base64(non_neg_integer, Keyword.t()) :: String.t()
  def generate_random_base64(len, options \\ [])

  def generate_random_base64(0, _options) do
    ""
  end

  def generate_random_base64(len, options) when is_integer(len) and len > 0 do
    (len * 2)
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(options)
    |> binary_part(0, len)
  end
end
