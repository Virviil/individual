defmodule Individual.Registry do
  @moduledoc """
  This registry is a build-up upon global registry. We'll use it for better conflicts resolution.
  """
  require Logger

  @throttle_time 5_000_000_000


  @doc false
  def register_name(name, pid) do
    :global.register_name(name, pid, &conflict_resolver/3)
  end

  @doc false
  def re_register_name(name, pid) do
    :global.re_register_name(name, pid, &conflict_resolver/3)
  end

  @doc false
  defdelegate unregister_name(name), to: :global
  @doc false
  defdelegate whereis_name(name), to: :global
  @doc false
  defdelegate send(pid, message), to: :global

  defp conflict_resolver(name, pid_l, pid_r) do
    case resolve_with_times(Individual.Wrapper.time_alive(pid_l), Individual.Wrapper.time_alive(pid_r)) do
      :left -> commit_resolution(name, pid_l, pid_r)
      :right -> commit_resolution(name, pid_r, pid_l)
    end
  end

  defp reslove_with_times(tl_l, tl_r) when tl_l - tl_r > @throttle_time, do: :left
  defp reslove_with_times(tl_l, tl_r) when tl_l - tl_r > -@throttle_time, do: :right
  defp resolve_with_times(_, _), do: elem({:left, :right}, :rand.uniform(2) - 1)

  defp commit_resolution(name, pid_to_stay, pid_to_kill) do
    Logger.debug("Individual: Name conflict for name #{inspect name}! Terminating #{inspect pid_to_kill}")
    :erlang.exit(pid_to_kill, :kill)
    pid_to_stay
  end
end
