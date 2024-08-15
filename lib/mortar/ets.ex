defmodule Mortar.ETS do
  @moduledoc """
  This module contains utility functions for working with ETS tables.
  """

  def safe_reduce_ets_table(table, acc, callback) do
    try do
      :ets.safe_fixtable(table, true)
      reduce_ets_table(table, acc, callback)
    after
      :ets.safe_fixtable(table, false)
    end
  end

  def reduce_ets_table(table, acc, callback) do
    key = :ets.first(table)
    do_reduce_ets_table(key, table, acc, callback)
  end

  defp do_reduce_ets_table(:'$end_of_table', _table, acc, _callback) do
    acc
  end

  defp do_reduce_ets_table(key, table, acc, callback) do
    acc =
      case :ets.lookup(table, key) do
        [] ->
          acc

        [{^key, _value} = obj] ->
          callback.(obj, acc)
      end

    do_reduce_ets_table(:ets.next(table, key), table, acc, callback)
  end

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
  Sometimes, you just need to update a whole object.
  """
  @spec update_object(:ets.table(), any(), function()) :: boolean()
  def update_object(table, key, callback) do
    list = :ets.take(table, key)
    list = Enum.map(list, callback)
    :ets.insert(table, list)
  end
end
