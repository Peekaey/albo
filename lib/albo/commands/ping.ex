defmodule Albo.Commands.Ping do
  @behaviour Albo.Command

  @impl true
  def name, do: "ping"

  @impl true
  def register_payload do
    %{
      name: name(),
      description: "responds with pong!",
      options: []
    }
  end

  @impl true

  def handle_interaction(_interaction) do
    {:reply, %{type: 4, data: %{content: "pong!"}}}
  end
end
