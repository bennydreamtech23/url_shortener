defmodule UrlShortener.Urls do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  # alias UrlShortener.Repo
  alias UrlShortener.Schema.Url

  def change_url(%Url{} = url, attrs \\ %{}) do
    Url.changeset(url, attrs)
  end
end
