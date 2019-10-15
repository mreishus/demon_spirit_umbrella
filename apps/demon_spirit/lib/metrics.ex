defmodule DemonSpirit.Metrics do
  @moduledoc """

  """
  def game_created() do
    Task.async(fn ->
      %{
        event: :game_created,
        when: DateTime.utc_now(),
        env: env()
      }
      |> send_to_honeycomb()
    end)
  end

  def send_to_honeycomb(params) do
    with {:ok, api_key} <- System.fetch_env("HONEYCOMB_APIKEY"),
         {:ok, dataset} <- System.fetch_env("HONEYCOMB_DATASET") do
      send_to_honeycomb_(params, api_key, dataset)
    end
  end

  defp send_to_honeycomb_(params, api_key, dataset) do
    body = Poison.encode!(params)
    url = "https://api.honeycomb.io/1/events/" <> dataset

    headers = [
      {"Content-type", "application/json"},
      {"X-Honeycomb-Team", api_key}
    ]

    Task.async(fn ->
      HTTPoison.post(url, body, headers, [])
    end)
  end

  defp env do
    Application.get_env(:demon_spirit, :env)
  end
end
