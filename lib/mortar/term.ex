defmodule Mortar.Term do
  @doc """
  Unified presence functions.
  """
  @spec presence(any()) :: any()
  def presence(nil), do: nil
  def presence(bin) when is_binary(bin), do: Mortar.String.presence(bin)
  def presence(list) when is_list(list), do: Mortar.List.presence(list)
  def presence(map) when is_map(map), do: Mortar.Map.presence(map)
  def presence(num) when is_number(num), do: num
  def presence(bool) when is_boolean(bool), do: bool
  def presence(%_{} = val), do: val

  @spec is_present?(binary()) :: boolean()
  def is_present?(value) do
    not is_nil(presence(value))
  end

  @spec is_blank?(binary()) :: boolean()
  def is_blank?(value) do
    is_nil(presence(value))
  end
end
