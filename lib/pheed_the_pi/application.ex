defmodule PheedThePi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Delete the RPi folder so the real Raspberry PI module can load
    delete_rpi()

    camera = Application.get_env(:picam, :camera, Picam.Camera)

    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      PheedThePiWeb.Endpoint,
      # Starts a worker by calling: PheedThePi.Worker.start_link(arg)
      # {PheedThePi.Worker, arg},
      camera,
      PheedThePi.PythonServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PheedThePi.Supervisor]
    supervisor = Supervisor.start_link(children, opts)

    set_picam_size!()

    supervisor
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PheedThePiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp set_picam_size!(), do:
    if Mix.env == :prod, do: Picam.set_size(1920, 0),
      else: Picam.set_size(720, 0)

  defp delete_rpi() do
    [:code.priv_dir(:pheed_the_pi), "python", "RPi"]
    |> Path.join()
    |> File.rm_rf()

    if Mix.env != :prod do
      destination =
        [:code.priv_dir(:pheed_the_pi), "python", "RPi"]
        |> Path.join()

        [:code.priv_dir(:pheed_the_pi), "RPi"]
        |> Path.join()
        |> File.cp_r(destination)
    end
  end
end
