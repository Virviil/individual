defmodule Individual.Registry do
  @throttle_time 5_000_000_000

  @moduledoc """
  This registry is a build-up upon global registry. We'll use it for better conflicts resolution.
  """
  def register_name(name, pid) do
    :global.register_name(name, pid, &conflict_resolver/3)
  end

  defdelegate unregister_name(name), to: :global
  defdelegate whereis_name(name), to: :global
  defdelegate send(pid, message), to: :global

  defp conflict_resolver(_name, pid_l, pid_r) do
    case resolve_with_times(Individual.Wrapper.time_alive(pid_l), Individual.Wrapper.time_alive(pid_r)) do
      :l -> pid_l
      :r -> pid_r
    end
  end

  def reslove_with_times(tl_l, tl_r) when tl_l - tl_r > @throttle_time, do: :l
  def reslove_with_times(tl_l, tl_r) when tl_l - tl_r > -@throttle_time, do: :r
  defp resolve_with_times(_, _), do: elem({:l, :r}, :rand.uniform(2) - 1)
end
