defmodule Mortar.A do
  @doc """
  (A)ssociative Array (Get), retrieves a value by a given key in a keyword list or map, with default
  """
  @spec aget(map() | Keyword.t(), atom(), any()) :: any()
  def aget(list, key, default \\ nil)

  def aget(list, key, default) when is_list(list) do
    Keyword.get(list, key, default)
  end

  def aget(map, key, default) when is_map(map) do
    Map.get(map, key, default)
  end

  @doc """
  (A)ssociative Array (Put New), acts like Map.put_new/3 and Keyword.put_new/3
  """
  @spec aput_new(map() | Keyword.t(), atom(), any()) :: any()
  def aput_new(list, key, value)

  def aput_new(list, key, value) when is_list(list) do
    Keyword.put_new(list, key, value)
  end

  def aput_new(map, key, value) when is_map(map) do
    Map.put_new(map, key, value)
  end

  @doc """
  (A)ssociative Array (Split), acts like Map.split/2 and Keyword.split/2
  """
  @spec asplit(map() | Keyword.t(), [atom()]) :: any()
  def asplit(list, keys)

  def asplit(list, keys) when is_list(list) and is_list(keys) do
    Keyword.split(list, keys)
  end

  def asplit(map, keys) when is_map(map) and is_list(keys) do
    Map.split(map, keys)
  end

  @doc """
  (A)ssociative Array (Take), acts like Map.take/2 and Keyword.take/2
  """
  @spec atake(map() | Keyword.t(), [atom()]) :: any()
  def atake(list, keys)

  def atake(list, keys) when is_list(list) and is_list(keys) do
    Keyword.take(list, keys)
  end

  def atake(map, keys) when is_map(map) and is_list(keys) do
    Map.take(map, keys)
  end

  @doc """
  (A)ssociative Array (Drop), acts like Map.drop/2 and Keyword.drop/2
  """
  @spec adrop(map() | Keyword.t(), [atom()]) :: any()
  def adrop(list, keys)

  def adrop(list, keys) when is_list(list) and is_list(keys) do
    Keyword.drop(list, keys)
  end

  def adrop(map, keys) when is_map(map) and is_list(keys) do
    Map.drop(map, keys)
  end
end
