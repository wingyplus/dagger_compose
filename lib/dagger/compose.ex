defmodule Dagger.Compose do
  @moduledoc """
  Provides a service bindings from Docker Compose. Aim to make
  dev environment and CI/CD more closer.
  """

  @doc """
  Attach services in Docker Compose file into container.
  """
  # TODO: support env
  # TODO: support volumes
  def with_compose(%Dagger.Container{} = container, compose_file, %Dagger.Query{} = client)
      when is_binary(compose_file) do
    compose = YamlElixir.read_from_file!(compose_file)
    with_compose(container, compose, client)
  end

  def with_compose(%Dagger.Container{} = container, compose, %Dagger.Query{} = client)
      when is_map(compose) do
    (compose["services"] || [])
    |> Enum.reduce(container, binding_service(client))
  end

  defp binding_service(client) do
    fn {name, service}, container ->
      container
      |> Dagger.Container.with_service_binding(name, to_service_container(service, client))
    end
  end

  defp to_service_container(%{"image" => image} = service, client) do
    container =
      client
      |> Dagger.Query.container()
      |> Dagger.Container.from(image)

    (service["ports"] || [])
    |> Enum.reduce(container, &set_exposed_port/2)
  end

  defp set_exposed_port(port, container) when is_binary(port) do
    port =
      case String.split(port, ":") do
        [_, port] ->
          {port, ""} = Integer.parse(port)
          port

        port ->
          {port, ""} = Integer.parse(port)
          port
      end

    set_exposed_port(port, container)
  end

  defp set_exposed_port(port, container) when is_integer(port) do
    container
    |> Dagger.Container.with_exposed_port(port)
  end
end
