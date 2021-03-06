defmodule PhoenixPg.PageController do
  require Logger
  require HTTPoison

  use PhoenixPg.Web, :controller

  def index(conn, _params) do
    Logger.info "Page loaded!"
    render conn, "index.html"
  end

  def create(conn, %{"create" => %{"artist" => searched_artist}}) do

    primary_artist = searched_artist
                     |> artist_search
                     |> Kernel.get_in(["response", "hits"])
                     |> List.first
                     |> get_song_primary_artist

    artist_songs = primary_artist["id"]
                   |> songs_search
                   |> Kernel.get_in(["response", "songs"])
                   # |> Enum.map(& [ title: &1["title"], url: &1["url"]])


    {_, song} = Enum.fetch(artist_songs,0)

    lyrics = HTTPoison.get!(song["url"])
             |> Map.get(:body)
             |> Floki.find(".lyrics p")
             |> Floki.text
             |> String.replace(~r/\n\n/, "\n")
             |> String.replace(~r/\[(.+?)\]/, "-\\1-")
             |> String.split("\n")
             |> Enum.chunk_by(&(&1 == ""))
             |> Enum.reject(&(&1 == [""]))

    song_name = song["title_with_featured"]

    { _, pdf } = %{title: song_name, lyrics: lyrics}
                 |> Iona.template(path: "web/static/assets/song.tex.eex")
                 # |> Iona.write!("web/static/assets/#{:os.system_time(:seconds)}.pdf")
                 |> Iona.to(:pdf)
    conn
    |> put_resp_content_type("application/pdf")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{song["title_with_featured"]}.pdf\"")
    |> send_resp(200, pdf)

    # IO.puts song["title_with_featured"]
    # Apex.ap lyrics
    # render conn, "index.html"
  end

  def get_song_primary_artist(song), do: song |> Kernel.get_in(["result", "primary_artist"])

  def parse_response(response) do
    response |> Map.get(:body) |> Poison.decode! 
  end

  def artist_search(artist) do
    client_key = System.get_env("GENIUS_CLIENT_KEY")
    HTTPoison.get!("https://api.genius.com/search?q=#{URI.encode artist}", ["Authorization": "Bearer #{client_key}"],[])
    |> parse_response
  end

  def songs_search(artist_id) do
    client_key = System.get_env("GENIUS_CLIENT_KEY")
    HTTPoison.get!("https://api.genius.com/artists/#{Integer.to_string artist_id}/songs?sort=popularity", ["Authorization": "Bearer #{client_key}"],[])
    |> parse_response
  end
end
