defmodule Individual.Stopper do
  use GenServer

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    Process.monitor(pid)
    {:ok, pid}
  end

  def init(_) do
    Process.send_after(self(), :exit, 1000)
    {:ok, []}
  end

  def handle_info(:exit, state) do
    {:stop, {:shutdown, "ok"}, state}
  end
end
