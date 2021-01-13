defmodule XUtil.Enum do
  @moduledoc """
  Algorithms I wish were included in Enum
  """

  @doc """
  Filters out ("rejects") the specified value.

      iex(1)> XUtil.Enum.drop([1, 2, 1, 3, 1, 4, 1, 5], 1)
      [2, 3, 4, 5]

      iex(1)> XUtil.Enum.drop([1, nil, 1, 3, nil, nil, 1, 5], nil)
      [1, 1, 3, 1, 5]
  """
  def drop(enumerable, val) do
    Enum.reject(enumerable, XUtil.Operator.equal(val))
  end

  @doc """
  Just the opposite of "any"

      iex(1)> XUtil.Enum.none?([1, 2, 3, 4, 5], fn val -> rem(val, 2) == 0 end)
      false
      iex(1)> XUtil.Enum.none?([1, 3, 5, 7, 9], fn val -> rem(val, 2) == 0 end)
      true
  """
  def none?(enumerable, predicate) do
    not Enum.any?(enumerable, predicate)
  end
end
