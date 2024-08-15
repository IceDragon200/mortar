defmodule Mortar.Struct do
  import Mortar.String, only: [string_to_atom: 1]

  def load_struct_from_map(module, map) do
    map =
      map
      |> Enum.map(fn {key, value} ->
        {string_to_atom(key), value}
      end)
      |> Enum.into(%{})

    struct(module, map)
  end
end
