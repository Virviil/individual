defmodule Individual.Wrapper do
  @moduledoc """
  This GenServer wraps underlying module.

  ## The problem

  Worker can not register it's name by default, so we need wrapper that would
  register inside global module for that purposes
  """
  def child_spec(son_child_spec) do
    Map.merge(son_child_spec, %{
      # We need to specify this worker as a supervisor to prevent timeout crashes
      type: :supervisor,
      # Shutdown should be specified as infinity to prevent timeout crashes
      shutdown: :infinity,
      start: {__MODULE__, :start_link, [son_child_spec]}
    })
  end

  def start_link(son_child_spec) do
    case GenServer.start_link(
           __MODULE__,
           son_child_spec,
           name: {:global, :"#Individual.Wrapper<son_child_spec.id>"}
         ) do
      {:ok, pid} ->
        Process.register(pid, :"#Individual.Wrapper<son_child_spec.id>")
        {:ok, pid}

      error ->
        error
    end
  end

  def init(son_child_spec) do
    # We are trying to register the wrapper with given name first. If the name
    # is taken, the worker's initialization process should not be started.
    # So we pend worker's initialization into main loop message handling.
    Process.send(self(), :init, [])
    {:ok, son_child_spec}
  end

  def handle_info(:init, son_child_spec) do
    {:ok, son_child_spec} = start_worker(son_child_spec)
    {:noreply, son_child_spec}
  end

  @doc """
  This function tries to start a worker.
  If everything goes ok, this module starts to be supervised by wrapper.
  """
  def start_worker(%{start: {module, function, args}, id: id} = son_child_spec) do
    case Kernel.apply(module, function, args) do
      {:ok, pid} when is_pid(pid) ->
        Process.link(pid)
        {:ok, son_child_spec}

      {:error, {:already_started, pid}} ->
        raise RuntimeError,
              "Individual's supervised module #{id} try to take the name, that is already registered in current node's scope for process #{
                pid
              }. Please, check your worker's starting functions - may be it's naming is in conflict with other names!"

      _err ->
        raise RuntimeError,
              "Individual's supervised module #{id} fails to start properly. It should return `{:ok, pid}` tuple to get supervised by Individual. Please, check you worker's starting functions - may be they don't return expected tuple!"
    end
  end
end
