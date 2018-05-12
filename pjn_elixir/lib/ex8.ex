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

end
