defmodule Pjn.Helper.Binserializer do
  def dump_to_file(term, path) do
    term = term |> :erlang.term_to_binary
    File.open(path, [:write], & IO.binwrite(&1, term))
  end
  def read_from_file(path) do
    with {:ok, data} <- File.open(path, [:read], & IO.binread(&1, :all)) do
      data |> :erlang.binary_to_term
    end
  end
end
