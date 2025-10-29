defmodule Miori.Consumer do
  @moduledoc """
  Nostrum consumer that responds to commands.
  Consumers - process that receives and processes events/messages from a producer.
  """

  use Nostrum.Consumer

  alias Nostrum.Api

  @impl true
  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!hello" ->
        # Create a message in the channel where the command was issued.
        # Pattern-match to raise on unexpected error during development.
        {:ok, _message} = Api.Message.create_message(msg.channel_id, "Hello, world!")
        :ok

      _ ->
        :ignore
    end
  end

  # Ignore any other events
  @impl true
  def handle_event(_), do: :ok
end
