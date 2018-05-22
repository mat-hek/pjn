defmodule Ex9 do

  def dump_base, do: "/Users/mathek/Desktop/shit/agh/pjn/repo/dump/ex9/"

  def prepare_judgments(judgments) do
    fs = File.stream!(dump_base() |> Path.join("judgments"))
    judgments
      |> Flow.map(fn %{"textContent" => content} ->
        content
          |> (&Regex.replace ~r"\<[^\>]*\>", &1, " ").()
          |> (&Regex.replace ~r"-\n", &1, "").()
          |> (& &1 <> "\n").()
      end)
      |> Enum.into(fs)
  end
end
