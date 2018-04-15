defmodule Pjn.Helper.File do
  def ls_paths(dir) do
    File.ls!(dir) |> Enum.map(& dir |> Path.join(&1))
  end
end
