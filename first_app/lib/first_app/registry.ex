# The Registry process maintains the mappings between bucket names and bucket
# processes, so that users can pass a name to access their desired bucket.

defmodule FirstApp.Registry do
  use GenServer

  ## Client API

  @doc """
  Start the registry
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts) # __MODULE__ is the current
  end                                           # module. Registry here.

  @doc """
  Look up the bucket PID for `name` in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name}) # Calls are synchronous and return
  end

  @doc """
  Ensures that there is a bucket in `server` with the name `name`
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name}) # Casts are async and don't return
  end


  ##
  ## Server Callbacks
  ##  => Run on the GenServer
  ##

  def init(:ok) do # callback for start_link
    {:ok, HashDict.new}
  end

  def handle_call({:lookup, name}, _from, names) do # callback for lookup
    {:reply, HashDict.fetch(names, name), names}
  end

  def handle_cast({:create, name}, names) do # callback for create
    if HashDict.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, bucket} = FirstApp.Bucket.start_link()
      {:noreply, HashDict.put(names, name, bucket)}
    end
  end
end