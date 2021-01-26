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

  @doc """
  Transforms a Unix timestamp, in milliseconds, into a string like "2021-01-25T18:24:03Z"

  Examples:
  iex(1)> XUtil.Time.timestamp_to_iso8601(1_596_739_626_078)
  "2020-08-06T18:47:06.078Z"
  iex(2)> XUtil.Time.timestamp_to_iso8601(-377_705_116_700_000)
  "-9999-01-01T00:01:40.000Z"
  iex(3)> XUtil.Time.timestamp_to_iso8601(253_402_300_798_999)
  "9999-12-31T23:59:58.999Z"
  """
  def timestamp_to_iso8601(unix_timestamp)
       when is_integer(unix_timestamp) and unix_timestamp > -377_705_116_800_000 and unix_timestamp < 253_402_300_799_000 do
    unix_timestamp |> DateTime.from_unix!(:millisecond) |> DateTime.to_iso8601()
  end
end
