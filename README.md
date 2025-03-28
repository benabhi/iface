# Iface

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `iface` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:iface, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/iface>.

## Fix

Se agrego al archivo `/home/ubuntu/Code/Elixir/iface/deps/paddle/lib/paddle/parsing.ex`
el siguiente fragmento de codigo por que falta un matcheo de patrones.

```elixir
# Agregado en la Linea 161 por falta de un matcheo de patrones :S
def clean_eldap_search_results {:ok, {:eldap_search_result, entries, [], :asn1_NOVALUE}}, base do
  {:ok, clean_entries(entries, base)}
end
```