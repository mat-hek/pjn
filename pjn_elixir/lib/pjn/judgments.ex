defmodule Pjn.Judgments do

  def read(file_ids \\ 1..3173) do
    base_path = "/Users/mathek/Desktop/shit/agh/pjn/data/json/"
    pathes = file_ids
      |> Stream.map(& base_path |> Path.join("judgments-#{&1}.json"))
    pathes
      |> Flow.from_enumerable(max_demand: 1)
      |> Flow.flat_map(fn path ->
          %{"items" => items} = path
            |> File.read!
            |> Poison.decode!
          items
        end)
  end
  
  def filter_by_year(judgments, year) do
    year = "#{year}"
    judgments
      |> Flow.filter(fn %{"judgmentDate" => <<y::binary-size(4)>> <> _} ->
          y == year
        end)
  end
end