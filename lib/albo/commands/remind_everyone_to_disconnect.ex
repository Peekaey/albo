defmodule Albo.Commands.RemindEveryoneToDisconnect do
  @behaviour Albo.Command

  require Logger

  @impl true
  def name, do: "remind_everyone_to_disconnect"

  @impl true
  def register_payload do
    %{
      name: name(),
      description: "reminds everyone in the channel about the right to disconnect",
      options: []
    }
  end

  @impl true
  @spec handle_interaction(map()) :: {:reply, %{type: 5}}
  def handle_interaction(interaction) do
    _data = Map.get(interaction, "data", Map.get(interaction, :data, %{}))

    Task.start(fn ->
      Process.sleep(100)

      content = "@everyone — Just a reminder that the right to disconnect is now law. Because if you're not being paid 24 hours a day, you shouldn't be on call 24 hours a day"

      token = Map.get(interaction, "token", Map.get(interaction, :token))

      case Albo.Utils.Helpers.get_right_to_disconnect_video() do
        nil ->
          Logger.error("Failed to get right to disconnect video")
          case Nostrum.Api.Interaction.create_followup_message(token, %{content: "#{content}\n\n_(Video unavailable)_"}) do
            {:ok, _} -> Logger.info("Sent error message to channel")
            {:error, reason} ->
              Logger.error("Failed to send error message: #{inspect(reason)}")
          end

        file ->
          case Nostrum.Api.Interaction.create_followup_message(token, %{content: content, files: [file]}) do
            {:ok, _} -> Logger.info("Reminder sent to channel")
            {:error, reason} ->
              Logger.error("Failed to send reminder: #{inspect(reason)}")
          end
      end
    end)

    # Type 5 = DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE - ACK an interaction and edit a response later, the user sees a loading state
    {:reply, %{type: 5}}
  end


  def remind_everyone_to_disconnect_background_job(channel_id) do
    content = "@everyone — It is now 5PM on a weekday. Just a reminder that the right to disconnect is now law. Because if you're not being paid 24 hours a day, you shouldn't be on call 24 hours a day"

    file_to_send = Albo.Utils.Helpers.get_right_to_disconnect_video()

    # Binaries are strings - convert to integer before sending as Channel.Id is of type int and will crash if passed as string
    channel_id_int = if is_binary(channel_id), do: String.to_integer(channel_id), else: channel_id

    Nostrum.Api.Message.create(channel_id_int,
      content: content,
      file: file_to_send
    )
  end
end
