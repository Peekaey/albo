defmodule Albo.Commands.DisconnectCheck do
  @behaviour Albo.Command

  @impl true
  def name, do: "disconnect_check"

  @impl true
  def register_payload do
    %{
      name: name(),
      description: "checks if someone has disconnected after work hours",
      options: [
        %{
          name: "wagie",
          description: "User to check (select from dropdown)",
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

    user_id =
      data
      |> Map.get("options", Map.get(data, :options, []))
      |> Enum.find_value(fn
        %{"name" => "wagie", "value" => v } -> v
        %{name: "wagie", value: v } -> v
        _ -> nil
      end)
    content = "<@#{user_id}> — Have you disconnected today? If not, please do so now"

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
end
