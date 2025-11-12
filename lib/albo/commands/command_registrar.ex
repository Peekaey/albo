defmodule Albo.CommandRegistrar do
  use GenServer
  require Logger

  @moduledoc """
  Registers application commands on startup for a single guild.
  Guild commands propagate instantly, unlike global commands which can take hours.
  """

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]},
      type: :worker,
      restart: :transient
    }
  end

  @impl true
  def init(_) do
    Process.send_after(self(), :register, 500)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:register, state) do
    {:ok, _} = Application.ensure_all_started(:nostrum)

    app_id = Application.fetch_env!(:nostrum, :application_id)
    guild_id = parse_guild_id()

    if is_nil(guild_id) do
      Logger.warning("DISCORD_GUILD_ID not set; skipping command registration")
      {:stop, :normal, state}
    else
      register_commands(app_id, guild_id)
      {:stop, :normal, state}
    end
  end

  defp parse_guild_id do
    case System.get_env("DISCORD_GUILD_ID") do
      nil -> nil
      s when is_binary(s) -> String.to_integer(s)
    end
  end

  defp register_commands(app_id, guild_id) do
    payloads = Albo.CommandRegistry.payloads_for_registration()

    case Nostrum.Api.ApplicationCommand.bulk_overwrite_guild_commands(app_id, guild_id, payloads) do
      {:ok, commands} ->
        Enum.each(commands, fn cmd ->
          name = Map.get(cmd, "name") || Map.get(cmd, :name, "<unknown>")
          id = Map.get(cmd, "id") || Map.get(cmd, :id)
          Logger.info("Registered command: #{name} (id: #{id})")
        end)

      {:error, reason} ->
        Logger.error("Failed to register commands: #{inspect(reason)}")
    end
  end
end
