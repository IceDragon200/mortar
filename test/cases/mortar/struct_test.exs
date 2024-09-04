defmodule Mortar.StructTest do
  defmodule TestStruct do
    defstruct [
      key: nil,
      x: nil,
      y: nil,
      z: nil,
      a: nil,
    ]
  end

  use ExUnit.Case

  alias Mortar.Struct, as: Subject

  describe "load_struct_from_map/2" do
    test "can convert string keys to atoms for struct" do
      assert %TestStruct{
        key: "Value",
        x: 1,
        y: 2,
        z: 3,
        a: 4,
      } = Subject.load_struct_from_map(TestStruct, %{
        "key" => "Value",
        "x" => 1,
        "y" => 2,
        "z" => 3,
        a: 4
      })
    end
  end
end
