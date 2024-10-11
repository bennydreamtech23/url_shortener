defmodule UrlShortenerWeb.Services.UrlShortenerCache do
  use GenServer

  @table_name :url_shortener_data
  @expiry_time 600_000  # expiry time: 10 minutes (600_000 milliseconds)

  ## Public API

  # Starts the GenServer and initializes the ETS table
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Inserting key-value pair into the ETS table with an expiry timestamp
  def insert(key, value) do
    GenServer.call(__MODULE__, {:insert, key, value})
  end

  # Retrieving value for the given key from the ETS table
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  # Deleting a key from the ETS table
  def delete(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end

  # Fetching all records from the ETS table
  def get_all() do
    GenServer.call(__MODULE__, :get_all)
  end

  ## GenServer Callbacks

  @impl true
  def init(_opts) do
    # Initialize ETS table when GenServer starts
    :ets.new(@table_name, [:named_table, :set, :public])
    {:ok, %{}}
  end

  @impl true
  def handle_call({:insert, key, value}, _from, state) do
    expiry_timestamp = System.system_time(:millisecond) + @expiry_time
    :ets.insert(@table_name, {key, value, expiry_timestamp})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    case :ets.lookup(@table_name, key) do
      [{^key, value, expiry_timestamp}] ->
        if not_expired?(expiry_timestamp) do
          {:reply, {:ok, value}, state}
        else
          :ets.delete(@table_name, key)
          {:reply, :expired, state}
        end

      [] ->
        {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:delete, key}, _from, state) do
    :ets.delete(@table_name, key)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:get_all, _from, state) do
    all_records = :ets.tab2list(@table_name)
    {:reply, all_records, state}
  end

  ## Private helper function

  defp not_expired?(expiry_timestamp) do
    System.system_time(:millisecond) < expiry_timestamp
  end
end
