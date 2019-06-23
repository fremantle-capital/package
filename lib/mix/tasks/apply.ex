defmodule Mix.Tasks.Wrap.Apply do
  @moduledoc """
  Apply the terraform definition for packages published to the container registry
  """

  use Mix.Task

  @cli_config [
    name: "wrap.apply",
    description: "Deploy packages to the cloud with Terraform",
    about: """
    Examples:

    mix wrap.apply my_package
    mix wrap.apply nested_package.a nested_package.b
    mix wrap.apply nested_package.*

    NOTE: Juice query language https://github.com/rupurt/juice
    """,
    allow_unknown_args: true
  ]

  @shortdoc "Apply terraform definition"
  @spec run([String.t()]) :: no_return
  def run(argv) do
    @cli_config
    |> Optimus.new!()
    |> Optimus.parse!(argv)
    |> Map.fetch!(:unknown)
    |> packages()
    |> Enum.each(&apply/1)
  end

  defp packages(argv), do: argv |> Enum.join(" ") |> Wrap.Packages.query()

  defp apply(package) do
    "terraform"
    |> System.cmd(
      [
        "apply",
        "-auto-approve",
        "-var",
        "release_name=#{Wrap.Package.hyphenize(package.name)}"
      ],
      cd: "./packages/releases/#{package.name}",
      env: Wrap.Env.read(package),
      into: IO.stream(:stdio, :line)
    )
  end
end
