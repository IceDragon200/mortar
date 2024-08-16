defmodule Mortar.Enum do
  @type order :: :asc | :desc

  @type field_and_order :: {field::any(), order()}

  @spec to_map_by(Enumerable.t(), (any -> key::any())) :: map()
  def to_map_by(enumerable, callback) do
    Enum.reduce(enumerable, %{}, fn item, acc ->
      Map.put(acc, callback.(item), item)
    end)
  end

  @spec sort_by_field([map()], atom(), :asc | :desc) :: [map()]
  def sort_by_field([] = items, _field, _order) do
    items
  end

  def sort_by_field(items, field, order) when order in [:asc, :desc] do
    schema =
      Enum.reduce_while(items, nil, fn item, acc ->
        case Map.fetch!(item, field) do
          %s{} ->
            {:halt, s}

          nil ->
            {:cont, acc}

          _ ->
            {:halt, acc}
        end
      end)

    case schema do
      nil ->
        Enum.sort_by(items, &Map.fetch!(&1, field), order)

      schema ->
        Enum.sort_by(items, &Map.fetch!(&1, field), {order, schema})
    end
  end

  @doc """
  Sort given records by the specified fields and order.
  """
  @spec sort_by_fields([map()], [field_and_order()]) :: [map()]
  def sort_by_fields([] = items, _list) do
    items
  end

  def sort_by_fields(items, []) do
    items
  end

  def sort_by_fields(items, fields_and_order) when is_list(fields_and_order) do
    [{field, order} | rest] = fields_and_order

    schema =
      Enum.reduce_while(items, nil, fn item, acc ->
        case Map.fetch!(item, field) do
          %s{} ->
            {:halt, s}

          nil ->
            {:cont, acc}

          _ ->
            {:halt, acc}
        end
      end)

    items = Enum.group_by(items, &Map.fetch!(&1, field))
    sorter = fn {_key, [item | _items]} ->
      Map.fetch!(item, field)
    end
    items =
      case schema do
        nil ->
          Enum.sort_by(items, sorter, order)

        schema ->
          Enum.sort_by(items, sorter, {order, schema})
      end

    Enum.flat_map(items, fn {_, items} ->
      sort_by_fields(items, rest)
    end)
  end
end
