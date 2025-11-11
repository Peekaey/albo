defmodule AlboTest do
  use ExUnit.Case
  doctest Albo

  test "greets the world" do
    assert Albo.hello() == :world
  end
end
