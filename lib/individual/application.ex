defmodule Individual.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Supervisor.start_link([
      {Individual, Individual.Test}
    ], strategy: :one_for_one, name: Individual.Supervisor)
  end
end
