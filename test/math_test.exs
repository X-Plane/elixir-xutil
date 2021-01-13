defmodule XUtil.MathTest do
  use ExUnit.Case, async: true
  doctest XUtil.Math
  alias XUtil.Math

  test "reinterpolates between bit sizes" do
    assert Math.reinterpolate(0, 10, 20) == 0
    assert Math.reinterpolate(0, 20, 10) == 0

    assert Math.reinterpolate(255, 8, 10) == 1023
    assert Math.reinterpolate(255, 8, 4) == 15

    assert Math.reinterpolate(127, 8, 4) == 7

    # Tyler notes: this is imperfect, but it's probably the best we can do (this is the expected error for linear interp).
    # Compare with: https://www.johndcook.com/interpolator.html
    assert Math.reinterpolate(127, 8, 10) == 509
    assert Math.reinterpolate(128, 8, 10) == 514

    assert Math.reinterpolate(127, 10, 12) == 508
    assert Math.reinterpolate(900, 10, 12) == 3603
    assert Math.reinterpolate(900, 10, 8) == 224
  end

  test "transforms quantized ints to floats" do
    assert Math.quantized_int_to_float(0, 10, -512, 511) == -512
    assert Math.quantized_int_to_float(511, 10, -512, 511) == -1
    assert Math.quantized_int_to_float(1023, 10, -512, 511) == 511

    assert Math.quantized_int_to_float(0, 10, 0, 1) == 0
    assert Math.quantized_int_to_float(1023, 10, 0, 1) == 1
    assert Math.nearly_equal(Math.quantized_int_to_float(100, 10, 0, 1), 0.097751711)
    assert Math.nearly_equal(Math.quantized_int_to_float(100, 10, -1, 1), -0.804496579)
  end

  test "quantizes float from ints" do
    assert Math.quantize_float(0, 0, 1, 10) == 0
    assert Math.quantize_float(1, 0, 1, 10) == 1023
    assert Math.quantize_float(0.5, 0, 1, 10) == 512
    assert Math.quantize_float(0.4999, 0, 1, 10) == 511

    assert Math.quantize_float(-1000, -1000, 0, 10) == 0
    assert Math.quantize_float(-501, -1000, 0, 10) == 510
    assert Math.quantize_float(-500, -1000, 0, 10) == 511
  end

  @tag slow_when_interpreted: true
  test "round-trips quantization" do
    for i <- 0..1023 do
      float_representation = Math.quantized_int_to_float(i, 10, -1000, 1000)
      assert Math.quantize_float(float_representation, -1000, 1000, 10) == i
    end
  end

  test "wraps ints" do
    assert Math.wrap(9, -10, 10) == 9
    assert Math.wrap(10, -10, 10) == -10
    assert Math.wrap(-10, -10, 10) == -10
    assert Math.wrap(9, 0, 9) == 0
    assert Math.wrap(10, 0, 9) == 1
    assert Math.wrap(0, 0, 9) == 0
  end

  test "limits ranges" do
    assert Math.limit(0, 0, 1023) == 0
    assert Math.limit(-1, 0, 1023) == 0
    assert Math.limit(512, 0, 1023) == 512
    assert Math.limit(1023, 0, 1023) == 1023
    assert Math.limit(1024, 0, 1023) == 1023

    assert Math.limit(1024, -999_999, 999_999) == 1024
    assert Math.limit(999_999, -999_999, 999_999) == 999_999
    assert Math.limit(-999_999, -999_999, 999_999) == -999_999
    assert Math.limit(1_999_999, -999_999, 999_999) == 999_999
    assert Math.limit(-1_999_999, -999_999, 999_999) == -999_999
  end

  test "does floating point mod" do
    assert round_to_3(Math.fmod(1.234, 9)) == 1.234
    assert round_to_3(Math.fmod(9.234, 9)) == 0.234
    assert round_to_3(Math.fmod(10.234, 9)) == 1.234
    assert round_to_3(Math.fmod(-9.123, 9)) == -0.123

    assert Float.round(Math.fmod(18.5, 4.2), 1) == 1.7
    assert Float.round(Math.fmod(-5.1, 3.0), 1) == -2.1

    assert Float.round(Math.fmod_positive(18.5, 4.2), 1) == 1.7
    assert Float.round(Math.fmod_positive(-5.1, 3.0), 1) == 0.9
  end

  test "wraps longitudes & latitudes" do
    assert round_to_3(Math.wrap_lon_lat(-20.123, 20.123)) == {-20.123, 20.123}
    assert round_to_3(Math.wrap_lon_lat(-180.123, 100.123)) == {179.877, -79.877}
    assert round_to_3(Math.wrap_lon_lat(181.123, -90.123)) == {-178.877, 89.877}
  end

  defp round_to_3({x, y}), do: {Float.round(x, 3), Float.round(y, 3)}
  defp round_to_3(x), do: Float.round(x, 3)
end
