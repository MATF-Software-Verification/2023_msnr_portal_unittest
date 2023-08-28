defmodule MsnrApiWeb.Router do
  use MsnrApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug MsnrApiWeb.Plugs.TokenAuthentication
  end

  scope "/api", MsnrApiWeb do
    pipe_through :api

    get "/auth/refresh", AuthController, :refresh
    post "/auth/login", AuthController, :login
    get "/auth/logout", AuthController, :logout

    resources "/activity-types", ActivityTypeController, except: [:new, :edit]
    resources "/passwords", PasswordController, only: [:update]
    resources "/registrations", StudentRegistrationController, except: [:new, :edit, :index]

    resources "/semesters", SemesterController, except: [:new, :edit] do
      resources "/registrations", StudentRegistrationController, only: [:index]
      resources "/topics", TopicController, only: [:index, :create]
      resources "/groups", GroupController, only: [:index, :create]
      resources "/activities", ActivityController, only: [:index, :create]
      resources "/assignments", AssignmentController, only: [:index]

      resources "/students", StudentController, except: [:new, :edit] do
        resources "/assignments", AssignmentController, only: [:index]
      end
    end

    resources "/assignments", AssignmentController, only: [:show, :edit] do
      resources "/documents", DocumentController, only: [:index, :create]
    end

    resources "/activities", ActivityController, except: [:new, :edit] do
      resources "/assignments", AssignmentController, only: [:index]
    end

    resources "/documents", DocumentController, only: [:show, :update]
    resources "/activities", ActivityController, only: [:show, :update]
    resources "/assignments", AssignmentController, only: [:show, :update]
    resources "/topics", TopicController, only: [:show, :update, :delete]
    resources "/groups", GroupController, only: [:show, :update]
    resources "/signups", SignupController, only: [:update]
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: MsnrApiWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
