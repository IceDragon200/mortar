defmodule Mortar.ETSTest do
  use ExUnit.Case

  alias Mortar.ETS, as: Subject

  describe "safe_reduce_ets_table/3" do
    test "can reduce an empty ets table" do
      table = :ets.new(:test, [:private, :set])

      assert 0 == Subject.safe_reduce_ets_table(table, 0, fn _obj, acc ->
        acc + 1
      end)
    end

    test "can reduce a table with objects" do
      table = :ets.new(:test, [:private, :set])

      true = :ets.insert(table, {:a, 1})
      true = :ets.insert(table, {:b, 2, "B"})
      true = :ets.insert(table, {:c, 3, "C", []})

      assert 3 == Subject.safe_reduce_ets_table(table, 0, fn _obj, acc ->
        acc + 1
      end)
    end
  end

  describe "reduce_ets_table/3" do
    test "can reduce an empty ets table" do
      table = :ets.new(:test, [:private, :set])

      assert 0 == Subject.reduce_ets_table(table, 0, fn _obj, acc ->
        acc + 1
      end)
    end

    test "can reduce a table with objects" do
      table = :ets.new(:test, [:private, :set])

      true = :ets.insert(table, {:a, 1})
      true = :ets.insert(table, {:b, 2, "B"})
      true = :ets.insert(table, {:c, 3, "C", []})

      assert 3 == Subject.reduce_ets_table(table, 0, fn _obj, acc ->
        acc + 1
      end)
    end
  end

  describe "safe_reduce_ets_table_while/3" do
    test "can reduce an empty ets table" do
      table = :ets.new(:test, [:private, :set])

      assert 0 == Subject.safe_reduce_ets_table_while(table, 0, fn _obj, acc ->
        {:cont, acc + 1}
      end)
    end

    test "can reduce a duplicate_bag table" do
      table = :ets.new(:test, [:private, :duplicate_bag])

      true = :ets.insert(table, {:a, 1})
      true = :ets.insert(table, {:a, 2})
      true = :ets.insert(table, {:a, 3})
      true = :ets.insert(table, {:a, 4})
      true = :ets.insert(table, {:a, 5})

      assert 3 == Subject.safe_reduce_ets_table_while(table, 0, fn obj, acc ->
        case obj do
          {:a, v} when v > 3 ->
            {:halt, acc}

          {:a, v} when v < 4 ->
            {:cont, acc + 1}
        end
      end)
    end
  end

  describe "insert_new/2" do
    test "can insert new object if key doesn't already exist" do
      table = :ets.new(:test, [:private, :set])

      assert true == Subject.insert_new(table, {:a, 2})
      assert false == Subject.insert_new(table, {:a, 3})

      assert [{:a, 2}] == :ets.lookup(table, :a)
    end
  end

  describe "insert_new_lazy/3" do
    test "can insert an object" do
      table = :ets.new(:test, [:private, :set])

      assert true == Subject.insert_new_lazy(table, :a, fn key ->
        {key, 2}
      end)
      assert false == Subject.insert_new_lazy(table, :a, fn :a ->
        {:a, 3}
      end)

      assert [{:a, 2}] == :ets.lookup(table, :a)
    end
  end

  describe "map_objects/3" do
    test "can map over objects in set ets table by key" do
      table = :ets.new(:test, [:private, :set])

      true = :ets.insert(table, {:a, 2})
      true = :ets.insert(table, {:b, 3})
      true = :ets.insert(table, {:d, 4})

      Subject.map_objects(table, :a, fn {:a, 2} = obj ->
        obj
      end)

      assert [{:a, 2}] = :ets.lookup(table, :a)

      Subject.map_objects(table, :b, fn {:b, 3} ->
        {:b, 22}
      end)

      assert [{:b, 22}] = :ets.lookup(table, :b)

      Subject.map_objects(table, :d, fn {:d, 4} ->
        {:c, 4}
      end)

      assert [] = :ets.lookup(table, :d)
      assert [{:c, 4}] = :ets.lookup(table, :c)
    end
  end

  describe "update_objects_with_default/3" do
    test "can update an object given a callback" do
      table = :ets.new(:test, [:private, :set])

      assert true == Subject.update_objects_with_default(table, :a, {:a, 2}, fn {:a, 2} = obj ->
        obj
      end)
      assert true == Subject.update_objects_with_default(table, :a, {:a, 3}, fn {:a, 2} ->
        {:a, 4}
      end)

      assert [{:a, 4}] == :ets.lookup(table, :a)
    end
  end
end
