defmodule Albo.Utils.Helpers do



  def get_right_to_disconnect_video() do
    choice = Enum.random(1..2)

    case choice do
      1 -> %{
        name: "albo1.mov",
        body: File.read!("./assets/albo1.mov")
      }
      2 -> %{
        name: "albo2.mov",
        body: File.read!("./assets/albo2.mov")
      }
    end
  end

  def get_turnbull_image() do
    %{
      name: "turnbull.jpg",
      body: File.read!("./assets/turnbull.jpg")
    }
  end
end
