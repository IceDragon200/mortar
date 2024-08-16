defmodule Mortar.CSV do
  @doc """
  Utility function for splitting a CSV blob into multiple lines.

  This function should not be used
  """
  @spec split_csv_blob(binary()) :: [map()]
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
