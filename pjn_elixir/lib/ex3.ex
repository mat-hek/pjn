defmodule Ex3 do
  alias Pjn.Helper.Serializer
  alias Ex3.Levenstein

  @dump_path "/Users/mathek/Desktop/shit/agh/pjn/repo/dump/ex3/"

  def mk_freq_list(judgments) do
    judgments
      |> Flow.from_enumerable(max_demand: 10)
      |> Flow.flat_map(fn %{"textContent" => content} ->
          content
            |> (&Regex.replace ~r"\<[^\>]*\>", &1, " ").()
            |> (&Regex.replace ~r"-\n", &1, "").()
            |> (&Regex.scan ~r"\w+"u, &1).()
            |> List.flatten
            |> Enum.map(&String.downcase/1)
        end)
      |> Enum.reduce(%{}, fn word, acc ->
          if map_size(acc) |> rem(1000) == 0, do:
            IO.inspect {self(), map_size(acc)}
          acc |> Map.update(word, 1, & &1+1)
        end)
      |> Enum.sort_by(fn {_word, cnt} -> -cnt end)
  end

  def filter_freq_list(fl) do
    fl
      |> Enum.filter(fn {word, _cnt} ->
        String.length(word) > 1 and not Regex.match?(~r"\d+", word)
      end)
  end

  def split_freq_list_by_word_set(fl, word_set) do
    fl |> Enum.split_with(fn {word, _cnt} ->
        word_set |> MapSet.member?(word)
      end)
  end

  def plot_freq_list(fl) do
    x = 1..length(fl)
    y = fl |> Keyword.values
    alias Expyplot.Plot
    Plot.plot [x, y]
    Plot.yscale ["log"]
    Plot.xlabel "Miejsce slowa na liscie"
    Plot.ylabel "Liczba wystapien"
    Plot.show
  end

  def read_morfologik do
    path = "/Users/mathek/Desktop/shit/agh/pjn/polimorfologik-2.1/polimorfologik-2.1.txt"
    File.stream!(path)
      |> Enum.map(fn line ->
          [_base, word | _] = line |> String.split(";")
          word |> String.replace("-", "") |> String.downcase
        end)
  end

  def fix_words(fl, words) do
    fm = fl |> Map.new
    words
      |> Enum.flat_map(fn w -> w |> fix_word(fm) |> Enum.map(& {w, &1}) end)
      |> Map.new
  end

  defp fix_word(word, fm, radius \\ 0)
  defp fix_word(_word, _fm, radius) when radius > 1 do [] end
  defp fix_word(word, fm, radius) do
    word
      |> Levenstein.in_radius(radius)
      |> Enum.flat_map(&
        with {:ok, cnt} <- fm |> Map.fetch(&1) do [[{&1, cnt}]] else _ -> [] end)
      |> Enum.max_by(fn [{_word, cnt}] -> cnt end, fn -> [] end)
      |> Enum.map(fn {word, _cnt} -> word end)
      |> (case do
          [] -> fix_word(word, fm, radius+1)
          result -> result
        end)

  end

  def store_freq_list(fl, name) do
    fl
      |> Enum.map(&Tuple.to_list/1)
      |> Serializer.dump_to_file("#{@dump_path}#{name}.json")
  end

  def read_freq_list(name) do
    Serializer.read_from_file("#{@dump_path}#{name}.json")
      |> Enum.map(&List.to_tuple/1)
  end
end
