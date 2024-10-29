defmodule UrlShortenerWeb.UrlShortenerController do
  use UrlShortenerWeb, :controller

  alias UrlShortenerWeb.Services.UrlShortenerCache

  def show(conn, %{"short_key" => short_key}) do
    case UrlShortenerCache.get(short_key) do
      {:ok, %{"long_url" => long_url}} ->
        redirect(conn, external: long_url)

      :error ->
        conn
        |> put_status(:not_found)
        |> render("404.html")
    end
  end
end
