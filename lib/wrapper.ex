defmodule Individual.Wrapper do
  @moduledoc """
  This module wraps underlying workers, that can not be registered in `:global` scope.

  ### The problem

  Worker can not register it's name by default, so we need wrapper, that would be
  registered inside global module for that purposes.

  ### Solution

  So, `Individual` will monitor `Individual.Wrapper`, which will be unique across cluster.
  Wrapper will monitor underlying module. If `Individual.Wrapper` will not be able to start
  because of name conflict, underlying module will even not try to start.

  When one of the cluster nodes will fall, `Individual` modules on all other
  nodes will try to start there own `Individual.Wrapper`'s. The first one, that will be started -
  will continue to work, and will start underlying module. All other will fail because
  of name conflicts.
  """
  require Logger

  @doc false
  def child_spec(son_child_spec) do
    Map.merge(son_child_spec, %{
      # We need to specify this worker as a supervisor to prevent timeout crashes
      type: :supervisor,
      # Shutdown should be specified as infinity to prevent timeout crashes
      shutdown: :infinity,
      start: {__MODULE__, :start_link, [son_child_spec]}
    })
  end

  def time_alive(pid) do
    GenServer.call(pid, :time_alive)
  end

  @doc """
  This function will be called by `Individual` module. No need to call it manually
  """
  def start_link(son_child_spec) do
    case GenServer.start_link(
           __MODULE__,
           son_child_spec,
           name: {:global, :"#Individual.Wrapper<#{son_child_spec.id}>"}
         ) do
      {:ok, pid} ->
        Process.register(pid, :"#Individual.Wrapper<#{son_child_spec.id}>")
        {:ok, pid}

      error ->
        error
    end
  end

  @doc false
  def init(son_child_spec) do
    # We are trying to register the wrapper with given name first. If the name
    # is taken, the worker's initialization process should not be started.
    # So we pend worker's initialization into main loop message handling.
    Process.send(self(), :init, [])
    {:ok, son_child_spec}
  end

  @doc false
  def handle_info(:init, son_child_spec) do
    Process.put(Individual.Wrapper.StartTime, :erlang.system_time())
    {:ok, son_child_spec} = start_worker(son_child_spec)
    {:noreply, son_child_spec}
  end

  def handle_call(:time_alive, _from, state) do
    {:reply, :erlang.system_time() - Process.get(Individual.Wrapper.StartTime, 0), state}
  end

  @doc false
  def start_worker(%{start: {module, function, args}, id: id} = son_child_spec) do
    # This function tries to start a worker.
    # If everything goes ok, this module starts to be supervised by wrapper.
    case Kernel.apply(module, function, args) do
      {:ok, pid} when is_pid(pid) ->
        Logger.debug("Starting worker #{son_child_spec.id}")
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
