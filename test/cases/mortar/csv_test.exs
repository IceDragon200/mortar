defmodule Mortar.CSVTest do
  use ExUnit.Case

  alias Mortar.CSV, as: Subject

  describe "split_csv_blob/1" do
    test "can split a blob" do
      rows =
        Subject.split_csv_blob("""
        a,b,c
        1,2,3
        4,5,6
        7,8,9
        """)

      assert [
        %{
          "a" => "1",
          "b" => "2",
          "c" => "3",
        },
        %{
          "a" => "4",
          "b" => "5",
          "c" => "6",
        },
        %{
          "a" => "7",
          "b" => "8",
          "c" => "9",
        }
      ] == rows
    end
  end
end
