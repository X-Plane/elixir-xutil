defmodule XUtil.Map do
  @moduledoc """
  Syntactic sugar for working with maps.
  """

  @doc """
  Returns a function to grab the value associated with key from your map (probably a struct).
  Useful for composing with Enum algorithms.
  Examples:

      iex(1)> [%{a: 2, b: 1}, %{a: 3, b: 2}, %{a: 1, b: 3}] |> Enum.sort_by(XUtil.Map.select_key(:a))
      [%{a: 1, b: 3}, %{a: 2, b: 1}, %{a: 3, b: 2}]

      iex(1)> [%{a: 2, b: 1}, %{a: 3, b: 2}, %{a: 1, b: 3}] |> Enum.map(XUtil.Map.select_key(:a))
      [2, 3, 1]
  """
  def select_key(key) when is_atom(key) do
    &Map.fetch!(&1, key)
  end

  @doc """
  Returns a function to compare the value associated with a key in your map (probably a struct).
  Useful for composing with Enum algorithms.
  Examples:

      iex(1)> [%{a: 1, b: 3}, %{a: 3, b: 1}, %{a: 3, b: 2}] |> Enum.filter(XUtil.Map.key_equals(:a, 3))
      [%{a: 3, b: 1}, %{a: 3, b: 2}]
  """
  def key_equals(key, sought_val) when is_atom(key) do
    &(Map.fetch!(&1, key) == sought_val)
  end

  @doc """
  Gives your updater a chance to modify each value in the map, leaving keys untouched.
  Examples:

      iex(1)> XUtil.Map.transform_values(%{a: 1, b: 2, c: 3, d: 4}, &(&1 * &1))
      %{a: 1, b: 4, c: 9, d: 16}

      iex(1)> XUtil.Map.transform_values(%{a: 1, b: 2, c: 3, d: 4}, &Integer.to_string/1)
      %{a: "1", b: "2", c: "3", d: "4"}
  """
  def transform_values(%{} = m, updater) when is_function(updater) do
    Map.new(m, fn {k, v} -> {k, updater.(v)} end)
  end

  @doc """
  Gives your updater a chance to modify each key in the map, leaving their associated values untouched.
  Duplicated keys are removed; the latest one prevails.
  Examples:

      iex(1)> XUtil.Map.transform_keys(%{"a" => 1, "b" => 2, "c" => 3}, &String.to_atom/1)
      %{a: 1, b: 2, c: 3}

      iex(1)> XUtil.Map.transform_keys(%{"a" => 1, "b" => 2, "c" => 3}, fn _ -> "foo" end)
      %{"foo" => 3}
  """
  def transform_keys(%{} = m, updater) when is_function(updater) do
    Map.new(m, fn {k, v} -> {updater.(k), v} end)
  end

  @doc """
  Filter based on the {key, value} pairs in the map.
  Returns a new map with only the key-value pairs your filterer returned true for.
  Examples:

      iex(1)> XUtil.Map.filter(%{a: 1, b: 2, c: 3, d: 4}, fn {_k, v} -> rem(v, 2) == 0 end)
      %{b: 2, d: 4}

      iex(1)> XUtil.Map.filter(%{a: 1, b: 2, c: 3, d: 4}, fn {k, _v} -> k == :a or k == :b end)
      %{a: 1, b: 2}
  """
  def filter(%{} = m, filterer) when is_function(filterer) do
    m
    |> Enum.filter(filterer)
    |> Map.new()
  end

  @doc """
  Filter based solely on the values. Your filterer looks at the values and
  returns false to remove the key-value entry from the resulting map.
  Examples:

      iex(1)> XUtil.Map.filter_values(%{a: 1, b: 2, c: 3, d: 4}, fn v -> rem(v, 2) == 0 end)
      %{b: 2, d: 4}
  """
  def filter_values(%{} = m, filterer) when is_function(filterer) do
    filter(m, fn {_key, val} -> filterer.(val) end)
  end

  @doc """
  Filter based solely on the keys. Your filterer looks at the keys and
  returns false to remove the key-value entry from the resulting map.
  Examples:

      iex(1)> XUtil.Map.filter_keys(%{a: 1, b: 2, c: 3, d: 4}, fn k -> k == :a or k == :b end)
      %{a: 1, b: 2}
  """
  def filter_keys(%{} = m, filterer) when is_function(filterer) do
    filter(m, fn {key, _val} -> filterer.(key) end)
  end

  @doc """
  Opposite of filter. Reject (drop from the resulting map) any key-value pairs
  for which your rejecter returns true.
  Examples:

      iex(1)> XUtil.Map.reject(%{a: 1, b: 2, c: 3, d: 4}, fn {_k, v} -> rem(v, 2) == 0 end)
      %{a: 1, c: 3}

      iex(1)> XUtil.Map.reject(%{a: 1, b: 2, c: 3, d: 4}, fn {k, _v} -> k == :a or k == :b end)
      %{c: 3, d: 4}
  """
  def reject(%{} = m, rejecter) when is_function(rejecter) do
    m
    |> Enum.reject(rejecter)
    |> Map.new()
  end

  @doc """
  Reject based solely on the values.
  Examples:

      iex(1)> XUtil.Map.reject_values(%{a: 1, b: 2, c: 3, d: 4}, fn v -> rem(v, 2) == 0 end)
      %{a: 1, c: 3}
  """
  def reject_values(%{} = m, rejecter) when is_function(rejecter) do
    reject(m, fn {_key, val} -> rejecter.(val) end)
  end

  @doc """
  Reject based solely on keys.
  Examples:

      iex(1)> XUtil.Map.reject_keys(%{a: 1, b: 2, c: 3, d: 4}, fn k -> k == :a or k == :b end)
      %{c: 3, d: 4}
  """
  def reject_keys(%{} = m, rejecter) when is_function(rejecter) do
    reject(m, fn {key, _val} -> rejecter.(key) end)
  end

  @doc "nil if the value doesn't exist at all in the map, otherwise the key for the first matching value we find"
  def key_for_value(%{} = m, val) do
    case Enum.find(m, fn {_k, v} -> v == val end) do
      {k, _wv} -> k
      _ -> nil
    end
  end
end
