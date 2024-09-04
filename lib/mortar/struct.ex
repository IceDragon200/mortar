defmodule Mortar.Struct do
  import Mortar.String, only: [string_to_atom: 1]

  @spec load_struct_from_map(module(), map()) :: struct()
  def load_struct_from_map(module, map) do
    map =
      map
      |> Enum.map(fn {key, value} ->
        key =
          case key do
            key when is_binary(key) ->
              string_to_atom(key)

            key when is_atom(key) ->
              key
          end
        {key, value}
      end)
      |> Enum.into(%{})

    struct(module, map)
  end
end
