defmodule PhoenixPg.PageController do
  require Logger
  require HTTPoison

  use PhoenixPg.Web, :controller

  def index(conn, _params) do
    Logger.info "Page loaded!"
    render conn, "index.html"
  end

  def create(conn, params) do
    artist = params["create"]["artist"]
    Logger.info artist
    client_key = System.get_env("GENIUS_CLIENT_KEY")
    response = HTTPoison.get!("https://api.genius.com/search?q=#{URI.encode artist}",
                             ["Authorization": "Bearer #{client_key}"],
                             [])

    # IO.puts inspect Poison.decode!(response.body)["response"]["hits"]

    response.body
    |> Poison.decode!
    |> Kernel.get_in(["response", "hits"])
    |> Enum.map(& { &1["result"]["title"], &1["result"]["url"]})
    |> Apex.ap
    render conn, "index.html"
  end
end
