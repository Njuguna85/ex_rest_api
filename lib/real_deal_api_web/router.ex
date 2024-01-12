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

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug RealDealApiWeb.Auth.Pipeline
  end

  scope "/api", RealDealApiWeb do
    pipe_through :api

    get "/", DefaultController, :index

    resources "/accounts", AccountController, except: [:new, :edit]

    post "/accounts/sign_in", AccountController, :sign_in

    resources "/users", UserController, except: [:new, :edit]
  end

  scope "/api", RealDealApiWeb do
    pipe_through [:api, :auth]

    get "/accounts/by_id/:id", AccountController, :show
  end
end
