defmodule Individual do
  @moduledoc """
  Process adapter to handle singleton processes in Elixir applications.

  ### The problem

  Sometimes, when yo start your program on cluster with *MASTER<->MASTER* strategy,
  some of your modules should be started only on one nod at a time. The should be
  registered within `:global` module, but `:global` doesn't handle name conflicts
  and restarts. This is what `Individual` for.

  ### Usage

  Wrap your worker or supervisor specification inside any of your supervisors with
  `Individual` call, passing supervisor specification as argument for `Individual`.

  Your worker or supervisor should be registered within `:global` module.

  ### Examples

      # Simple call:
      def start(_type, _args) do
        Supervisor.start_link([
          {Individual, MyModule}
        ], strategy: :one_for_one, name: Individual.Supervisor)
      end

      # Call with args:
      def start(_type, _args) do
        Supervisor.start_link([
          {Individual, {MyModule, %{foo: :bar}}}
        ], strategy: :one_for_one, name: Individual.Supervisor)
      end

      # To start multiple processes with same name:
      def start(_type, _args) do
        Supervisor.start_link([
          {Individual, Supervisor.child_spec({MyModule, []}, id: Test1)},
          {Individual, Supervisor.child_spec({MyModule, []}, id: Test2)}
        ], strategy: :one_for_one, name: Individual.Supervisor)
      end
  """
  use GenServer
  require Logger

  @type child_spec :: :supervisor.child_spec() | {module, term} | module

  @doc false
  @spec child_spec(child_spec :: child_spec) :: :supervisor.child_spec()
  def child_spec(child_spec) do
    son_child_spec = child_spec |> convert_child_spec()

    Map.merge(
      son_child_spec,
      %{
        type: :supervisor,
        shutdown: :infinity,
        start: {__MODULE__, :start_link, [son_child_spec]}
      }
    )
  end

  @doc """
  This function will start your module, monitored with `Individual`. It requires
  your module's specification, the same you pass into any of your supervisors.

  ### Examples
      Individual.start_link(MyModule)
      Individual.start_link({MyModule, [1,2,3]})
      Individual.start_link(MyModule.child_spec(:foobar))
  """
  @spec start_link(son_childspec :: child_spec) :: GenServer.on_start
  def start_link(son_childspec) do
    GenServer.start_link(__MODULE__, son_childspec, name: :"#Individual<#{son_childspec.id}>")
  end

  @doc false
  def init(son_childspec) do
    {:ok, start_wrapper(son_childspec)}
  end

  ### DEATH

  # If the process is dieing - `Individual` dies also.
  # If the process is exiting - `Individual` is forced to exit.
  # Everything depends on supervision and workers strategies.

  @doc false
  def handle_info({:DOWN, _, :process, _pid, reason}, son_childspec) do
    # Managed process exited. We need to die with the same reason.
    {:stop, reason, son_childspec}
  end

  defp start_wrapper(%{id: id} = worker_child_spec) do
    case Individual.Wrapper.start_link(worker_child_spec) do
      {:ok, pid} ->
        Logger.debug("Individual: Starting wrapper for worker #{id}")
        pid
      {:error, {:already_started, pid}} ->
        Logger.debug "Individual: Worker #{id} already started. Subscribing..."
        pid
    end
    |> Process.monitor()

    worker_child_spec
  end

  defp convert_child_spec(module) when is_atom(module) do
    module.child_spec([]) |> convert_child_spec()
  end
  defp convert_child_spec({module, arg}) when is_atom(module) do
    module.child_spec(arg) |> convert_child_spec()
  end
  defp convert_child_spec(spec) when is_map(spec) do
    case Map.get(spec, :type) do
      :supervisor ->
        Map.merge(%{restart: :permanent, shutdown: :infinity}, spec)
      :worker ->
        Map.merge(%{restart: :permanent, shutdown: 5000}, spec)
      nil ->
        Map.merge(%{restart: :permanent, shutdown: 5000, type: :worker}, spec)
    end
  end
end
