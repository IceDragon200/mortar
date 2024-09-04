defmodule Mortar.MapTest do
  use ExUnit.Case

  alias Mortar.Map, as: Subject

  describe "replace_nil/3" do
    test "can replace an implicit nil" do
      m = %{}

      assert %{a: "A"} = Subject.replace_nil(m, :a, "A")
    end

    test "can replace an explicit nil" do
      m = %{a: nil}

      assert %{a: 1} = Subject.replace_nil(m, :a, 1)
    end

    test "will not replace value if it is non-null" do
      m = %{a: "A"}

      assert %{a: "A"} = Subject.replace_nil(m, :a, 1)
    end
  end

  describe "put_non_nil/3" do
    test "can put a value as long as it's not nil" do
      m = %{}

      assert %{a: "A"} = m = Subject.put_non_nil(m, :a, "A")
      m = Subject.put_non_nil(m, :b, nil)
      assert %{a: "A"} == m
      assert %{a: "A", c: "C"} == Subject.put_non_nil(m, :c, "C")
    end
  end

  describe "invert_map_pairs/1" do
    test "inverses the mappings of the given map" do
      m = %{a: "A", b: "B", c: "C"}

      assert %{
        "A" => :a,
        "B" => :b,
        "C" => :c,
      } = Subject.invert_map_pairs(m)
    end
  end
end
