defmodule Mortar.EnumTest do
  use ExUnit.Case

  alias Mortar.Enum, as: Subject

  describe "to_map_by/2" do
    test "can create a map from a given list of values" do
      source = [
        %{
          name: "Egg",
          index: 4,
          timestamp: DateTime.utc_now(),
        },
        %{
          name: "Apple",
          index: 3,
          timestamp: DateTime.utc_now(),
        },
        %{
          name: "Bread",
          index: 2,
          timestamp: DateTime.utc_now(),
        },
        %{
          name: "Celantro",
          index: 1,
          timestamp: DateTime.utc_now(),
        }
      ]

      assert %{
        4 => %{
          name: "Egg",
          index: 4,
          timestamp: _,
        },
        3 => %{
          name: "Apple",
          index: 3,
          timestamp: _,
        },
        2 => %{
          name: "Bread",
          index: 2,
          timestamp: _,
        },
        1 => %{
          name: "Celantro",
          index: 1,
          timestamp: _,
        }
      } = Subject.to_map_by(source, & &1.index)
    end
  end

  describe "sort_by_field/3" do
    test "can handle empty lists" do
      assert [] == Subject.sort_by_field([], :name, :asc)
    end

    test "can sort a list of maps by a field with a certain order" do
      source = [
        %{
          name: "Egg",
          index: 4,
          timestamp: DateTime.utc_now(),
        },
        %{
          name: "Apple",
          index: 3,
          timestamp: DateTime.utc_now(),
        },
        %{
          name: "Bread",
          index: 2,
          timestamp: DateTime.utc_now(),
        },
        %{
          name: "Celantro",
          index: 1,
          timestamp: DateTime.utc_now(),
        }
      ]

      assert [
        %{name: "Apple", index: 3},
        %{name: "Bread", index: 2},
        %{name: "Celantro", index: 1},
        %{name: "Egg", index: 4},
      ] = Subject.sort_by_field(source, :name, :asc)

      assert [
        %{name: "Celantro", index: 1},
        %{name: "Bread", index: 2},
        %{name: "Apple", index: 3},
        %{name: "Egg", index: 4},
      ] = Subject.sort_by_field(source, :index, :asc)

      assert [
        %{name: "Egg", index: 4},
        %{name: "Celantro", index: 1},
        %{name: "Bread", index: 2},
        %{name: "Apple", index: 3},
      ] = Subject.sort_by_field(source, :name, :desc)

      assert [
        %{name: "Celantro", index: 1},
        %{name: "Bread", index: 2},
        %{name: "Apple", index: 3},
        %{name: "Egg", index: 4},
      ] = Subject.sort_by_field(source, :timestamp, :desc)
    end
  end

  describe "sort_by_fields/2" do
    test "can sort empty list" do
      assert [] == Subject.sort_by_fields([], [name: :asc])
    end

    test "can handle no sort fields" do
      assert [%{a: 2}, %{a: 3}, %{a: 1}] == Subject.sort_by_fields([%{a: 2}, %{a: 3}, %{a: 1}], [])
    end

    test "can sort records by multiple fields" do
      source = [
        %{name: "Apple", i: 7},
        %{name: "Banana", i: 7},
        %{name: "Apple", i: 4},
        %{name: "Banana", i: 9},
      ]

      assert [
        %{name: "Apple", i: 4},
        %{name: "Apple", i: 7},
        %{name: "Banana", i: 7},
        %{name: "Banana", i: 9},
      ] == Subject.sort_by_fields(source, [name: :asc, i: :asc])
    end
  end
end
