defmodule Individual.Test do
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: {:global, :test})
  end

  def ping() do
    GenServer.call({:global, :test}, :ping)
  end

  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end
end
