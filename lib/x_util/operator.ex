defmodule XUtil.Operator do
  @moduledoc """
  Simple functional wrappers around fundamental operators
  """

  @doc """
  What I wish I could write as &==(&1, val)
      iex(1)> Enum.filter([1, 2, 3, 1, 2, 3], XUtil.Operator.equal(3))
      [3, 3]
  """
  def equal(val), do: fn x -> x == val end

  @doc """
  What I wish I could write as &!=(&1, val)
      iex(1)> Enum.filter([1, 2, 3, 4], XUtil.Operator.not_equal(3))
      [1, 2, 4]
  """
  def not_equal(val), do: fn x -> x != val end
end
