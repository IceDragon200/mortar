defmodule Mortar.DateAndTimeTest do
  use ExUnit.Case

  alias Mortar.DateAndTime, as: Subject

  describe "maybe_to_iso8601/1" do
    test "can handle nil" do
      assert is_nil(Subject.maybe_to_iso8601(nil))
    end

    test "can handle time" do
      assert "20:45:31" == Subject.maybe_to_iso8601(~T[20:45:31])
    end

    test "can handle date" do
      assert "2024-08-16" == Subject.maybe_to_iso8601(~D[2024-08-16])
    end

    test "can handle naive datetime" do
      assert "2024-08-16T20:45:31.000000" == Subject.maybe_to_iso8601(~N[2024-08-16T20:45:31.000000])
    end

    test "can handle datetime" do
      assert "2024-08-16T20:45:31.000000Z" == Subject.maybe_to_iso8601(~U[2024-08-16T20:45:31.000000Z])
    end
  end

  describe "datetime_is_within_range?/3" do
    test "can determine if time falls within a given range" do
      assert Subject.datetime_is_within_range?(~T[12:00:00], ~T[11:00:00], ~T[13:00:00])
      assert Subject.datetime_is_within_range?(~T[13:00:00], ~T[11:00:00], ~T[13:00:00])
      assert Subject.datetime_is_within_range?(~T[11:00:00], ~T[11:00:00], ~T[13:00:00])
      refute Subject.datetime_is_within_range?(~T[10:59:59], ~T[11:00:00], ~T[13:00:00])
      refute Subject.datetime_is_within_range?(~T[13:01:00], ~T[11:00:00], ~T[13:00:00])
    end
  end
end
