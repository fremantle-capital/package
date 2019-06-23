defmodule Mix.Tasks.Wrap.Publish do
  @moduledoc """
  Publish the latest docker images that have been built on the local docker instance
  """

  use Mix.Task

  @cli_config [
    name: "wrap.publish",
    description:
      "Publish the latest docker images that have been built on the local docker instance",
    about: """
    Examples:

    mix wrap.publish my_package
    mix wrap.publish nested_package.a nested_package.b
    mix wrap.publish nested_package.*

    NOTE: Juice query language https://github.com/rupurt/juice
    """,
    allow_unknown_args: true
  ]

  @shortdoc "Publish latest docker images"
  @spec run([String.t()]) :: no_return
  def run(argv) do
    @cli_config
    |> Optimus.new!()
    |> Optimus.parse!(argv)
    |> Map.fetch!(:unknown)
    |> packages()
    |> Enum.each(&build/1)
  end

  defp packages(argv), do: argv |> Enum.join(" ") |> Wrap.Packages.query()

  defp build(package) do
    "docker"
    |> System.cmd(
      [
        "push",
        "#{package.registry_image}:latest"
      ],
      into: IO.stream(:stdio, :line)
    )
  end
end
