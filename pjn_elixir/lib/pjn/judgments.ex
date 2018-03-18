defmodule Pjn.Judgments do

  def read(dataset, file_ids \\ nil)

  def read(:all, file_ids), do:
    read_path(
      "/Users/mathek/Desktop/shit/agh/pjn/data/json/",
      file_ids || 1..3173,
      fn %{"items" => items} -> items end
    )

  def read(2017, file_ids), do:
    read_path(
      "/Users/mathek/Desktop/shit/agh/pjn/data2017/json/",
      file_ids || 0..8
    )

  def read_path(base_path, file_ids, unwrap_f \\ & &1) do
    file_ids
      |> Stream.map(& base_path |> Path.join("judgments-#{&1}.json"))
      |> Flow.from_enumerable(max_demand: 1)
      |> Flow.flat_map(& &1
          |> File.read!
          |> Poison.decode!
          |> unwrap_f.()
        )
  end

  def filter_by_year(judgments, year) do
    year = "#{year}"
    judgments
      |> Flow.filter(fn %{"judgmentDate" => <<y::binary-size(4)>> <> _} ->
          y == year
        end)
  end

end
