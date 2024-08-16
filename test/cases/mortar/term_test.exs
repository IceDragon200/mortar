defmodule Mortar.TermTest do
  use ExUnit.Case

  alias Mortar.Term, as: Subject

  describe "presence/1" do
    test "can return nil of various \"blank\" values" do
      assert is_nil(Subject.presence(nil))
      assert is_nil(Subject.presence(""))
      assert is_nil(Subject.presence("    "))
      assert is_nil(Subject.presence([]))
      assert is_nil(Subject.presence(%{}))
    end

    test "can return values for various non-blank values" do
      assert 0 == Subject.presence(0)
      assert false == Subject.presence(false)
      assert true == Subject.presence(true)
      assert "A" == Subject.presence("A")
      # even though the element is nil, the list is still "present" has it has elements
      assert [nil] == Subject.presence([nil])
      assert [""] == Subject.presence([""])
      assert %{nil => nil} == Subject.presence(%{nil => nil})
      assert %{nil => 0} == Subject.presence(%{nil => 0})
      assert %{a: 0} == Subject.presence(%{a: 0})
    end
  end

  describe "is_present?/1" do
    test "will report false of non-present values" do
      refute Subject.is_present?(nil)
      refute Subject.is_present?("")
      refute Subject.is_present?("    ")
      refute Subject.is_present?([])
      refute Subject.is_present?(%{})
    end

    test "will report true of present values" do
      assert Subject.is_present?(0)
      assert Subject.is_present?(true)
      assert Subject.is_present?(false)
      assert Subject.is_present?("A")
      # even though the element is nil, the list is still "present" has it has elements
      assert Subject.is_present?([nil])
      assert Subject.is_present?([""])
      assert Subject.is_present?(%{nil => nil})
      assert Subject.is_present?(%{nil => 0})
      assert Subject.is_present?(%{a: 0})
    end
  end

  describe "is_blank?/1" do
    test "will report true for non-present values" do
      assert Subject.is_blank?(nil)
      assert Subject.is_blank?("")
      assert Subject.is_blank?("    ")
      assert Subject.is_blank?([])
      assert Subject.is_blank?(%{})
    end

    test "will report false of present values" do
      refute Subject.is_blank?(0)
      refute Subject.is_blank?(true)
      refute Subject.is_blank?(false)
      refute Subject.is_blank?("A")
      # even though the element is nil, the list is still "present" has it has elements
      refute Subject.is_blank?([nil])
      refute Subject.is_blank?([""])
      refute Subject.is_blank?(%{nil => nil})
      refute Subject.is_blank?(%{nil => 0})
      refute Subject.is_blank?(%{a: 0})
    end
  end
end
