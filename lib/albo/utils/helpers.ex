defmodule Albo.Utils.Helpers do

  require Logger

  def get_right_to_disconnect_video() do
    choice = Enum.random(1..6)
    filename = "albo#{choice}.mov"
    filepath = "./assets/#{filename}"

    case File.read(filepath) do
      {:ok, body} ->
        %{name: filename, body: body}

      {:error, reason} ->
        Logger.error("Failed to read #{filepath}: #{inspect(reason)}")
        nil
    end
  end

  def get_turnbull_image() do
    %{
      name: "turnbull.jpg",
      body: File.read!("./assets/turnbull.jpg")
    }
  end
end
