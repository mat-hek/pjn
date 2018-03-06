defmodule Pjn.Helper.Serializer do

  def dump_to_file(data, path) do
    data
      |> Poison.encode!
      |> (&File.write path, &1).()
  end
  
  def read_from_file(path) do
    File.read!(path) |> Poison.decode!
  end
end