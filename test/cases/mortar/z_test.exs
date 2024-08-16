defmodule Mortar.ZTest do
  use ExUnit.Case

  alias Mortar.Z

  describe "zip_deflate!" do
    test "can deflate a binary blob" do
      assert blob = Z.zip_deflate!("Compress, this string please")
      assert "Compress, this string please" = Z.zip_inflate!(blob)
    end
  end
end
