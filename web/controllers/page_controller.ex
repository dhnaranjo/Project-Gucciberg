defmodule PhoenixPg.PageController do
  use PhoenixPg.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
