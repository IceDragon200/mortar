defmodule Mortar.ATest do
  use ExUnit.Case

  alias Mortar.A

  describe "aput_new/3" do
    test "can retrieve a value by key for a keyword list" do
      a = []
      a = A.aput_new(a, :a, 2)
      assert 2 == A.aget(a, :a)
    end

    test "can retrieve a value by key for a map" do
      a = %{}
      a = A.aput_new(a, :a, 2)
      assert 2 == A.aget(a, :a)
    end
  end

  describe "aget/2" do
    test "can retrieve a value by key for a keyword list" do
      assert 2 == A.aget([a: 2], :a)
      assert nil == A.aget([a: 2], :b)
    end

    test "can retrieve a value by key for a map" do
      assert 2 == A.aget(%{a: 2}, :a)
      assert nil == A.aget(%{a: 2}, :b)
    end
  end

  describe "asplit/2" do
    test "can split a keyword list" do
      source = [a: 2, b: 3, c: 4]
      assert {[a: 2, b: 3], [c: 4]} == A.asplit(source, [:a, :b])
    end

    test "can split a map" do
      source = %{a: 2, b: 3, c: 4}
      assert {%{a: 2, b: 3}, %{c: 4}} == A.asplit(source, [:a, :b])
    end
  end

  describe "atake/2" do
    test "can take keys from keyword list" do
      source = [a: 2, b: 3, c: 4]
      assert [a: 2, b: 3] == A.atake(source, [:a, :b])
    end

    test "can take keys from map" do
      source = %{a: 2, b: 3, c: 4}
      assert %{a: 2, b: 3} == A.atake(source, [:a, :b])
    end
  end

  describe "adrop/2" do
    test "can drop keys from keyword list" do
      source = [a: 2, b: 3, c: 4]
      assert [c: 4] == A.adrop(source, [:a, :b])
    end

    test "can drop keys from map" do
      source = %{a: 2, b: 3, c: 4}
      assert %{c: 4} == A.adrop(source, [:a, :b])
    end
  end
end
