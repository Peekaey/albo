defmodule Albo.Consumer do
  @moduledoc """
  Nostrum consumer that responds to commands.
  Consumers - process that receives and processes events/messages from a producer.
  """

  use Nostrum.Consumer

  alias Albo.CommandRegistry


  @impl true
  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    # Support both map and struct forms:
    name =
      interaction
      |> Map.get("data", Map.get(interaction, :data, %{}))
      |> (fn data -> Map.get(data, "name", Map.get(data, :name)) end).()

    cond do
      is_nil(name) ->
        :ignore

      module = CommandRegistry.lookup(name) ->
        case module.handle_interaction(interaction) do
          {:reply, response_map} ->
            id = Map.get(interaction, "id", Map.get(interaction, :id))
            token = Map.get(interaction, "token", Map.get(interaction, :token))
            Nostrum.Api.Interaction.create_response(id, token, response_map)
            :ok

          {:defer_and_followup, fun} when is_function(fun, 0) ->
            id = Map.get(interaction, "id", Map.get(interaction, :id))
            token = Map.get(interaction, "token", Map.get(interaction, :token))
            # send deferred response
            Nostrum.Api.Interaction.create_response(id, token, %{type: 5})
            # run long work and send follow-up
            Task.start(fn ->
              result = fun.()
              app_id = Application.fetch_env!(:nostrum, :application_id)

              case result do
                {content, files} when is_list(files) ->
                  # Try to call Interaction.create_followup_message if available
                  Nostrum.Api.Interaction.create_followup_message(app_id, token, %{content: content})

                content when is_binary(content) ->
                  Nostrum.Api.Interaction.create_followup_message(app_id, token, %{content: content})
              end
            end)

            :ok

          other ->
            Logger.warning("Command #{inspect(module)} returned unexpected: #{inspect(other)}")
            :ignore
        end

      true ->
        :ignore
    end
  end

  @impl true
  def handle_event(_), do: :ok
end
