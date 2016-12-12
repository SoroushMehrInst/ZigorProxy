defmodule ZigorProxy do
  @moduledoc """
  ZigorProxy module is able to proxy sockets from clients to server(s)
  """
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = get_bindings

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ZigorProxy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def get_bindings do
    do_get_bindings Application.get_env(:zigor_proxy, :bindings), []
  end

  defp do_get_bindings([bind | tail], final_binds) do
    import Supervisor.Spec, warn: false
    case bind do
      {:zigcrypt, ip, port} -> do_get_bindings(tail, [worker(Task, [ZigorProxy.Server, :start_listen, [port, ip]]) | final_binds])
      {:sslcrypt, ip, port} -> do_get_bindings(tail, [worker(Task, [ZigorProxy.Server, :start_listen_ssl, [port, ip]]) | final_binds])
      _ -> nil
    end
  end

  defp do_get_bindings([], final_binds) do
    final_binds
  end
end
