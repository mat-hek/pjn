defmodule Ex1 do
  alias Ex1.Finder
  alias Expyplot.Plot
  
  def find_money(judgments) do
    judgments
      |> Flow.flat_map(fn %{"textContent" => content} ->
        content |> Finder.find_money
      end)
      |> Enum.to_list
  end
  
  def plot_money(money, args \\ []) do
    Plot.xlabel "Kwoty [zl]"
    Plot.ylabel "Liczba wystapien"
    args = [bins: 20] |> Keyword.merge(args)
    Plot.hist money, args
    Plot.show
  end
  
  def count_szkodas(judgments) do
    judgments
      |> Flow.map(fn %{"textContent" => content} ->
          content |> Finder.count_szkodas
        end)
      |> Enum.sum
  end
  
  def count_KC(judgments) do
    judgments
      |> Flow.filter(fn %{"referencedRegulations" => refs} ->
          refs |> Enum.any?(fn
            %{"journalEntry" => 93, "journalNo" => 16, "text" => text} ->
              Regex.match? ~r"art\.\s445", text
            _ -> false
            end)
        end)
      |> Enum.count
  end
  
end
