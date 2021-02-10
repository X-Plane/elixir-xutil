defmodule XUtil.Math do
  @moduledoc "Various mathematical helpers; corresponds to X-Plane's hl_math.h"

  def reinterpolate(input, from_bits, to_bits)
      when is_integer(input) and input >= 0 and is_integer(from_bits) and is_integer(to_bits) do
    from_max = floor(:math.pow(2, from_bits)) - 1
    to_max = floor(:math.pow(2, to_bits)) - 1
    round(input * to_max / from_max)
  end

  def quantized_int_to_float(input, from_bits, out_min, out_max)
      when is_integer(input) and input >= 0 and is_integer(from_bits) and out_min < out_max do
    from_max = floor(:math.pow(2, from_bits)) - 1
    limit(out_min + input * (out_max - out_min) / from_max, out_min, out_max)
  end

  def quantize_float(val, in_min, in_max, to_bits) when is_number(val) and in_min < in_max and is_integer(to_bits) do
    to_max = floor(:math.pow(2, to_bits)) - 1
    round(to_max / (in_max - in_min) * (val - in_min))
  end

  def limit(input, min_val, max_val) when is_number(input) and min_val < max_val do
    input
    |> min(max_val)
    |> max(min_val)
  end

  @doc """
  Wraps the input in the specified range, primarily useful for degree measurements.
  wrap_lon() and wrap_lat() are implemented in terms of this.

      iex(1)> XUtil.Math.wrap(-180.0, -180, 180)
      -180.0

      iex(1)> XUtil.Math.wrap(-180.1, -180, 180) |> Float.round(1)
      179.9

      iex(1)> XUtil.Math.wrap(179.9, -180, 180) |> Float.round(1)
      179.9

      iex(1)> XUtil.Math.wrap(180, -180, 180)
      -180

      iex(1)> XUtil.Math.wrap(181, -180, 180)
      -179

      iex(1)> XUtil.Math.wrap(-181, -180, 180)
      179
  """
  def wrap(input, min, max) when is_integer(input) and is_integer(min) and is_integer(max) and min < max do
    range_size = max - min
    remainder = rem(input - min, range_size)
    if remainder < 0, do: max + remainder, else: min + remainder
  end

  def wrap(input, min, max) when is_float(input) and is_number(min) and is_number(max) and min < max do
    min + fmod_positive(input - min, max - min)
  end

  @doc "An implementation of C's fmod() --- modular division on floating point values"
  def fmod(input, max) when is_float(input) do
    input - max * trunc(input / max)
  end

  @doc "Like fmod, but returns a positive (wrapped) remainder when C's fmod() would return a negative"
  def fmod_positive(input, max) when is_float(input) do
    input - max * floor(input / max)
  end

  def nearly_equal(f1, f2, tolerance \\ 0.000001) do
    abs(f1 - f2) <= tolerance
  end

  def pythagorean_distance({x1, y1}, {x2, y2}) do
    dx = x1 - x2
    dy = y1 - y2
    :math.sqrt(dx * dx + dy * dy)
  end

  def pythagorean_distance(%{lon: x1, lat: y1}, %{lon: x2, lat: y2}) do
    dx = x1 - x2
    dy = y1 - y2
    :math.sqrt(dx * dx + dy * dy)
  end

  def pythagorean_distance(p, q, r), do: :math.sqrt(p * p + q * q + r * r)

  def meters_sec_to_knots(speed_msc), do: speed_msc * 1.9438445

  def meters_to_feet(meters), do: meters * 3.2808399
  def feet_to_meters(feet), do: feet / 3.2808399

  @pi 3.14159265359
  @pi_over_180 3.14159265359 / 180.0
  @mean_earth_radius_meters 6_371_008.8

  @doc """
  The great-circle distance between the two aircraft locations, in meters
  See: https://en.wikipedia.org/wiki/Great-circle_distance
  We're using the Haversine formula for better accuracy at short distances: https://en.wikipedia.org/wiki/Haversine_formula
  """
  def great_circle(%{lon: lon1, lat: lat1}, %{lon: lon2, lat: lat2}), do: great_circle({lon1, lat1}, {lon2, lat2})

  def great_circle({lon1, lat1}, {lon2, lat2}) do
    a = :math.sin((lat2 - lat1) * @pi_over_180 / 2)
    b = :math.sin((lon2 - lon1) * @pi_over_180 / 2)

    s = a * a + b * b * :math.cos(lat1 * @pi_over_180) * :math.cos(lat2 * @pi_over_180)
    2 * :math.atan2(:math.sqrt(s), :math.sqrt(1 - s)) * @mean_earth_radius_meters
  end

  @doc """
  The bearing, in degrees, from the first lon/lat to the second
  https://stackoverflow.com/a/3209935/1417451
  """
  def bearing_deg({lon1, lat1}, {lon2, lat2}) do
    lon1_rad = lon1 * @pi_over_180
    lat1_rad = lat1 * @pi_over_180
    lon2_rad = lon2 * @pi_over_180
    lat2_rad = lat2 * @pi_over_180

    y = :math.sin(lon2_rad - lon1_rad) * :math.cos(lat2_rad)
    x = :math.cos(lat1_rad) * :math.sin(lat2_rad) - :math.sin(lat1_rad) * :math.cos(lat2_rad) * :math.cos(lon2_rad - lon1_rad)
    theta = :math.atan2(y, x)
    fmod(theta * 180 / @pi + 360, 360.0)
  end

  # International nm is defined as exactly 1852 meters: https://en.wikipedia.org/wiki/Nautical_mile
  def meters_to_nautical_miles(meters), do: meters / 1852

  def mean_lon_lat({lon0, lat0}, {lon1, lat1}) do
    {(lon0 + lon1) * 0.5, (lat0 + lat1) * 0.5}
  end

  @doc "Wraps -180 -> -180; 179 -> 179; 180 -> -180"
  def wrap_lon(lon), do: wrap(lon, -180, 180)
  def wrap_lat(lat), do: wrap(lat, -90, 90)
  def wrap_lon_lat(lon, lat), do: {wrap_lon(lon), wrap_lat(lat)}
  def wrap_lon_lat({lon, lat}), do: {wrap_lon(lon), wrap_lat(lat)}
  def wrap_lon_lat([lon | [lat]]), do: {wrap_lon(lon), wrap_lat(lat)}
end
