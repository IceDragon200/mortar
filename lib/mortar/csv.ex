defmodule Mortar.CSV do
  def split_csv_blob(blob) when is_binary(blob) do
    blob
    |> Mortar.String.split_by_newlines(keep_newline: true)
    |> CSV.decode(headers: true)
    |> Enum.map(fn
      {:ok, row} -> row
      {:error, _} -> nil
    end)
    |> Enum.reject(&is_nil/1)
  end
end
