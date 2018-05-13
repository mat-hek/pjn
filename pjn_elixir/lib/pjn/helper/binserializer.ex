defmodule Pjn.Helper.Binserializer do
  def dump_to_file(term, path) do
    term = term |> :erlang.term_to_binary
    with {:ok, res} <- File.open(path, [:write], & IO.binwrite(&1, term)) do
      res
    end
  end
  def read_from_file(path) do
    with {:ok, data} <- File.open(path, [:read], & IO.binread(&1, :all)) do
      {:ok, data |> :erlang.binary_to_term}
    end
  end
end
