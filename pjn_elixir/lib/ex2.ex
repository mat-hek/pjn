defmodule Ex2 do
  @es_url "http://127.0.0.1:9200/judgments/_doc"

  def post_to_es(judgments) do
    judgments
      |> Stream.map(fn judgment ->
          %{"textContent" => content, "judgmentDate" => date,
            "courtCases" => cases, "judges" => judges} = judgment
          data = %{
            content: content,
            date: date,
            signature: cases |> Enum.map(fn %{"caseNumber" => no} -> no end),
            judges: judges |> Enum.map(fn %{"name" => name} -> name end),
          }
          with {:ok, %{status_code: status}} when status in 200..300
            <- HTTPoison.post(@es_url, data |> Poison.encode!, [{"Content-type", "application/json"}])
          do
            :ok
          else
            resp -> raise inspect {:invalid_es_response, resp}
          end
        end)
      |> Stream.run
  end
end
