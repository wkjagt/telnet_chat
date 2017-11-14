defmodule TelnetChatTest do
  use ExUnit.Case
  doctest TelnetChat

  test "greets the world" do
    assert TelnetChat.hello() == :world
  end
end
