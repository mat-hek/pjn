defmodule Pjn.Helper.Serializer do

  def dump_to_file(data, path) do
    data
      |> Poison.encode!
      |> (&File.write path, &1).()
  end

  def dump_to_files(data, path, chunk_size, extension \\ ".json") do
    data
      |> Stream.chunk_every(chunk_size)
      |> Stream.with_index
      |> Flow.from_enumerable(max_demand: 1)
      |> Flow.map(fn {data, i} -> {data |> Poison.encode!, i} end)
      |> Flow.each(fn {data, i} -> File.write "#{path}#{i}#{extension}", data end)
      |> Flow.run
  end

  def read_from_file(path) do
    File.read!(path) |> Poison.decode!
  end
end
