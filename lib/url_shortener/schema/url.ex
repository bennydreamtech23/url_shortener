defmodule UrlShortener.Schema.Url do
  use Ecto.Schema
  import Ecto.Changeset

  schema "urls" do
    field(:long_url, :string)
    field(:expiry_time, :naive_datetime)
    field(:short_url, :string)

    timestamps()
  end

  def changeset(url, params) do
    url
    |> cast(params, [:long_url, :short_url, :expiry_time])
    |> validate_required([:long_url])
    |> validate_format(:long_url, ~r/^https?:\/\//, message: "Invalid URL format")
  end
end
