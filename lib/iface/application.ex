defmodule Iface.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Carga las variables del archivo .env
    Dotenv.load()
    Mix.Task.run("loadconfig")

    children = [
      # Starts a worker by calling: Iface.Worker.start_link(arg)
      # {Iface.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Iface.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
