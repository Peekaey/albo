defmodule Albo.Commands.RemindUserToDisconnect do
  @behaviour Albo.Command

  require Logger

  @impl true
  def name, do: "remind_someone_to_disconnect"

  @impl true
  def register_payload do
    %{
      name: name(),
      description: "reminds someone about the right to disconnect",
      options: [
        %{
          name: "wagie",
          description: "User to remind (select from dropdown)",
          # Discord option type 6 = USER
          type: 6,
          required: true
        }
      ]
    }
  end

  @impl true
  def handle_interaction(interaction) do
    data = Map.get(interaction, "data", Map.get(interaction, :data, %{}))


    # Find the option value (user id) provided
    user_id =
      data
      |> Map.get("options", Map.get(data, :options, []))
      |> Enum.find_value(fn
        %{"name" => "wagie", "value" => v} -> v
        %{name: "wagie", value: v} -> v
        _ -> nil
      end)

      # Spawn task to get video data before responding to avoid timeouts
      Task.start(fn ->
        Process.sleep(100)

        content = "<@#{user_id}> — The right to disconnect is now law. Because if you're not being paid 24 hours a day, you shouldn't be on call 24 hours a day"

        token = Map.get(interaction, "token", Map.get(interaction, :token))

        case Albo.Utils.Helpers.get_right_to_disconnect_video() do
          nil ->
            Logger.error("Failed to get right to disconnect video")
            case Nostrum.Api.Interaction.create_followup_message(token, %{content: "#{content}\n\n_(Video unavailable)_"}) do
              {:ok, _} -> Logger.info("Sent error message to user #{user_id}")
              {:error, reason} ->
                Logger.error("Failed to send error message: #{inspect(reason)}")
            end

          file ->
            case Nostrum.Api.Interaction.create_followup_message(token, %{content: content, files: [file]}) do
              {:ok, _} -> Logger.info("Reminder sent to user #{user_id}")
              {:error, reason} ->
                Logger.error("Failed to send reminder message: #{inspect(reason)}")
            end
        end
      end)

    # Type 5 = DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE - ACK an interaction and edit a response later, the user sees a loading state
    {:reply, %{type: 5}}
  end
end
