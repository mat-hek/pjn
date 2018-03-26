defmodule Ex4 do
  alias Pjn.Helper.Serializer

  def dump_base, do: "/Users/mathek/Desktop/shit/agh/pjn/repo/dump/ex4/"

  def llr(fl, bg) do
    fl = fl |> Map.new
    bcnt = bg |> count_words
    bg
    |> Enum.map(fn {words, cnt} ->
        [cnt1, cnt2] = words |> Enum.map(&(fl[&1] - cnt) |> max(0))
        # if cnt1 < 0 or cnt2 < 0 do
        #   IO.inspect {words, words |> Enum.map(&fl[&1]), cnt}
        # end
        ncnt = bcnt - cnt
        e = shannon_entropy([cnt, cnt1, cnt2, ncnt])
        e_rsum = shannon_entropy([cnt + cnt1, cnt2 + ncnt])
        e_csum = shannon_entropy([cnt + cnt2, cnt1 + ncnt])
        llr = 2 * Enum.sum([cnt, cnt1, cnt2, ncnt]) * (e - e_rsum - e_csum)
        {words, llr}
      end)
    |> Enum.sort_by(fn {_words, llr} -> llr end, &>=/2)
  end

  def shannon_entropy(list) do
    sum = list |> Enum.sum
    list |> Enum.map(fn 0 -> 0; v -> v/sum * :math.log(v/sum) end) |> Enum.sum
  end

  def pmi(fl, bg) do
    wcnt = fl |> count_words
    bcnt = bg |> count_words
    fl = fl |> Map.new
    bg
    |> Enum.map(fn {words, cnt} ->
        p12 = cnt/bcnt
        [p1, p2] = words |> Enum.map(&fl[&1]/wcnt)
        {words, p12/(p1*p2)}
      end)
    |> Enum.sort_by(fn {_words, pmi} -> pmi end, &>=/2)
  end

  def count_words(kv) do
    kv |> Enum.map(fn {_w, cnt} -> cnt end) |> Enum.sum
  end

  def filter_fl(fl) do
    fl |> Enum.filter(fn {word, _cnt} -> word |> filter_word? end)
  end

  def filter_bigrams(bg) do
    bg |> Enum.filter(fn {words, _cnt} -> words |> Enum.all?(&filter_word?/1) end)
  end

  defp filter_word?(word) do
    not Regex.match?(~r"\d+", word)
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
      |> Serializer.dump_to_file("#{dump_base()}#{name}.json")
  end

  def read_bigrams(name) do
    Serializer.read_from_file("#{dump_base()}#{name}.json")
      |> Map.new(fn [words, cnt] -> {words |> MapSet.new, cnt} end)
  end

end
