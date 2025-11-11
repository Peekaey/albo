import Config

# Load .env at runtime
if File.exists?(".env") do
  ".env"
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.reject(&(&1 == "" || String.trim(&1) |> String.starts_with?("#")))
  |> Enum.each(fn line ->
    case String.split(line, "=", parts: 2) do
      [key, value] ->
        value =
          value
          |> String.trim()
          |> String.trim_leading(~s("))
          |> String.trim_trailing(~s("))
          |> String.trim_leading(~s('))
          |> String.trim_trailing(~s('))

        System.put_env(key, value)

      _ ->
        :ignore
    end
  end)
end

# Configure Nostrum at runtime so it can start the consumer process before shards attempt to connect.
# System.fetch_env!/1 will raise early if the token is missing - fails fast
config :nostrum,
  application_id: System.fetch_env!("DISCORD_APP_ID"),
  token: System.fetch_env!("DISCORD_BOT_TOKEN"),
  consumer: Miori.Consumer,
  intents: [
    # : is an atom and are constants where their name is their value
    :guild_messages,
    :guild_users,
    :direct_messages,
    :message_content,
    :guilds,
    :guild_presences,
    :guild_users
  ]
