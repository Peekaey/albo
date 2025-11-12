defmodule Albo.CommandRegistry do
  @commands [
    Albo.Commands.Ping,
    Albo.Commands.RemindUserToDisconnect,
    Albo.Commands.RemindEveryoneToDisconnect
  ]

  def commands, do: @commands

  def lookup(name) when is_binary(name) do
    Enum.find(@commands, fn mod ->
      function_exported?(mod, :name, 0) and String.downcase(mod.name()) == String.downcase(name)
    end)
  end

  def payloads_for_registration do
    Enum.map(@commands, & &1.register_payload())
  end
end
