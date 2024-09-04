defmodule Mortar.RandomTest do
  use ExUnit.Case

  alias Mortar.Random, as: Subject

  describe "generate_random_digits/1" do
    test "can generate a string with a random digit" do
      assert <<c::utf8>> = Subject.generate_random_digits(1)
      assert c >= ?0 and c <= ?9
    end

    test "can generate a string with random digits" do
      assert str = Subject.generate_random_digits(10)

      assert Mortar.String.is_all_numeric?(str)
    end

    test "can handle zero as the length" do
      assert "" == Subject.generate_random_digits(0)
    end
  end

  describe "generate_random_base16/1" do
    test "can generate a string with a single base16 character" do
      assert <<c::utf8>> = Subject.generate_random_base16(1)
      assert is_base16_char?(c)
    end

    test "can generate a string with base16" do
      assert str = Subject.generate_random_base16(32)
      Enum.each(String.codepoints(str), fn <<c::utf8>> ->
        assert is_base16_char?(c)
      end)
    end

    test "can handle zero as the length" do
      assert "" == Subject.generate_random_base16(0)
    end
  end

  describe "generate_random_base32/1" do
    test "can generate a string with a single base32 character" do
      assert <<c::utf8>> = Subject.generate_random_base32(1)
      assert is_base32_char?(c)
    end

    test "can generate a string with base32" do
      assert str = Subject.generate_random_base32(32)
      Enum.each(String.codepoints(str), fn <<c::utf8>> ->
        assert is_base32_char?(c)
      end)
    end

    test "can handle zero as the length" do
      assert "" == Subject.generate_random_base32(0)
    end
  end

  describe "generate_random_base64/1" do
    test "can generate a string with a single base64 character" do
      assert <<c::utf8>> = Subject.generate_random_base64(1)
      assert is_base64_char?(c)
    end

    test "can generate a string with base64" do
      assert str = Subject.generate_random_base64(32)
      Enum.each(String.codepoints(str), fn <<c::utf8>> ->
        assert is_base64_char?(c)
      end)
    end

    test "can handle zero as the length" do
      assert "" == Subject.generate_random_base64(0)
    end
  end

  defp is_base16_char?(c) when is_integer(c) do
    (c >= ?0 and c <= ?9) or (c >= ?A and c <= ?F)
  end

  defp is_base32_char?(c) when is_integer(c) do
    (c >= ?0 and c <= ?9) or (c >= ?A and c <= ?Z)
  end

  defp is_base64_char?(c) when is_integer(c) do
    (c >= ?0 and c <= ?9) or
    (c >= ?A and c <= ?Z) or
    (c >= ?a and c <= ?z) or
    c == ?= or
    c == ?_ or
    c == ?- or
    c == ?/
  end
end
