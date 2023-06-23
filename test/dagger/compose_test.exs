defmodule Dagger.ComposeTest do
  use ExUnit.Case
  doctest Dagger.Compose

  setup do
    client = Dagger.connect!()
    on_exit(fn -> Dagger.close(client) end)

    %{client: client}
  end

  test "binding port", %{client: client} do
    client
    |> Dagger.Query.container()
    |> Dagger.Container.from("redis")
    |> Dagger.Compose.with_compose("docker-compose.yaml", client)
    |> Dagger.Container.with_entrypoint(["redis-cli", "-h", "redis-srv"])
    |> Dagger.Container.with_exec(["set", "foo", "abc"])
    |> Dagger.Container.with_exec(["save"])
    |> Dagger.Container.with_exec(["get", "foo"])
    |> Dagger.Container.sync()
  end
end
