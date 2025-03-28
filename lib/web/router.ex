defmodule Bonfire.Web.Router do
  use Bonfire.Web, :router
  # use Plug.ErrorHandler
  alias Bonfire.Common.Config

  pipeline :basic do
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {Bonfire.UI.Social.Web.LayoutView, :root}
    plug Bonfire.Web.Plugs.LoadCurrentUser
  end

  pipeline :browser do
    plug :accepts, ["html", "activity+json", "json", "ld+json"]
    plug :fetch_session
    plug PhoenixGon.Pipeline,
      assets: Map.new(Config.get(:js_config, []))
    plug :put_root_layout, {Bonfire.UI.Social.Web.LayoutView, :root}
    plug Cldr.Plug.SetLocale,
      default: Bonfire.Web.Localise.default_locale,
	    apps: [:cldr, :gettext],
	    from: [:session, :cookie, :accept_language],
	    gettext: Bonfire.Web.Gettext,
	    cldr: Bonfire.Web.Cldr
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Bonfire.Web.Plugs.ActivityPub
    plug Bonfire.Web.Plugs.LoadCurrentAccount
    plug Bonfire.Web.Plugs.LoadCurrentUser
    # plug Bonfire.Web.Plugs.Locale # TODO: skip guessing a locale if the user has one in preferences
  end

  pipeline :guest_only do
    plug Bonfire.Web.Plugs.GuestOnly
  end

  pipeline :account_required do
    plug Bonfire.Web.Plugs.AccountRequired
  end

  pipeline :user_required do
    plug Bonfire.Web.Plugs.UserRequired
  end

  pipeline :admin_required do
    plug Bonfire.Web.Plugs.AdminRequired
  end


  # include routes for active Bonfire extensions (no need to comment out, they'll be skipped if not available or if disabled)

  # use_if_enabled Bonfire.Website.Web.Routes

  use_if_enabled Bonfire.Me.Web.Routes
  use_if_enabled Bonfire.Social.Web.Routes

  use_if_enabled Bonfire.Search.Web.Routes
  use_if_enabled Bonfire.Tag.Web.Routes
  use_if_enabled Bonfire.Classify.Web.Routes
  use_if_enabled Bonfire.Geolocate.Web.Routes

  use_if_enabled Bonfire.UI.Reflow.Routes
  use_if_enabled Bonfire.UI.Coordination.Routes
  use_if_enabled Bonfire.UI.Kanban.Routes
  use_if_enabled Bonfire.Breadpub.Web.Routes
  use_if_enabled Bonfire.Recyclapp.Routes
  use_if_enabled Bonfire.Upcycle.Web.Routes

  # include GraphQL API
  use_if_enabled Bonfire.API.GraphQL.Router

  # include federation routes
  use_if_enabled ActivityPubWeb.Router

  # include nodeinfo routes
  use_if_enabled NodeinfoWeb.Router

  # optionally include Livebook for developers
  use_if_enabled Bonfire.Livebook.Web.Routes

  # optionally include Surface Catalogue for the stylebook
  require_if_enabled Surface.Catalogue.Router


  ## Below you can define routes specific to your flavour of Bonfire (which aren't handled by extensions)

  # pages anyone can view
  scope "/" do
    pipe_through :browser

    live "/", Bonfire.Web.HomeLive, as: :home
    # a default homepage which you can customise (at path "/")
    # can be replaced with something else (eg. bonfire_website extension or similar), in which case you may want to rename the path (eg. to "/home")
    # live "/", Website.HomeGuestLive, as: :landing
    # live "/home", Web.HomeLive, as: :home

    live "/error", Bonfire.Common.Web.ErrorLive

  end

  # pages only guests can view
  scope "/", Bonfire do
    pipe_through :browser
    pipe_through :guest_only
  end

  # pages you need an account to view
  scope "/", Bonfire do
    pipe_through :browser
    pipe_through :account_required
 end

  # pages you need to view as a user
  scope "/", Bonfire do
    pipe_through :browser
    pipe_through :user_required
  end

  # pages only admins can view
  scope "/settings/admin" do
    pipe_through :browser
    pipe_through :admin_required
  end




  scope "/" do
    pipe_through :browser

    # if module_enabled?(Surface.Catalogue.Router) do # FIXME - getting function surface_catalogue/1 is undefined or private
    #   Surface.Catalogue.Router.surface_catalogue "/ui/"
    # end

    if module_enabled?(Phoenix.LiveDashboard.Router) do
      import Phoenix.LiveDashboard.Router
      pipe_through :admin_required

      live_dashboard "/admin/system",
        ecto_repos: [Bonfire.Repo],
        ecto_psql_extras_options: [long_running_queries: [threshold: "400 milliseconds"]],
        metrics: Bonfire.Web.Telemetry,
        # metrics: FlamegraphsWeb.Telemetry,
        additional_pages: [
          flame_on: FlameOn.DashboardPage
        ]
    end

  end

  if Mix.env() in [:dev, :test] do
    scope "/" do
      pipe_through :browser

      if module_enabled?(Bamboo.SentEmailViewerPlug) do
        forward "/admin/emails", Bamboo.SentEmailViewerPlug
      end
    end
  end

end
defmodule Bonfire.Web.Router.Reverse do
  import Voodoo, only: [def_reverse_router: 2]
  import Where
  def_reverse_router :path, for: Bonfire.Web.Router

  # def path(_conn_or_socket_or_endpoint, name, _arg1) do
  #   error(name, "no path defined for type")
  #   nil
  # end
end
