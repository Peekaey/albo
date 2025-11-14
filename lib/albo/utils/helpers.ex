defmodule Albo.Utils.Helpers do



  def get_right_to_disconnect_video() do
    choice = Enum.random(1..6)

    case choice do
      1 -> %{
        name: "albo1.mov",
        body: File.read!("./assets/albo1.mov")
      }
      2 -> %{
        name: "albo2.mov",
        body: File.read!("./assets/albo2.mov")
      }
      3 -> %{
        name: "albo3.mov",
        body: File.read!("./assets/albo3.mov")
      }
      4 -> %{
        name: "albo4.mov",
        body: File.read!("./assets/albo4.mov")
      }
      5 -> %{
        name: "albo5.mov",
        body: File.read!("./assets/albo5.mov")
      }
      6 -> %{
        name: "albo6.mov",
        body: File.read!("./assets/albo6.mov")
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
