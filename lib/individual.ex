defmodule Individual do
  use GenServer
  require Logger

  # Если процесс дохнет - я сам дохну
  # Если процесс выходит - надо самому выходить

  def child_spec(child_spec) do
    son_childspec = child_spec |> convert_child_spec()

    Map.merge(
      son_childspec,
      %{
        type: :supervisor,
        start: {__MODULE__, :start_link, [son_childspec]}
      }
    )
  end

  def start_link(son_childspec) do
    GenServer.start_link(__MODULE__, son_childspec)
  end

  def init(son_childspec) do
    {:ok, start_supervised_module(son_childspec)}
  end

  def handle_info({:DOWN, _, :process, pid, reason}, son_childspec) do
    # Managed process exited. We need to die with the same reason.
    {:stop, reason, son_childspec}
  end

  defp start_supervised_module(%{start: {module, function, args}} = son_childspec) do
    case Kernel.apply(module, function, args) do
      {:ok, pid} ->
        Logger.debug "Starting module #{module}"
        pid
      {:error, {:already_started, pid}} ->
        Logger.debug "Module #{module} already started. Subscribing..."
        pid
    end
    |> Process.monitor()

    son_childspec
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
