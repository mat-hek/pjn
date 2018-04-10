defmodule Ex5 do

  def dump_base, do: "/Users/mathek/Desktop/shit/agh/pjn/repo/dump/ex5/"

  def calc_bigrams(judgments = %Flow{}) do
    judgments
    |> Flow.each(fn %{"textContent" => content, "id" => id} ->
        with \
          {:ok, bigrams} <- get_bigrams(content),
          {:ok, file} = Path.join(dump_base(), "bigrams/#{id}") |> File.open([:write]),
          :ok <- IO.binwrite(file, bigrams |> :erlang.term_to_binary),
          :ok <- file |> File.close
        do
          :ok
        else
          error -> IO.inspect {:error, error, id}
        end
      end)
    |> Flow.run
  end
  def calc_bigrams(judgments) do
    judgments
    |> Flow.from_enumerable(max_demand: 1)
    |> calc_bigrams()
  end

  def reduce_bigrams(files \\ bigrams_files()) do
    files
    |> Flow.from_enumerable(max_demand: 1)
    |> Flow.map(fn path ->
        File.read!(path) |> :erlang.binary_to_term
      end)
    |> Enum.reduce(& Map.merge &1, &2, fn _k, v1, v2 -> v1+v2 end)
  end

  def bigrams_files() do
    path = dump_base() |> Path.join("bigrams")
    File.ls!(path)
    |> Enum.map(& path |> Path.join(&1))
  end

  def unigrams_from_bigrams(bigrams) do
    bigrams
    |> Enum.reduce(%{}, fn {{w1, w2}, cnt}, acc ->
        acc
        |> Map.update(w1, {cnt, 0}, fn {l, r} -> {l + cnt, r} end)
        |> Map.update(w2, {0, cnt}, fn {l, r} -> {l, r + cnt} end)
      end)
    |> Enum.map(fn {w, {l, r}} -> {w, max(l, r)} end)
  end

  def filter_noun_adj(bigrams) do
    bigrams
    |> Enum.filter(fn {{{_w1, type1}, {_w2, type2}}, _cnt} ->
        type1 == :subst and type2 in [:adj, :adja, :adjp, :adjc]
      end)
  end

  defp get_bigrams(content) do
    content = Regex.replace(~r"\<[^\>]*\>", content, " ")
    with {:ok, %{body: data}}
      <- HTTPoison.post("http://localhost:9200/", content, [], timeout: 500_000, recv_timeout: 500_000)
    do
      bigrams = data
      |> String.split("\n")
      |> parse_tagged()
      |> count_bigrams()
      {:ok, bigrams}
    end
  end

  defp parse_tagged(tagged, ignore \\ true, acc \\ [])
  defp parse_tagged(["\t" <> line | tagged], _ignore = false, acc) do
    [word, type | _] = line |> String.split("\t")
    word = word |> String.downcase
    type = type |> String.split(":") |> hd |> String.to_atom
    acc = cond do
      type == :interp -> acc
      Regex.match?(~r"\d+", word) -> [nil | acc]
      true -> [{word, type} | acc]
    end
    parse_tagged(tagged, true, acc)
  end
  defp parse_tagged(["\t" <> _line | tagged], _ignore = true, acc), do:
    parse_tagged(tagged, true, acc)
  defp parse_tagged([_line | tagged], _ignore, acc), do:
    parse_tagged(tagged, false, acc)
  defp parse_tagged([], _ignore, acc), do:
    acc |> Enum.reverse


  defp count_bigrams(words, prev \\ nil, acc \\ %{})
  defp count_bigrams([w | words], nil, acc) do
    count_bigrams(words, w, acc)
  end
  defp count_bigrams([nil | words], _prev, acc) do
    count_bigrams(words, nil, acc)
  end
  defp count_bigrams([w | words], prev, acc) do
    acc = acc |> Map.update({prev, w}, 1, & &1+1)
    count_bigrams(words, w, acc)
  end
  defp count_bigrams([], _prev, acc), do: acc

end
