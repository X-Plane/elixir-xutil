defmodule XUtil.GenServer do
  @moduledoc "Simple utilities for avoiding boilerplate in a GenServer implementation."

  @doc """
  If your GenServer is a thin wrapper around a struct, you can make its handle_call()
  implementation be "just this."

  Supports operations that:
  - Update the state
  - May return an error (with an optional explanation)
  - Query the state

  ...but not operations that both modify the state *and* query something.
  """
  def apply_call(impl_struct_state, impl) when is_struct(impl_struct_state) and is_function(impl) do
    case impl.(impl_struct_state) do
      updated_state when is_struct(updated_state) -> {:reply, :ok, updated_state}
      {:ok, updated_state} when is_struct(updated_state) -> {:reply, :ok, updated_state}
      :error -> {:reply, :error, impl_struct_state}
      {:error, explanation} = e when is_binary(explanation) -> {:reply, e, impl_struct_state}
      return_value -> {:reply, return_value, impl_struct_state}
    end
  end

  def fetch(impl_struct_state, impl) when is_struct(impl_struct_state) and is_function(impl) do
    {:reply, impl.(impl_struct_state), impl_struct_state}
  end

  def fetch_or_apply(state, {:apply, impl}), do: apply_call(state, impl)
  def fetch_or_apply(state, {:apply, impl, a1}), do: apply_call(state, fn state -> impl.(state, a1) end)
  def fetch_or_apply(state, {:apply, impl, a1, a2}), do: apply_call(state, fn state -> impl.(state, a1, a2) end)
  def fetch_or_apply(state, {:apply, impl, a1, a2, a3}), do: apply_call(state, fn state -> impl.(state, a1, a2, a3) end)
  def fetch_or_apply(state, {:apply, impl, a1, a2, a3, a4}), do: apply_call(state, fn state -> impl.(state, a1, a2, a3, a4) end)

  def fetch_or_apply(state, {:fetch, impl}), do: fetch(state, impl)
  def fetch_or_apply(state, {:fetch, impl, a1}), do: fetch(state, fn state -> impl.(state, a1) end)
  def fetch_or_apply(state, {:fetch, impl, a1, a2}), do: fetch(state, fn state -> impl.(state, a1, a2) end)
  def fetch_or_apply(state, {:fetch, impl, a1, a2, a3}), do: fetch(state, fn state -> impl.(state, a1, a2, a3) end)
  def fetch_or_apply(state, {:fetch, impl, a1, a2, a3, a4}), do: fetch(state, fn state -> impl.(state, a1, a2, a3, a4) end)
end
