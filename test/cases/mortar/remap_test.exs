defmodule Mortar.RemapTest do
  use ExUnit.Case

  alias Mortar.Remap, as: Subject

  describe "remap_structure/2" do
    test "can remap a given map by guide" do
      input = %{
        "null_key" => "HIDE_ME_TOO",
        "omit_me" => "HIDE_ME",
        "a-key" => "data",
        "b_something" => %{
          "fld_list" => [
            %{
              "b-key" => "data2",
              "c-key" => "data3"
            }
          ]
        },
        "c_sub" => %{
          "x" => 1,
          "y" => 2,
          "z" => 3,
        },
        "obj" => %{
          "metadata" => %{
            "comment" => "STUFF",
          },
          "pos1" => %{
            "x" => 1,
            "y" => 2,
            "z" => 3,
          },
          "pos2" => %{
            "x" => 12,
            "y" => 22,
            "z" => 32,
          }
        }
      }

      guide = %{
        "null_key" => nil,
        "omit_me" => false,
        "a-key" => :a_key,
        "b_something" => {:b_something, %{
          "fld_list" => true,
        }},
        "c_sub" => {:c_sub, %{
          "x" => :x,
          "y" => :y,
          "z" => :z,
        }},
        "obj" => {:obj, %{
          "metadata" => {false, %{
            "comment" => true,
          }},
          "pos1" => {true, %{
            "x" => :x,
            "y" => :y,
            "z" => :z,
          }},
          "pos2" => %{
            "x" => :x,
            "y" => :y,
            "z" => :z,
          },
        }},
      }

      assert %{
        a_key: "data",
        b_something: %{
          "fld_list" => [
            %{
              "b-key" => "data2",
              "c-key" => "data3"
            }
          ]
        },
        c_sub: %{
          x: 1,
          y: 2,
          z: 3
        },
        obj: %{
          "pos1" => %{
            x: 1,
            y: 2,
            z: 3,
          },
          "pos2" => %{
            x: 12,
            y: 22,
            z: 32,
          }
        }
      } == Subject.remap_structure(input, guide)
    end

    test "can handle a nil input" do
      assert is_nil(Subject.remap_structure(nil, %{}))
    end
  end
end
