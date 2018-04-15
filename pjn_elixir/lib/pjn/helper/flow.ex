defmodule Pjn.Helper.Flow do
  def flowify(enum, args \\ [])
  def flowify(%Flow{} = flow, _args), do: flow
  def flowify(enum, args), do: enum |> Flow.from_enumerable(args)
end
