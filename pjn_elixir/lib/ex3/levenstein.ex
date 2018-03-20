defmodule Ex3.Levenstein do

  @letters (?a..?z |> Enum.to_list) ++ 'ąćęłńóśźż'

  def in_radius(word, 0), do: [word]

  def in_radius(word, radius) do
    [word |
      (insert_letter(word) ++ remove_letter(word) ++ swap_letter(word))
        |> Enum.dedup
        |> Enum.flat_map(& in_radius &1, radius - 1)
      ]
  end

  defp insert_letter(word) do
    for i <- 0..String.length(word), l <- @letters do
      {pref, postf} = word |> String.split_at(i)
      pref <> <<l::utf8>> <> postf
    end
  end

  defp remove_letter(""), do: []
  defp remove_letter(word) do
    len = String.length(word)
    0..(len-1) |> Enum.map(fn i ->
        String.slice(word, 0, i) <> String.slice(word, i+1, len)
      end)
  end

  defp swap_letter(word) do
    len = String.length(word)
    if len > 1, do: do_swap_letter(word, len), else: []
  end
  defp do_swap_letter(word, len) do
    for i <- 0..(len-2) , j <- (i+1)..(len-1) do
      String.slice(word, 0, i)
      <> String.at(word, j)
      <> String.slice(word, (i+1)..(j-1))
      <> String.at(word, i)
      <> String.slice(word, j+1, len)
    end
  end

end
