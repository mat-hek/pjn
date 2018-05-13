defmodule Ex8 do
  alias Pjn.Helper

  def dump_base, do: "/Users/mathek/Desktop/shit/agh/pjn/repo/dump/ex8/"

  def prepare_judgments(j) do
    j
    |> Enum.sort_by(& &1 |> Map.fetch!("judgmentDate"))
    |> Enum.take(100)
    |> Enum.each(fn %{"textContent" => content, "id" => id} ->
      content = Regex.replace(~r"(\<[^\>]*\>)", content, " ")
      File.write(Path.join([dump_base(), "judgments", "#{id}"]), content)
    end)
  end

  def parse_ner_results() do
    dump_base()
    |> Path.join("ner_out")
    |> Helper.File.ls_paths()
    |> Enum.map(&File.read!/1)
    |> Enum.map(& &1 |> String.split("\n") |> Enum.drop(2) |> Enum.join("\n"))
    |> Enum.flat_map(&parse_ner_output/1)
  end

  def parse_ner_output(content) do
    content
    |> Quinn.parse()
    |> Quinn.find(:sentence)
    |> Enum.flat_map(& &1 |> Quinn.find(:tok) |> parse_ner_tokens)
  end

  defp parse_ner_tokens(tokens) do
    tokens
    |> Enum.flat_map(fn t ->
      [%{value: [orth]}] = t |> Quinn.find(:orth)
      t
      |> Quinn.find(:ann)
      |> Enum.map(fn %{attr: attr, value: [id]} ->
        {{attr |> Keyword.fetch!(:chan), String.to_integer(id)}, orth}
      end)
    end)
    |> Enum.group_by(fn {k, _v} -> k end, fn {_k, v} -> v end)
    |> Enum.flat_map(fn
      {{cat, 0}, words} -> words |> Enum.map(& {cat, [&1]})
      {{cat, _id}, words} -> [{cat, words}]
    end)
  end

  def reject_multi_category(ner_results) do
    ner_results
    |> Enum.group_by(fn {_cat, phrase} -> phrase end, fn {cat, _phrase} -> cat end)
    |> Enum.filter(fn {_phrase, cats} -> cats |> Enum.uniq() |> length == 1 end)
    |> Enum.flat_map(fn {phrase, cats} -> cats |> Enum.map(&{&1, phrase}) end)
  end

  def most_frequent_phrases(ner_results) do
    ner_results
    |> Enum.map(fn {cat, phrase} -> {cat, phrase |> Enum.join(" ")} end)
    |> Enum.group_by(fn {_cat, phrase} -> phrase end, fn {cat, _phrase} -> cat end)
    |> Enum.map(fn {phrase, cats} -> {phrase, length(cats), Enum.uniq(cats)} end)
    |> Enum.sort_by(fn {_phrase, num_found, _cats} -> num_found end, &>=/2)
  end

  def most_frequent_per_category(ner_results, limit \\ :infinity) do
    res = ner_results
    |> Enum.group_by(fn {cat, _phrase} -> cat |> extract_main_category() end)
    |> Map.new(fn {k, v} -> {k, v |> most_frequent_phrases()} end)
    case limit do
      :infinity ->
        res
      x when is_integer(x) ->
        res |> Enum.map(fn {k, v} -> {k, v |> Enum.take(limit)} end)
    end
  end

  def plot_categories_sizes(ner_results) do
    {x, y} = ner_results
    |> Enum.group_by(fn {cat, _phrase} -> cat end)
    |> Enum.map(fn {cat, phrases} -> {cat, length(phrases)} end)
    |> Enum.sort_by(fn {_cat, size} -> size end, &>=/2)
    |> Enum.unzip()

    Explot.new
    |> Explot.x_axis_labels(x)
    |> Explot.bar(nil, y)
    |> Explot.show
  end

  def plot_main_categories_sizes(ner_results) do
    ner_results
    |> Enum.map(fn {cat, phrase} -> {cat |> extract_main_category(), phrase} end)
    |> plot_categories_sizes()
  end

  defp extract_main_category(category) do
    category |> String.slice(0, 7)
  end

end
