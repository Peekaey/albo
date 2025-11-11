defmodule Albo.Commands.RemindToDisconnect do
  @behaviour Albo.Command

  @impl true
  def name, do: "remind_to_disconnect"

  @impl true
  @spec register_payload() :: %{
          description: <<_::360>>,
          name: <<_::160>>,
          options: [%{description: <<_::296>>, name: <<_::40>>, required: true, type: 6}, ...]
        }
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

      content = "<@#{user_id}> — The right to disconnect is now law. Because if you're not being paid 24 hours a day, you shouldn't be on call 24 hours a day"

  response = %{
    type: 4, 
    data: %{
      content: content,
      files: [
        %{
          name: "albo1.mov",
          body: File.read!("./assets/albo1.mov")
        }
      ]
    }
  }

  {:reply, response}

  end
end
