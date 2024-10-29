defmodule UrlShortenerWeb.UrlShortenerLive.Index do
  use UrlShortenerWeb, :live_view

  # Importing helpers

  alias UrlShortener.Schema.Url
  alias UrlShortener.Urls
  alias UrlShortenerWeb.Services.UrlShortenerCache
  # alias UrlShortenerWeb.Router, as: Routes
  alias UrlShortenerWeb.Router.Helpers, as: Routes

  @impl true
  def mount(_params, _session, socket) do
    changeset = Urls.change_url(%Url{})

    socket =
      socket
      |> assign_form(changeset)
      |> assign(shortened_url: nil, error: nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"url" => url_params}, socket) do
    changeset = Urls.change_url(%Url{}, url_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  @impl true
  def handle_event("submit", %{"url" => url_params}, socket) do
    changeset = Urls.change_url(%Url{}, url_params)

    if changeset.valid? do
      case UrlShortenerCache.insert_url(url_params) do
        {:ok, short_key} ->
          # Generate the full shortened URL for display
          shortened_url = Routes.url_shortener_path(UrlShortenerWeb.Endpoint, :show, short_key)
          {:noreply, assign(socket, shortened_url: shortened_url, error: nil)}

        {:error, reason} ->
          # Handle the error gracefully
          {:noreply, assign(socket, error: "Failed to shorten URL: #{reason}")}
      end
    else
      # Assign validation error without redirecting
      {:noreply, assign(socket, error: "Invalid URL")}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
