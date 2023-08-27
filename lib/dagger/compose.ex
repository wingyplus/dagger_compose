defmodule Dagger.Compose do
  @moduledoc """
  Provides a service bindings from Docker Compose. Aim to make
  dev environment and CI/CD more closer.
  """

  # TODO: support env-file
  # TODO: support secret

  @doc """
  Attach services in Docker Compose file into container.
  """
  def with_compose(%Dagger.Container{} = container, compose_file, %Dagger.Client{} = client)
      when is_binary(compose_file) do
    compose = YamlElixir.read_from_file!(compose_file)
    with_compose(container, compose, client)
  end

  def with_compose(%Dagger.Container{} = container, compose, %Dagger.Client{} = client)
      when is_map(compose) do
    bind = fn {name, service}, container ->
      container
      |> Dagger.Container.with_service_binding(name, to_service_container(service, client))
    end

    (compose["services"] || [])
    |> Enum.reduce(container, bind)
  end

  defp to_service_container(%{"image" => image} = service, client) do
    container =
      client
      |> Dagger.Client.container()
      |> Dagger.Container.from(image)

    container
    |> with_expose_ports(service["ports"] || [])
    |> with_environment(service["environment"] || %{})
  end

  defp with_expose_ports(container, ports) do
    ports
    |> Enum.reduce(container, &set_exposed_port/2)
  end

  defp with_environment(container, environment) do
    environment
    |> Enum.reduce(container, &set_environment/2)
  end

  defp set_environment({key, value}, container) do
    container
    |> Dagger.Container.with_env_variable(key, value)
  end

  defp set_environment(env, container) when is_binary(env) do
    env =
      case String.split(env, "=") do
        [key, value] -> {key, value}
        key -> {key, ""}
      end

    set_environment(env, container)
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
