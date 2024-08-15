defmodule Mortar.Remap do
  @type remap_field :: String.t() | atom() | {:default}

  @typedoc """
  remap key is either a string or non-nil atom, it will be used to rename a field when used as a
  value, and acts as the source field name when used as a key.

  {:default} is used to denote any missing fields, normally it would be used as {:default} => true,
  but in the case of typed maps (i.e. %{String.t() => map()}) it could be used as:

      {:default} => remap_guide

  """
  @type remap_key :: remap_field() | {:default}

  @typedoc """
  The remap value is what a field should be transformed to, if using a remap_field, it will rename
  the field, is using a boolean; when true it will keep the field name, otherwise it will drop
  the field, if using a {boolean, remap_guide} tuple, when boolean is true, it will use the sub
  remape_guide to treat the source value as a map and perform a remap_structure on it.

  Finally a {remap_field, remap_guide} can be used to change the field name AND perform a
  remap_structure on the value.
  """
  @type remap_value :: remap_field()
                     | boolean()
                     | {boolean(), remap_guide()}
                     | {remap_field(), remap_guide()}

  @typedoc """
  A remap guide is a map containing the new field names for a map or any remapping rules.
  """
  @type remap_guide :: %{
    remap_key() => remap_value()
  }

  @doc """
  Renames fields in a map, supports nesting and default

  Args:
  * `input` - the input map or nil value
  * `guide` - the guide map that will be used to transform the input
  """
  @spec remap_structure(map() | nil, remap_guide()) :: map() | nil
  def remap_structure(nil, _guide) do
    nil
  end

  def remap_structure(input, guide) when is_map(input) and is_map(guide) do
    default = Map.get(guide, {:default})

    Enum.reduce(input, %{}, fn {key, value}, acc ->
      case Map.get(guide, key, default) do
        nil ->
          acc

        false ->
          acc

        true ->
          Map.put(acc, key, value)

        name when is_binary(name) or is_atom(name) ->
          Map.put(acc, name, value)

        sub_guide when is_map(sub_guide) ->
          Map.put(acc, key, remap_structure(value, sub_guide))

        {false, _sub_guide} ->
          acc

        {true, sub_guide} ->
          Map.put(acc, key, remap_structure(value, sub_guide))

        {name, sub_guide} when is_binary(name) or is_atom(name) ->
          Map.put(acc, name, remap_structure(value, sub_guide))
      end
    end)
  end
end
