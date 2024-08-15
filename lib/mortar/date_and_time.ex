defmodule Mortar.DateAndTime do
  @moduledoc """
  Provides some utility functions for working with Date, Time and DateTime.

  The module is intentionally named DateAndTime to avoid confusion with DateTime itself.
  """

  @doc """
  Sometimes you just want to convert the given date, time, or datetime to its ISO format, but you
  also don't want to deal with nil yourself at least not at the point of call.
  """
  def maybe_to_iso8601(nil) do
    nil
  end

  def maybe_to_iso8601(%Time{} = subject) do
    Time.to_iso8601(subject)
  end

  def maybe_to_iso8601(%Date{} = subject) do
    Date.to_iso8601(subject)
  end

  def maybe_to_iso8601(%DateTime{} = subject) do
    DateTime.to_iso8601(subject)
  end

  def maybe_to_iso8601(%NaiveDateTime{} = subject) do
    NaiveDateTime.to_iso8601(subject)
  end

  @type date_or_datetime :: Date.t() | DateTime.t() | NaiveDateTime.t()

  @spec datetime_is_within_range?(
    timestamp::date_or_datetime(),
    low::date_or_datetime(),
    high::date_or_datetime()
  ) :: boolean()
  def datetime_is_within_range?(%schema{} = timestamp, %schema{} = low, %schema{} = high) do
    case schema.compare(low, timestamp) do
      :gt ->
        false

      val when val in [:lt, :eq] ->
        case schema.compare(timestamp, high) do
          :gt ->
            false

          val when val in [:lt, :eq] ->
            true
        end
    end
  end
end
