defmodule Pigeon.APNSWorker do  
  use GenServer
  require Logger

  @doc "Starts the worker"
  def start_link(name, mode, cert, key) do
    Logger.debug("Starting worker #{name}\n\t mode: #{mode}, cert: #{cert}, key: #{key}")
    c = Pigeon.APNS.Connection.new(mode, cert, key)
    GenServer.start_link(__MODULE__, {:ok, c}, name: name)
  end

  @doc "Stops the server"
  def stop() do
    :gen_server.cast(self, :stop)
  end

  @doc "Initialize our server"
  def init(:ok, connection) do
    {:ok, connection}
  end

  @doc "Implement this multiple times with a different pattern to deal
  with sync messages"
  def handle_call({:push, :apns, notification}, from, state) do 
    {:ok, connection} = state
    case :ssl.send(connection.ssl_socket, notification) do
      :ok -> Logger.debug "Sent ok..."
      error -> Logger.error(error)
    end
    { :reply, :ok, state }
  end

  def handle_call(message, from, state) do
    Logger.debug "Bad message..."
    {:reply, {:error, :bad_message}, state}
  end

  @doc "Implement this multiple times with a different pattern to deal
  with async messages"
  def handle_cast(:message, state) do
  end

  @doc "Handle the server stop message"
  def handle_cast(:stop , state) do
    { :noreply, state }
  end

  @doc "Implement this to handle out of band messages (messages not
  sent using a gen_server call)"
  def handle_info(message, state) do
    {:reply, {:error, :bad_message}, state}
  end
end