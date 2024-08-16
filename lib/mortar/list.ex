defmodule Mortar.List do
  def presence([]) do
    nil
  end

  def presence([_ | _] = list) do
    list
  end
end
