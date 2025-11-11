defmodule Albo.Command do
  # For Nostrum (Discord Command Interface)
  # Returns command name as string - used for lookup/registration
  @callback name() :: String.t()
  # Returns shape of the command to be sent to Discord
  @callback register_payload() :: map()
  # Receives interaction payload
  @callback handle_interaction(interaction :: map()) ::
              {:reply, map()} | {:defer_and_followup, (-> any()) | nil}
  # Either performs an immediate interaction response using the response_map Or
  # defer and follow up the response with the command logic
end
