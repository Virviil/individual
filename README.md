# Individual

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

```elixir
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
```

## Starting cluster

```
iex --name a@127.0.0.1 -S mix
iex --name b@127.0.0.1 -S mix
```

## Changelog

### 0.2.1

[ENCHANSMENT] Adding `Individual.Wrapper` module, that allowes to control GenServer,
that don't register themselves in `:global` scope.

### 0.1.1

[ENCHANSMENT] Beautifying `observer`'s output

## Installation

The package can be installed by adding `individual` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:individual, "~> 0.2"}
  ]
end
```
