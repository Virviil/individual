# Individual

Process adapter to handle singleton processes in Elixir applications.

## The problem

Sometimes, when you start your program on cluster with *MASTER<->MASTER* strategy,
some of your modules should be started only on one node at a time. This is common pattern, which is called **CLUSTER SINGLETON**.
These modules can be thus be registered within `:global` module, but `:global` doesn't handle name conflicts and restarts.

## Solution

**Individual** will cover working with `:global` module by itself.
It will ensure, that **ONLY** one defined module at a time is working on a cluster,
and also will restart the process on another node in node with working process will fail.

## Split Brain Resolution

Since **Individual** uses `:global` module, there is a common problem with [cluster splits](https://en.wikipedia.org/wiki/Network_partition).
In this case, each part of previous stable cluster will have it's own process, thus
this process stops to be *singleton*.
In current implementation, **Individual** does not resolve this problems for you,
you should resolve them by yourself.

(*If you have great ideas of doing this - welcome to your PRs to this repo!*)

## Usage

Wrap your worker or supervisor specification inside any of your supervisors with
`Individual` call, passing supervisor specification as an argument for `Individual`.

Your worker or supervisor can register itself with some name or not - `Individual` will take care about registering it in a global scope.

## Examples

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
...
```

## Changelog

### 0.2.1

#### **ENHANCEMENTS**
*  Adding `Individual.Wrapper` module, that allows to control GenServer, that don't register themselves in `:global` scope.

### 0.1.1

#### **ENHANCEMENTS**
* Beautifying `observer`'s output

## Installation

The package can be installed by adding `individual` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:individual, "~> 0.2"}
  ]
end
```
