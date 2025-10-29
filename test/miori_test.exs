defmodule MioriTest do
  use ExUnit.Case
  doctest Miori

  test "greets the world" do
    assert Miori.hello() == :world
  end
end
