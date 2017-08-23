defmodule PhoenixPg.PageController do
  require Logger
  require HTTPoison

  use PhoenixPg.Web, :controller

  def index(conn, _params) do
    Logger.info "Page loaded!"
    render conn, "index.html"
  end

  def create(conn, %{"create" => %{"artist" => artist}}) do
    Logger.info artist
    client_key = System.get_env("GENIUS_CLIENT_KEY")

    response = HTTPoison.get!("https://api.genius.com/search?q=#{URI.encode artist}",
                              ["Authorization": "Bearer #{client_key}"],
                              [])

    songs = response
            |> Map.get(:body)
            |> Poison.decode!
            |> Kernel.get_in(["response", "hits"])
            |> Enum.map(& [ title: &1["result"]["title"], url: &1["result"]["url"]])

    {_, song} = Enum.fetch(songs,0)

    song_page = HTTPoison.get!(song[:url])
                |> Map.get(:body)
                |> Floki.find(".lyrics p")
                |> Floki.text
                |> String.replace(~r/\n\n/, "\n")
                # |> Floki.raw_html
                # |> String.replace(~r/<a.*?<\/a>/, "")

    IO.puts song_page
    render conn, "index.html"
  end
end
