defmodule XUtil.Bitstring do
  @moduledoc """
  Simple utilities for working with bitstrings.

  Elixir has amazing support for working with binaries (bitstrings whose size is divisible by 8)
  """

  @doc """
  Joins the enumerable bitstrings into a single bitstring.
  Examples:

      iex(1)> XUtil.Bitstring.join([<<1, 2, 3>>, <<1::size(1)>>, <<2::size(2)>>])
      <<1, 2, 3, 1::size(1), 2::size(2)>>

      iex(1)> XUtil.Bitstring.join([<<1, 2, 3>>, <<>>, <<1::size(1)>>, <<2::size(2)>>])
      <<1, 2, 3, 1::size(1), 2::size(2)>>

      iex(1)> XUtil.Bitstring.join([<<>>, <<1::size(1)>>, <<2::size(2)>>])
      <<6::size(3)>>
  """
  def join(bitstrings) do
    Enum.reduce(bitstrings, fn bits, acc ->
      acc_size = bit_size(acc)
      <<acc::bitstring-size(acc_size), bits::bitstring>>
    end)
  end

  @doc """
  True if the first bitstring contains the second.
  Examples:

      iex(1)> XUtil.Bitstring.contains(<<1, 2, 3, 4, 1::size(1)>>, <<2, 3, 4>>)
      true

      iex(1)> XUtil.Bitstring.contains(<<1, 2, 3, 4, 1::size(1)>>, <<3, 4, 1::size(1)>>)
      true

      iex(1)> XUtil.Bitstring.contains(<<1, 2, 3, 4, 1::size(1)>>, <<1::size(1)>>)
      true

      iex(1)> XUtil.Bitstring.contains(<<1, 2, 3, 4, 1::size(1)>>, <<>>)
      true

      iex(1)> XUtil.Bitstring.contains(<<1, 2, 3, 4, 1::size(1)>>, <<1, 2, 3, 4, 1::size(2)>>)
      false
  """
  def contains(haystack, needle)

  # A catch for when you inadvertently pass in a multiple-of-8 sized bitstring.
  # This should be quite a bit faster than our recursive implementation.
  def contains(haystack, needle) when is_binary(haystack) and is_binary(needle) do
    :binary.match(haystack, needle) != :nomatch
  end

  def contains(haystack, needle) when is_bitstring(haystack) and is_bitstring(needle) do
    cond do
      bit_size(needle) > bit_size(haystack) -> false
      bit_size(needle) == bit_size(haystack) -> needle == haystack
      true -> contains_subbitstring(haystack, needle)
    end
  end

  @doc """
  Splits the bitstring into chunks of equal size. (Input bitstring must be an even multiple of your size.)

      iex> XUtil.Bitstring.chunk(<<255::size(241)>>, 241)
      [<<255::size(241)>>]

      iex> XUtil.Bitstring.chunk(<<255::size(241), 255::size(241), 255::size(241), 255::size(241)>>, 241)
      [<<255::size(241)>>, <<255::size(241)>>, <<255::size(241)>>, <<255::size(241)>>]
  """
  def chunk(bits, chunk_bit_size) when is_bitstring(bits) do
    for <<chunk::bitstring-size(chunk_bit_size) <- bits>> do
      <<chunk::bitstring-size(chunk_bit_size)>>
    end
  end

  defp contains_subbitstring(haystack, needle) when is_bitstring(haystack) and is_bitstring(needle) do
    needle_size = bit_size(needle)

    case haystack do
      <<>> -> false
      <<^needle::bitstring-size(needle_size), _::bitstring>> -> true
      <<_::bitstring-size(1), remainder::bitstring>> -> contains_subbitstring(remainder, needle)
    end
  end
end
