defmodule Albo.Commands.RemindEveryoneToDisconnect do
  @behaviour Albo.Command

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
  def handle_interaction(interaction) do
    data = Map.get(interaction, "data", Map.get(interaction, :data, %{}))

    content = "@everyone — Just a reminder that the right to disconnect is now law. Because if you're not being paid 24 hours a day, you shouldn't be on call 24 hours a day"

    file_to_send = Albo.Utils.Helpers.get_right_to_disconnect_video()
    response = %{
      type: 4,
      data: %{
        content: content,
        files: [
          %{
            name: file_to_send.name,
            body: file_to_send.body
          }
        ]
      }
    }
    {:reply, response}
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
