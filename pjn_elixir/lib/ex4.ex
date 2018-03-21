defmodule Ex4 do
  @dump_base "/Users/mathek/Desktop/shit/agh/pjn/repo/dump/ex4/"
  alias Pjn.Helper.Serializer

  def count_words(fl) do
    fl |> Keyword.values |> Enum.sum
  end

  def get_bigrams(judgments) do
    judgments
      |> Flow.from_enumerable(max_demand: 10)
      |> Flow.map(fn %{"textContent" => content} ->
          content
            |> (&Regex.replace ~r"\<[^\>]*\>", &1, " ").()
            |> (&Regex.replace ~r"-\n", &1, "").()
            |> (&Regex.scan ~r"\w+"u, &1).()
            |> List.flatten
            |> Enum.map(&String.downcase/1)
            |> Enum.chunk_every(2, 1, :discard)
            |> Enum.reduce(%{}, fn words, acc ->
                acc |> Map.update(MapSet.new(words), 1, & &1+1)
              end)
        end)
      |> Enum.reduce(& Map.merge &1, &2, fn _k, v1, v2 -> v1+v2 end)
  end

  def store_bigrams(bg, name) do
    bg
      |> Enum.map(fn {words, cnt} -> [words |> Enum.to_list, cnt] end)
      |> Serializer.dump_to_file("#{@dump_base}#{name}.json")
  end

  def read_bigrams(name) do
    Serializer.read_from_file("#{@dump_base}#{name}.json")
      |> Map.new(fn [words, cnt] -> {words |> MapSet.new, cnt} end)
  end

end
