defmodule Seqy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = build_children() ++ [{Seqy.Processbook, []}]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Seqy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp build_children() do
    Application.fetch_env!(:seqy, :topics)
    |> Enum.map(fn
      topic -> {DynamicSupervisor, strategy: :one_for_one, name: topic.name}
    end)
  end
end
