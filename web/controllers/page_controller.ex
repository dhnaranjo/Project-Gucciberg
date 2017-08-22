defmodule PhoenixPg.PageController do
  require Logger
  use PhoenixPg.Web, :controller

  def index(conn, _params) do
    Logger.info "Page loaded!"
    render conn, "index.html"
  end

  def create(conn, params) do
    artist = params["create"]["artist"]
    Logger.info artist
    render conn, "index.html"
  end
end
