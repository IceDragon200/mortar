defmodule Mortar.List do
  @spec presence(list()) :: nil | list()
  def presence([]) do
    nil
  end

  def presence([_ | _] = list) do
    list
  end
end
