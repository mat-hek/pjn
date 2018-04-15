defmodule Ex6 do
  alias Pjn.Helper
  alias Helper.Binserializer

  @case_types C: "A?C", U: "A?U", K: "A?K", G: "G", P: "A?P", R: "R",
              W: "W", Am: "Am"

  @frequent_words_regexes [
      "na", "do", "nie", "że", "art", "się", "dnia", "przez", "od", "sąd",
      "za", "jest", "zł", "oraz", "roku", "tym", "to", "co", "sądu", "po"
    ]
    |> Helper.Regex.mk_alt
    |> (case do regex -> ~r"(\b#{regex}\b)" end)

  def dump_base, do: "/Users/mathek/Desktop/shit/agh/pjn/repo/dump/ex6/"

  def cases_path(case_type), do:
    Path.join([dump_base(), "cases", "#{case_type}"])
  def base_form_cases_path(case_type), do:
    Path.join([dump_base(), "cases_bf", "#{case_type}"])

  def tag_stored() do
    @case_types
    |> Keyword.keys
    |> Enum.map(&base_form_cases_path/1)
    |> Enum.each(& &1 |> File.mkdir_p!)

    @case_types
    |> Keyword.keys
    |> Enum.flat_map(fn case_type ->
        pathes = case_type |> cases_path |> Helper.File.ls_paths
        Stream.repeatedly(fn -> case_type end) |> Enum.zip(pathes)
       end)
    |> Enum.shuffle
    |> Flow.from_enumerable(max_demand: 1)
    |> Flow.map(fn {case_type, path} ->
        id = path |> Path.basename
        content = path |> Binserializer.read_from_file
        {id, case_type, content}
      end)
    |> Flow.each(fn {id, case_type, content} ->
        with {:ok, data} <- content |> tag_content do
           words = data |> parse_tagged
           path = case_type |> base_form_cases_path |> Path.join("#{id}")
           words |> Binserializer.dump_to_file(path)
        else
          error -> IO.inspect {:error, :tag, id, error}
        end
      end)
    |> Flow.run

  end

  def categorize(judgments) do
    @case_types
    |> Keyword.keys
    |> Enum.map(&cases_path/1)
    |> Enum.each(& &1 |> File.mkdir_p!)

    judgments
    |> Helper.Flow.flowify(max_demand: 1)
    |> Flow.filter(fn %{"courtType" => type} ->
        type in ["COMMON", "SUPREME"]
      end)
    |> Flow.flat_map(fn %{
          "courtCases" => [%{"caseNumber" => case_no} | _],
          "textContent" => content,
          "id" => id
        } ->
        case_type = case_no |> get_case_type
        content = case_type
        |> Enum.flat_map(fn _ -> content |> extract_justification end)
        |> Enum.map(&parse_content/1)
        Enum.zip([case_type, content, [id]])
      end)
    |> Flow.each(fn {case_type, content, id} ->
        path = case_type |> cases_path |> Path.join("#{id}")
        content |> Binserializer.dump_to_file(path)
      end)
    |> Flow.run
  end

  def parse_content(judgment_content) do
    judgment_content
    |> (& Regex.replace ~r"(\<[^\>]*\>)", &1, " ").()
    |> (& Regex.replace ~r"#{Regex.source @frequent_words_regexes}|(\d+)"iu, &1, "").()
  end

  def extract_justification(judgment_content) do
    judgment_content
    |> String.split("<h2>UZASADNIENIE</h2>", parts: 2)
    |> tl
  end

  def get_case_type(case_no) do
    @case_types
    |> Enum.find(fn {_t, regex} -> Regex.match?(~r".*#{regex}.*", case_no) end)
    |> (case do
        nil -> []
        {type, _regex} -> [type]
      end)
  end

  def tag_content(content) do
    with {:ok, %{body: data}}
      <- HTTPoison.post("http://localhost:9200/", content, [], timeout: 500_000, recv_timeout: 500_000)
    do
      {:ok, data}
    end
  end

  defp parse_tagged(tagged) do
    do_parse_tagged(tagged |> String.split("\n"), true, [])
  end
  defp do_parse_tagged(["\t" <> line | tagged], _ignore = false, acc) do
    [word, _] = line |> String.split("\t", parts: 2)
    do_parse_tagged(tagged, true, [word | acc])
  end
  defp do_parse_tagged(["\t" <> _line | tagged], _ignore = true, acc), do:
    do_parse_tagged(tagged, true, acc)
  defp do_parse_tagged([_line | tagged], _ignore, acc), do:
    do_parse_tagged(tagged, false, acc)
  defp do_parse_tagged([], _ignore, acc), do:
    acc |> Enum.reverse

end
