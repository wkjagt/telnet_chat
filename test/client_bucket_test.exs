defmodule TelnetChat.ClientBucketTest do
  use ExUnit.Case, async: true

  test "adds clients to bucket" do
    {:ok, bucket} = start_supervised TelnetChat.ClientBucket
    assert TelnetChat.ClientBucket.clients.length == 0

    TelnetChat.ClientBucket.add_client("willem")
    assert TelnetChat.ClientBucket.clients.length == 1
  end
end