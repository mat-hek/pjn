defmodule Pjn.Helper.Regex do
  def mk_alt(list), do:
    "(?:" <> (list |> Enum.join("|")) <> ")"
end