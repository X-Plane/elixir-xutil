defmodule XUtil.Dsf do
  @moduledoc "Utilities for working with X-Plane's DSF scenery tiles"
  import Comb
  import XUtil.Math

  # These values are for Mobile; Desktop uses 3x2 or even 4x3
  @lon_degrees_loaded 2
  @lat_degrees_loaded 2

  @doc """
  The DSF for a given lon/lat.

      iex(1)> XUtil.Dsf.dsf(0.1234, 0.5678)
      {0, 0}

      iex(1)> XUtil.Dsf.dsf({179.9, 79.9})
      {179, 79}

      iex(1)> XUtil.Dsf.dsf({-179.9, -79.9})
      {-180, -80}
  """
  def dsf({lon, lat}) when is_number(lon) and is_number(lat), do: {floor(lon), floor(lat)}
  def dsf({lon, lat, _ele}) when is_number(lon) and is_number(lat), do: {floor(lon), floor(lat)}
  def dsf(%{lon: lon, lat: lat}), do: {floor(lon), floor(lat)}
  def dsf(lon, lat) when is_number(lon) and is_number(lat), do: {floor(lon), floor(lat)}

  @doc """
  The {lon_west, lat_south} 3x2 block the aircraft is currently using.
  This is necessarily one of connected_blocks() (i.e., it's among the set
  of six 3x2 DSF blocks that contain this DSF).
  Mirrors the logic in X-Plane's UTL_geoid::check_ref().
  """
  def decode_block(%{lon: lon, lat: lat}) do
    lon_w = wrap_lon(round(lon - @lon_degrees_loaded * 0.5))
    lat_s = wrap_lat(round(lat - @lat_degrees_loaded * 0.5))
    {lon_w, lat_s}
  end

  @doc """
  Returns the 3x2 DSF block indices (indexed on the lower left/southwest corner of the DSF block)
  that contain the specified DSF.

      iex(1)> XUtil.Dsf.connected_blocks(0, 0)
      [{-2, -1}, {-2, 0}, {-1, -1}, {-1, 0}, {0, -1}, {0, 0}]

      iex(1)> XUtil.Dsf.connected_blocks(12, 12)
      [{10, 11}, {10, 12}, {11, 11}, {11, 12}, {12, 11}, {12, 12}]

      # DSF lon 180 wraps to -180, and lat 90 wraps to -90 (since we index DSFs on their southwest corner)
      iex(1)> XUtil.Dsf.connected_blocks(180, 90)
      [{178, 89}, {178, -90}, {179, 89}, {179, -90}, {-180, 89}, {-180, -90}]

      # Wraps properly
      iex(1)> XUtil.Dsf.connected_blocks(-178, -88) == XUtil.Dsf.connected_blocks(182, 92)
      true
  """
  def connected_blocks(lon, lat) when is_integer(lon) and is_integer(lat) do
    raw = cartesian_product((lon - 2)..lon, (lat - 1)..lat)

    Enum.map(raw, fn lon_lat ->
      {wrap_lon(Enum.at(lon_lat, 0)), wrap_lat(Enum.at(lon_lat, 1))}
    end)
  end

  def connected_blocks({lon, lat}) when is_integer(lon) and is_integer(lat), do: connected_blocks(lon, lat)

  @doc """
  The set of DSFs at a particular (integer) offset away from your base DSF.
  Handles equatorial/international dateline wrapping.

      iex(1)> XUtil.Dsf.dsfs_at_offset({-180, -30}, 1)
      #MapSet<[{-180, -31}, {-180, -29}, {-179, -31}, {-179, -30}, {-179, -29}, {179, -31}, {179, -30}, {179, -29}]>
  """
  def dsfs_at_offset(base_dsf, offset)

  def dsfs_at_offset({lon, lat} = base_dsf, 0) when is_integer(lon) and is_integer(lat) do
    MapSet.new([base_dsf])
  end

  def dsfs_at_offset({lon, lat} = _base_dsf, offset) when is_integer(lon) and is_integer(lat) and is_integer(offset) do
    complete_range_raw = cartesian_product((lon - offset)..(lon + offset), (lat - offset)..(lat + offset))
    inner_to_remove_raw = cartesian_product((lon - offset + 1)..(lon + offset - 1), (lat - offset + 1)..(lat + offset - 1))
    inner_removed = MapSet.difference(MapSet.new(complete_range_raw), MapSet.new(inner_to_remove_raw))
    inner_removed |> Enum.map(&wrap_lon_lat/1) |> MapSet.new()
  end

  @doc """
  The weird string representation X-Plane uses for indexing DSFs.

      iex(1)> XUtil.Dsf.to_string(%{lon: -15, lat: -8})
      "-08-015"

      iex(1)> XUtil.Dsf.to_string({81, 8})
      "+08+081"

      iex(1)> XUtil.Dsf.to_string({36, -9, 12345})
      "-09+036"

      iex(1)> XUtil.Dsf.to_string({153, -24})
      "-24+153"

      iex(1)> XUtil.Dsf.to_string({0, 0})
      "+00+000"
  """
  def to_string(lon_lat_optional_ele) do
    {lon, lat} = dsf(lon_lat_optional_ele)
    "#{pad_leading(lat, 3)}#{pad_leading(lon, 4)}"
  end

  @doc """
  Parses X-Plane's weird string representation used to index dsfs into {lon, lat}

      iex(1)> XUtil.Dsf.from_string("-08-015")
      {-15, -8}

      iex(1)> XUtil.Dsf.from_string("+08+081")
      {81, 8}

      iex(1)> XUtil.Dsf.from_string("-09+036")
      {36, -9}

      iex(1)> XUtil.Dsf.from_string("+24-153")
      {-153, 24}

      iex(1)> XUtil.Dsf.from_string("+00+000")
      {0, 0}
  """
  def from_string(dsf_id) when is_binary(dsf_id) and byte_size(dsf_id) == 7 do
    {lat, ""} = dsf_id |> String.slice(0..2) |> Integer.parse()
    {lon, ""} = dsf_id |> String.slice(3..7) |> Integer.parse()
    {lon, lat}
  rescue
    _ ->
      {}
  end

  def from_string(_), do: {}

  defp pad_leading(lon_or_lat, field_width) do
    sign = if lon_or_lat >= 0, do: "+", else: "-"
    with_leading_zeros = lon_or_lat |> abs() |> Integer.to_string() |> String.pad_leading(field_width - 1, "0")
    sign <> with_leading_zeros
  end
end
