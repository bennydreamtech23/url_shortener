defmodule UrlShortener.Repo do
  use Ecto.Repo,
    otp_app: :urlshortener,
    adapter: Etso.Adapter
end
