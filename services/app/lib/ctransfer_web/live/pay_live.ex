defmodule CTransferWeb.PayLive do
  @moduledoc false
  use CTransferWeb, :live_view

  alias CTransfer.Accounts

  @impl true
  def render(assigns) do
    ~H"""

    """
  end

  @impl true
  def mount(_params, session, socket) do
    socket = assign_current_user(socket, session)
    {:ok, socket}
  end

  defp assign_current_user(socket, session) do
    case session do
      %{"user_token" => user_token} ->
        assign_new(socket, :current_user, fn ->
          Accounts.get_user_by_session_token(user_token)
        end)

      %{} ->
        assign_new(socket, :current_user, fn -> nil end)
    end
  end
end
