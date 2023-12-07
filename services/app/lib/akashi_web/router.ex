defmodule AkashiWeb.Router do
  use AkashiWeb, :router

  import AkashiWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AkashiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AkashiWeb do
    pipe_through :browser

    # get "/", PageController, :home
    live "/", HomeLive
  end

  # Other scopes may use custom stacks.
  scope "/api", AkashiWeb do
    pipe_through :api

    post "/rpc", RPCController, :webhook
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:akashi, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AkashiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AkashiWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{AkashiWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      # live "/users/register", UserRegistrationLive, :new
      # live "/users/log_in", UserLoginLive, :new
      # live "/users/reset_password", UserForgotPasswordLive, :new
      # live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", AkashiWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{AkashiWeb.UserAuth, :ensure_authenticated}] do
      # live "/users/settings", UserSettingsLive, :edit
      # live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/payments", PaymentLive.Index, :index
      live "/payments/new", PaymentLive.Index, :new
      live "/payments/:id/edit", PaymentLive.Index, :edit
      live "/payments/:id", PaymentLive.Show, :show
      live "/payments/:id/show/edit", PaymentLive.Show, :edit
    end
  end

  scope "/", AkashiWeb do
    pipe_through [:browser]
    delete "/users/log_out", UserSessionController, :delete
    live "/payments/:id/send", PaymentLive.Send
    live "/bounties", BountyLive.Index, :index
    live "/bounties/new", BountyLive.Index, :new
    live "/bounties/:id/edit", BountyLive.Index, :edit
    live "/bounties/:id", BountyLive.Show, :show
    live "/bounties/:id/show/edit", BountyLive.Show, :edit

    live_session :current_user,
      on_mount: [{AkashiWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
