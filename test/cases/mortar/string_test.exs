defmodule Mortar.StringTest do
  use ExUnit.Case

  alias Mortar.String, as: Subject

  describe "split_upto_newline/1" do
    test "can split a string without newlines" do
      assert ["ABC"] == Subject.split_upto_newline("ABC")
    end

    test "can split a string with a newline" do
      assert ["ABC", "\nDEF"] == Subject.split_upto_newline("ABC\nDEF")
      assert ["ABC", "\r\nDEF"] == Subject.split_upto_newline("ABC\r\nDEF")
    end

    test "can split a string with multiple newlines" do
      assert ["ABC", "\r\nDEF\r\nGHJ"] == Subject.split_upto_newline("ABC\r\nDEF\r\nGHJ")
    end
  end

  describe "split_by_newlines/1" do
    test "can split a string by various newline sequences" do
      assert ["ABC", "DEF", "GHJ", "IJK"] == Subject.split_by_newlines("ABC\nDEF\rGHJ\r\nIJK")
      assert ["ABC\n", "DEF\r", "GHJ\r\n", "IJK"] == Subject.split_by_newlines("ABC\nDEF\rGHJ\r\nIJK", keep_newline: true)
    end
  end

  describe "split_leading_spaces/1" do
    test "can correctly split an empty string" do
      assert {"", ""} == Subject.split_leading_spaces("")
    end

    test "can correctly split a string with no leading space" do
      assert {"", "Hello, World"} == Subject.split_leading_spaces("Hello, World")
    end

    test "splits as much leading space" do
      assert {"    ", "after the space    "} = Subject.split_leading_spaces("    after the space    ")
    end
  end

  describe "truncate_spaces/1" do
    test "can handle a string without spaces" do
      assert "ABC,DEF" == Subject.truncate_spaces("ABC,DEF")
    end

    test "can handle a string with only spaces" do
      assert "" == Subject.truncate_spaces("          ")
    end

    test "can handle a string with only spaces and newlines" do
      assert "" == Subject.truncate_spaces("\n")
      assert "" == Subject.truncate_spaces("   \r   ")
      assert "" == Subject.truncate_spaces("\r\n")
      assert "" == Subject.truncate_spaces("\r\n   \r\n")
    end

    test "all leading spaces will be trimmed" do
      assert "Word" == Subject.truncate_spaces("   Word")
    end

    test "all tailing spaces will be trimmed" do
      assert "Word" == Subject.truncate_spaces("Word   ")
    end

    test "all excess spaces between words will be truncated" do
      assert "These are words and lines" == Subject.truncate_spaces(
        "These   are\nwords\r\nand           lines"
      )
    end
  end

  describe "presence/1" do
    test "will return nil for empty strings" do
      assert is_nil(Subject.presence(""))
      assert is_nil(Subject.presence("    "))
      assert is_nil(Subject.presence("\r\n"))
      assert is_nil(Subject.presence("   \n"))
    end

    test "will return string is it contains any non-spaces or non-newlines" do
      assert "Hello, World" == Subject.presence("Hello, World")
      assert "    Space!" == Subject.presence("    Space!")
    end
  end

  describe "is_all_numeric?/1" do
    test "determines if a string only contains numbers" do
      refute Subject.is_all_numeric?("")
      assert Subject.is_all_numeric?("123")
      refute Subject.is_all_numeric?("1a23")
    end
  end

  describe "is_all_alpha?/1" do
    test "determines if a string only contains numbers" do
      refute Subject.is_all_alpha?("")
      assert Subject.is_all_alpha?("abc")
      refute Subject.is_all_alpha?("a1bc")
    end
  end

  describe "is_all_alpha_numeric?/1" do
    test "determines if a string only contains numbers" do
      refute Subject.is_all_alpha_numeric?("")
      assert Subject.is_all_alpha_numeric?("abc")
      assert Subject.is_all_alpha_numeric?("a1bc")
    end
  end

  describe "normalize_alpha_numeric/1" do
    test "can normalize an empty string" do
      assert "" == Subject.normalize_alpha_numeric("")
    end

    test "can normalize an alpha-numeric string" do
      assert "ABC2" == Subject.normalize_alpha_numeric("  ABC_2")
    end
  end

  describe "normalize_numeric/1" do
    test "can normalize an empty string" do
      assert "" == Subject.normalize_numeric("")
    end

    test "can normalize an alpha-numeric string" do
      assert "2" == Subject.normalize_numeric("  ABC_2")
    end
  end

  describe "normalize_alpha/1" do
    test "can normalize an empty string" do
      assert "" == Subject.normalize_alpha("")
    end

    test "can normalize an alpha-numeric string" do
      assert "ABC" == Subject.normalize_alpha("  ABC_2")
    end
  end

  describe "tn_mnemonic_to_string/1" do
    test "can convert a telephone mnemonic to a phone number" do
      assert "667827 542" == Subject.tn_mnemonic_to_string("MORTAR LIB")
    end
  end

  describe "identify_casing/1" do
    test "will report none for empty string" do
      assert :none == Subject.identify_casing("")
    end

    test "can identify the intended casing of an alpha-string" do
      assert :downcase == Subject.identify_casing("abcdef")
      assert :upcase == Subject.identify_casing("ABCDEF")
    end

    test "can identify a mixed case string" do
      assert :mixed == Subject.identify_casing("Abcdef")
    end
  end

  describe "stream_binary_lines/1" do
    test "can stream a binary line by line" do
      blob = """
      1,2,3
      4,5,6
      7,8,9
      """

      result =
        Subject.stream_binary_lines(blob)
        |> Enum.into([])

      assert [
        "1,2,3",
        "4,5,6",
        "7,8,9",
      ] == result
    end
  end
end
