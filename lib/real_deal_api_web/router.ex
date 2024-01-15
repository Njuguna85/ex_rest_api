defmodule RealDealApiWeb.Router do
  use RealDealApiWeb, :router
  use Plug.ErrorHandler

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{reason: %{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, map) do
    conn |> halt()
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :auth do
    plug RealDealApiWeb.Auth.Pipeline
    plug RealDealApiWeb.Auth.SetAccount
  end

  scope "/api", RealDealApiWeb do
    pipe_through :api

    get "/", DefaultController, :index

    post "/accounts", AccountController, :create
    post "/accounts/sign_in", AccountController, :sign_in
  end

  scope "/api", RealDealApiWeb do
    pipe_through [:api, :auth]

    resources "/users", UserController, except: [:new, :edit]

    get "/accounts/by_id/:id", AccountController, :show
    get "/accounts/current/", AccountController, :current_account_session

    get "/accounts/sign_out", AccountController, :sign_out
    get "/accounts/refresh_session", AccountController, :refresh_session

    get "/accounts", AccountController, :index
    get "/accounts/:id", AccountController, :show
    patch "/accounts/:id", AccountController, :update
    put "/accounts/:id", AccountController, :update
    delete "/accounts/:id", AccountController, :delete
  end
end
