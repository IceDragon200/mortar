defmodule Mortar.Map do
  @doc """
  Determines if the map has any key-value pairs, if it does, then it is present,
  otherwise it is not.
  """
  @spec presence(map()) :: map()
  def presence(map) when is_map(map) and map_size(map) > 0 do
    map
  end

  def presence(map) when is_map(map) do
    nil
  end

  @doc """
  Sets given key in map even if explictly nil.

  Return:
  * `map` - the updated map
  """
  @spec replace_nil(map(), Map.key(), Map.value()) :: map()
  def replace_nil(map, key, value) when is_map(map) do
    case map[key] do
      nil ->
        Map.put(map, key, value)

      _ ->
        map
    end
  end

  @doc """
  Map.put but if the value is nil, nothing happens

  Args:
  * `map` - the target map
  * `key` - the key
  * `value` - the value to set

  Return:
  * `map` - the updated map
  """
  @spec put_non_nil(map(), Map.key(), Map.value()) :: map()
  def put_non_nil(map, _key, nil) when is_map(map) do
    map
  end

  def put_non_nil(map, key, value) when is_map(map) do
    Map.put(map, key, value)
  end

  @doc """
  Inverts a given key-value pair object (e.g. map or keyword list)
  That is, the keys become values, and the values become the keys
  """
  @spec invert_map_pairs(map()) :: map()
  def invert_map_pairs(map) when is_map(map) do
    Enum.reduce(map, %{}, fn {key, value}, acc ->
      Map.put(acc, value, key)
    end)
  end

  @doc """
  Combines a put_new and get function into one, returning a tuple with the value and map
  respectively.
  """
  @spec put_new_and_get(map(), Map.key(), Map.value()) :: {Map.value(), map()}
  def put_new_and_get(map, key, value) do
    # What were you expecting, something magical?
    map = Map.put_new(map, key, value)
    {Map.get(map, key), map}
  end

  @doc """
  Combines a put_new_lazy and get function into one, returning a tuple with the value and map
  respectively.
  """
  @spec put_new_and_get(map(), Map.key(), (-> Map.value())) :: {Map.value(), map()}
  def put_new_lazy_and_get(map, key, fun) do
    map = Map.put_new_lazy(map, key, fun)
    {Map.get(map, key), map}
  end
end
