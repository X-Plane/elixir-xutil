defmodule XUtil.Guards do
  @moduledoc "Custom utilities for use in guard clauses"

  @doc "Matches if the first string ends with the second. This is like matching on _ <> needle_literal"
  defguard ends_with?(haystack, needle)
           when is_bitstring(haystack) and is_bitstring(needle) and byte_size(haystack) >= byte_size(needle) and
                  binary_part(haystack, byte_size(haystack), -byte_size(needle)) == needle

  defguard is_non_empty_map?(m) when is_map(m) and m != %{}

  defguard has_lon_lat?(m) when is_map(m) and is_map_key(m, "lon") and is_map_key(m, "lat")
end
