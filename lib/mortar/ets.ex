defmodule Mortar.ETS do
  @moduledoc """
  This module contains utility functions for working with ETS tables.
  """
  @type acc :: term()

  @type acc_res :: {:cont, term()} | {:halt, term()}

  @type reducer_function :: (tuple(), acc -> acc)

  @type while_reducer_function :: (tuple(), acc -> acc_res)

  @spec safe_reduce_ets_table(:ets.table(), acc(), reducer_function()) :: acc()
  def safe_reduce_ets_table(table, acc, fun) do
    safe_reduce_ets_table_while(table, acc, fn obj, acc ->
      acc = fun.(obj, acc)
      {:cont, acc}
    end)
  end

  @spec reduce_ets_table(:ets.table(), acc(), reducer_function()) :: acc()
  def reduce_ets_table(table, acc, fun) do
    reduce_ets_table_while(table, acc, fn obj, acc ->
      acc = fun.(obj, acc)
      {:cont, acc}
    end)
  end

  @doc """
  Fixes the table and then executes reduce_ets_table/3 using the given parameters.

  This ensures the table is safe to traverse from multiple processes.
  """
  @spec safe_reduce_ets_table_while(:ets.table(), acc(), while_reducer_function()) :: acc()
  def safe_reduce_ets_table_while(table, acc, fun) when is_function(fun, 2) do
    try do
      :ets.safe_fixtable(table, true)
      reduce_ets_table_while(table, acc, fun)
    after
      :ets.safe_fixtable(table, false)
    end
  end

  @doc """

  """
  @spec reduce_ets_table_while(:ets.table(), acc(), while_reducer_function()) :: acc()
  def reduce_ets_table_while(table, acc, fun) when is_function(fun, 2) do
    key = :ets.first(table)
    do_reduce_ets_table_while(key, table, acc, fun)
  end

  defp do_reduce_ets_table_while(:'$end_of_table', _table, acc, _fun) do
    acc
  end

  defp do_reduce_ets_table_while(key, table, acc, fun) do
    case reduce_ets_objects_while(:ets.lookup(table, key), acc, fun) do
      {:halt, acc} ->
        acc

      {:cont, acc} ->
        do_reduce_ets_table_while(:ets.next(table, key), table, acc, fun)
    end
  end

  @spec reduce_ets_objects_while(list(), acc(), while_reducer_function()) :: acc_res()
  defp reduce_ets_objects_while([], acc, _callback) do
    {:cont, acc}
  end

  defp reduce_ets_objects_while([obj | rest], acc, fun) do
    case fun.(obj, acc) do
      {:cont, acc} ->
        reduce_ets_objects_while(rest, acc, fun)

      {:halt, acc} ->
        {:halt, acc}
    end
  end

  @doc """
  Insert the given object if its key doesn't exist yet.
  """
  @spec insert_new(:ets.table(), tuple()) :: boolean()
  def insert_new(table, object) when is_tuple(object) do
    key = elem(object, 0)
    case :ets.lookup(table, key) do
      [] ->
        :ets.insert(table, object)

      [_ | _] ->
        false
    end
  end

  @doc """
  Insert object evaluated from fun if key does not already exist.
  """
  @spec insert_new_lazy(:ets.table(), any(), tuple()) :: boolean()
  def insert_new_lazy(table, key, fun) when is_function(fun, 1) do
    case :ets.lookup(table, key) do
      [] ->
        :ets.insert(table, fun.(key))

      [_ | _] ->
        false
    end
  end

  @doc """
  Map over all objects in table by given key.
  """
  @spec map_objects(:ets.table(), any(), function()) :: boolean()
  def map_objects(table, key, fun) when is_function(fun, 1) do
    list = :ets.take(table, key)
    list = Enum.map(list, fun)
    :ets.insert(table, list)
  end

  @doc """
  Updates objects in a given table with a possible default pair.

  If the key isn't already set, then the default tuple is assumed.

  Otherwise any objects set under the key is used instead.

  The list of objects will be mapped using the given function, even if it is the default.

  Usage:

      update_objects_with_default(my_table, a_key, {a_key, value}, fn {_key, _value} = tup ->
        tup
      end)

  """
  @spec update_objects_with_default(:ets.table(), any(), tuple(), function()) :: boolean()
  def update_objects_with_default(
    table,
    key,
    default,
    fun
  ) when is_tuple(default) and is_function(fun, 1) do
    list =
      case :ets.take(table, key) do
        [] ->
          [default]

        list when is_list(list) ->
          list
      end

    list = Enum.map(list, fun)
    :ets.insert(table, list)
  end
end
