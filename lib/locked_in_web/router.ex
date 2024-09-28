defmodule LockedInWeb.Router do
  # alias LockedInWeb.NotificationController
  use LockedInWeb, :router

  import LockedInWeb.UserAuth
  # alias LockedInWeb.UserSessionController
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LockedInWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    # plug :protect_from_forgery
    # plug Plug.CSRFProtection
  end

  pipeline :authenticted do
    plug :fetch_current_user
    plug :require_authenticated_user
  end

  pipeline :authorized do
    plug :authorize
  end

  pipeline :is_admin do
    plug :admin
  end

  # scope "/", LockedInWeb do
  #   pipe_through :browser

  #   get "/", PageController, :home
  # end

  # Other scopes may use custom stacks.
  scope "/api", LockedInWeb do
    pipe_through :api
    get "/test", UserController, :test
    post "/register", UserRegistrationController, :create
    post "/login", UserSessionController, :create
    delete "/logout", UserSessionController, :delete
    pipe_through :authenticted
    # get "/test", UserController, :test
    get "/me", UserController, :show
    get "/posts/:post_id", PostController, :show
    post "/connect/:requestee_id", ConnectionController, :request
    patch "/connect/:requester_id", ConnectionController, :accept
    delete "/connect/:id", ConnectionController, :delete
    get "/connections", ConnectionController, :index
    get "/connections/requests", ConnectionController, :request_index
    get "/users/:user_id/liked_posts", UserController, :liked_posts
    get "/feed", UserController, :feed
    get "/skills", SkillController, :index

    # get "/users/:user_id/profile", UserController, :profile
    resources "/posts", PostController, except: [:new, :edit], param: "post_id"
    scope "/posts/:post_id" do
      post "/view", PostController, :mark_viewed
      resources "/comments", CommentController, only: [:create, :show, :index , :delete], param: "comment_id"
    end
    scope "/notifications"  do
      get "/", NotificationController, :index
      patch "/:notification_id", NotificationController, :update
    end
    resources "/chats", ChatController, only: [:create, :show, :index, :delete], param: "user2_id"
    scope "/chats/:user2_id" do
      patch "/messages", MessageController, :update
      resources "/messages", MessageController, only: [:create,  :index], param: "message_id"
    end
    get "/notifications", UserController, :notifications
    patch "/notifications", UserController, :read_notifications
    get "/jobs/feed", JobController, :feed
    resources "/jobs", JobController, only: [:create, :show, :index, :delete], param: "job_id"
    scope "/jobs/:job_id" do
      post "/", JobController, :mark_viewed
      resources "/applications", ApplicationController, only: [:create, :show, :index, :delete], param: "application_id"

    end
    scope "/users" do
      patch "/profile", UserController, :update
      get "/profile/:user_id", UserController, :profile
      patch "/email_change", UserController, :update
      patch "/password_change", UserController, :update
    end

    delete "/like/:post_id", PostController, :unlike
    post "/like/:post_id", PostController, :like
    pipe_through :authorized
    resources "/users", UserController, except: [:new, :create, :edit], param: "user_id"
    scope "/users/:user_id" do
      get "/profile", UserController, :profile
      resources "/posts", PostController, except: [:new, :show, :edit], param: "post_id"
      scope "/posts/:post_id" do
          resources "/comments", CommentController, only: [:create, :delete], param: "comment_id"
      end
    end
  end
  scope "/api", LockedInWeb do
    pipe_through [:api, :authenticted, :is_admin]
    scope "/admin" do
      get "/export_xml", ExportController, :export_xml
      get "users/export", ExportController, :export
      resources "/users", UserController, except: [:new, :create, :edit], param: "user_id"
      scope "/users/:user_id" do
        resources "/posts", UserController, except: [:new, :show, :edit], param: "post_id"
        scope "/posts/:post_id" do
          resources "/comments", UserController, only: [:create, :delete], param: "comment_id"
        end
      end
    end
  end


  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:locked_in, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LockedInWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # ## Authentication routes

  # scope "/", LockedInWeb do
  #   pipe_through [:browser, :redirect_if_user_is_authenticated]

  #   get "/users/register", UserRegistrationController, :new
  #   post "/users/register", UserRegistrationController, :create
  #   get "/users/log_in", UserSessionController, :new
  #   post "/users/log_in", UserSessionController, :create
  #   get "/users/reset_password", UserResetPasswordController, :new
  #   post "/users/reset_password", UserResetPasswordController, :create
  #   get "/users/reset_password/:token", UserResetPasswordController, :edit
  #   put "/users/reset_password/:token", UserResetPasswordController, :update
  # end

  # scope "/", LockedInWeb do
  #   pipe_through [:browser, :require_authenticated_user]

  #   get "/users/settings", UserSettingsController, :edit
  #   put "/users/settings", UserSettingsController, :update
  #   get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  # end

  # scope "/", LockedInWeb do
  #   pipe_through [:browser]

  #   delete "/users/log_out", UserSessionController, :delete
  #   get "/users/confirm", UserConfirmationController, :new
  #   post "/users/confirm", UserConfirmationController, :create
  #   get "/users/confirm/:token", UserConfirmationController, :edit
  #   post "/users/confirm/:token", UserConfirmationController, :update
  # end
end
