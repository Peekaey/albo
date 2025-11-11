defmodule Albo.Application do
  use Application

  @moduledoc """
  Application entry point.
  Nostrum already manage and supervises its own processes as an application.
  """

  @impl true
  def start(_type, _args) do
    # Application's supervised children here.
    children = [
      # Starts the Nostrum consumer as a supervised child so a consumer process
      # is available immediately when shards attempt to connect.
      # Consumer process is the DiscordBot itself
      {Albo.Consumer, []},
      {Albo.CommandRegistrar, []}
    ]

    # Name the supervisor so it can be referenced elsewhere in the app.
    Supervisor.start_link(children, strategy: :one_for_one, name: Albo.Supervisor)
  end
end
