defmodule Individual.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Supervisor.start_link([
      {Individual, Supervisor.child_spec({Individual.Test, []}, id: Test1)},
      # {Individual, Supervisor.child_spec({Individual.Test, []}, id: Test2)}
    ], strategy: :one_for_one, name: Individual.Supervisor)
  end
end
