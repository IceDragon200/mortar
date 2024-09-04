defmodule Mortar.ZTest do
  use ExUnit.Case

  alias Mortar.Z

  describe "zip_deflate!/1 (binary)" do
    test "can deflate a binary blob" do
      assert blob = Z.zip_deflate!("Compress, this string please")
      assert "Compress, this string please" = Z.zip_inflate!(blob)
    end
  end

  describe "zip_deflate!/1 (iodata)" do
    test "can deflate a binary blob" do
      assert blob = Z.zip_deflate!("Compress, this string please", return: :iodata)
      assert is_list(blob)
      assert ["Compress, this string please"] = Z.zip_inflate!(blob, return: :iodata)
    end
  end
end
