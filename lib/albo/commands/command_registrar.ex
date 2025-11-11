defmodule Albo.CommandRegistrar do
  use GenServer
  require Logger

  @moduledoc """
  A small worker that registers application commands on startup.
  It registers for a single guild (fast to propagate) to avoid Discord global command propagation delays.
  """

  # start_link starts a process and links it to the caller for supervision
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # describes to the supervisor how to start the process - acts as parameters
  # such as which MFA to call to start, how to read the child (worker vs supervisor)
  # how/when to restart it
  def child_spec(arg) do
    %{
      id: __MODULE__,
      # Module , function, arguments
      start: {__MODULE__, :start_link, [arg]},
      # Worker - not a nested supervisor
      type: :worker,
      # Restart only if terminates abnormally
      restart: :transient
    }
  end

  # GenServer callback
  # called when GenServer process is created and returns
  # a tuple to describe the initial state or instruct VM how to continue
  @impl true
  def init(_) do
    Process.send_after(self(), :register, 500)
    # returns an ok signal after 500 milliseconds
    {:ok, %{}}
  end

  @impl true
  def handle_info(:register, state) do
    # Returns ok if application started successfully or error if failed to start
    {:ok, _} = Application.ensure_all_started(:nostrum)
    # Gets app Id for cmd registration
    app_id = Application.fetch_env!(:nostrum, :application_id)

    # Gets guild Id as to register for that specific guild
    guild_id =
      System.get_env("DISCORD_GUILD_ID")
      |> case do
        # if not secret return to nil (null)
        nil -> nil
        # if string, convert to int
        s when is_binary(s) -> String.to_integer(s)
        # if already int, return as is
        i when is_integer(i) -> i
      end

    if is_nil(guild_id) do
      Logger.warning("DISCORD_GUILD_ID not set; skipping command registration")
      {:stop, :normal, state}
    else
      # Get payloads/commands for registration
      payloads = Albo.CommandRegistry.payloads_for_registration()

      # Preferred: try the new ApplicationCommand API helper, with fallbacks.
      # Capture and normalize possible return values so we can handle:
      #   - {:ok, cmds}
      #   - :ok
      #   - {:error, reason}
      #   - nil (no API available or failure)
      result =
        cond do
          function_exported?(Nostrum.Api.ApplicationCommand, :bulk_overwrite_guild_commands, 3) ->
            Nostrum.Api.ApplicationCommand.bulk_overwrite_guild_commands(
              app_id,
              guild_id,
              payloads
            )

          function_exported?(Nostrum.Api, :bulk_overwrite_guild_application_commands, 3) ->
            Nostrum.Api.bulk_overwrite_guild_application_commands(app_id, guild_id, payloads)

          true ->
            nil
        end

      case result do
        {:ok, cmds} ->
          Enum.each(cmds, fn c ->
            name = Map.get(c, "name") || Map.get(c, :name) || "<unknown>"
            id = Map.get(c, "id") || Map.get(c, :id)
            Logger.info("Bulk registered guild command: #{name} (id: #{inspect(id)})")
          end)

        :ok ->
          # Some API variants may return :ok. Attempt to verify by listing current guild commands.
          Logger.info("bulk_overwrite_guild_commands returned :ok; verifying current commands")

          verify_result =
            cond do
              function_exported?(Nostrum.Api.ApplicationCommand, :get_guild_commands, 2) ->
                Nostrum.Api.ApplicationCommand.get_guild_commands(app_id, guild_id)

              function_exported?(Nostrum.Api, :get_guild_application_commands, 2) ->
                Nostrum.Api.get_guild_application_commands(app_id, guild_id)

              true ->
                {:error, :no_list_function}
            end

          case verify_result do
            {:ok, cmds} ->
              Enum.each(cmds, fn c ->
                name = Map.get(c, "name") || Map.get(c, :name) || "<unknown>"
                id = Map.get(c, "id") || Map.get(c, :id)
                Logger.info("Verified guild command: #{name} (id: #{inspect(id)})")
              end)

            {:error, reason} ->
              Logger.warning("Could not verify commands after :ok response: #{inspect(reason)}")

            _ ->
              Logger.warning(
                "Unexpected response while verifying commands: #{inspect(verify_result)}"
              )
          end

        {:error, reason} ->
          Logger.error("Bulk overwrite failed: #{inspect(reason)}")

        nil ->
          Logger.error(
            "No bulk-overwrite API available or the call failed; ensure Nostrum supports bulk overwrite on this version"
          )
      end

      {:stop, :normal, state}
    end
  end
end
