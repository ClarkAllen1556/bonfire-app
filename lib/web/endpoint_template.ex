defmodule Bonfire.Web.EndpointTemplate do
defmacro __using__(_) do
quote do
  use Bonfire.ErrorReporting # make sure this comes before the Phoenix endpoint
  use Phoenix.Endpoint, otp_app: :bonfire

  import Bonfire.Common.Extend
  alias Bonfire.Common.Utils
  alias Bonfire.Common.Config

  use_if_enabled Absinthe.Phoenix.Endpoint

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_bonfire_key",
    signing_salt: Config.get!(:signing_salt),
    encryption_salt: Config.get!(:encryption_salt)
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]

  if module_enabled?(Bonfire.API.GraphQL.UserSocket) do
    socket "/api/socket", Bonfire.API.GraphQL.UserSocket,
      websocket: true,
      longpoll: false
  end

  # plug Plug.Static,
  #   at: "/data/uploads",
  #   from: {:bonfire, "data/uploads"},
  #   gzip: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :bonfire,
    gzip: true,
    only: ~w(css fonts images js favicon.ico robots.txt cache_manifest.json favicon.ico source.tar.gz)

  plug Plug.Static,
    at: "/data/uploads/",
    from: "data/uploads",
    gzip: true

  plug Plug.Static,
    at: "/",
    from: :livebook,
    gzip: true,
    only: ~w(images js)

  plug Plug.Static,
    at: "/livebook/",
    from: :livebook,
    gzip: true,
    only: ~w(css images js favicon.ico robots.txt cache_manifest.json)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  # FIXME: doesn't work when defined in template macro
  # if code_reloading? do
  #   socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
  #   plug Phoenix.LiveReloader
  #   plug Phoenix.CodeReloader
  #   plug Phoenix.Ecto.CheckRepoStatus, otp_app: :bonfire
  # end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Bonfire.ErrorReporting

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug Bonfire.Web.Router

  def include_assets(conn) do
    js = if Utils.e(conn, :assigns, :current_account, nil) || Utils.e(conn, :assigns, :current_user, nil) do
      static_path("/js/bonfire_live.js")
    else
      static_path("/js/bonfire_basic.js")
    end

    # if Config.get!(:env) == :dev do
    #   "<link phx-track-static rel='stylesheet' href='"<> static_path("/css/bonfire.css") <>"'/> <script defer phx-track-static crossorigin='anonymous' src='"<> js <>"'></script>"
    # else
      (PhoenixGon.View.render_gon_script(conn) |> Phoenix.HTML.safe_to_string) <>
      "<link phx-track-static rel='stylesheet' href='"<> static_path("/css/bonfire.css") <>"'/> <script defer phx-track-static crossorigin='anonymous' src='"<> js <>"'></script> "
    # end
  end

end
end
end
