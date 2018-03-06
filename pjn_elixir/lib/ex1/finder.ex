defmodule Ex1.Finder do
  import Pjn.Helper.Regex

  def find_money(text) do
    prefix_sizes = %{"tys" => 1_000, "mln" => 1_000_000, "mld" => 1_000_000_000}
    prefix = prefix_sizes |> Map.keys |> mk_alt
    unit = ~w(zł złoty złotych) |> mk_alt
    re = ~r"((?:\d(?:\s|\.|,)*)+)(?:(#{prefix})\.?\s)?#{unit}\b"u
    re
      |> Regex.scan(text)
      |> Enum.flat_map(fn
        [_, amount | rest] ->
          {amount, fraction} = case Regex.run ~r"^(.*)\s*,.*(\d\d)$"u, amount do
              [_, number, fraction] -> {number, fraction}
              _ -> {amount, "0"}
            end
          amount = Regex.replace ~r"\s|\.|,"u, amount, ""
          with \
            {amount, ""} <- amount |> Integer.parse,
            {fraction, ""} <- fraction |> Integer.parse
          do
            factor = case rest do
                [prefix] -> prefix_sizes[prefix]
                [] -> 1
              end
            [amount * factor + 0.01 * fraction]
          else
            _ -> []
          end
          
        end)
  end
  
  def count_szkodas(text) do
    szkodas = ~w(szkoda szkodą szkodę szkodo szkody szkodzie szkodach szkodami szkodom szkód) |> mk_alt
    ~r"\b#{szkodas}\b"iu
      |> Regex.run(text)
  end
    
end
