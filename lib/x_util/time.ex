defmodule XUtil.Time do
  @moduledoc """
  Simple utilities for working with times.

  This is mostly to stop me from searching the web for "how do I get x in Elixir?".
  """

  @doc """
  The current Unix timestamp, expressed in integer milliseconds.
  Not necessarily monotonically increasing.
  """
  def unix_timestamp_ms, do: :os.system_time(:millisecond)

  @doc """
  Current system time, expressed as an ISO 8601:2004 string like "2020-10-29T23:00:07Z"
  """
  def iso8601_now, do: DateTime.to_iso8601(DateTime.utc_now())
end
