defmodule DemonSpiritWeb.GithubDeployView do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="">
      <div>
        <div>
          <button phx-click="github_deploy">Deploy to GitHub</button>
        </div>
        Status: <%= @deploy_step %>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, deploy_step: "Ready!")}
  end

  def handle_event("github_deploy", _value, socket) do
    s = self()

    spawn(fn ->
      :timer.sleep(1000)
      send(s, :create_org)
    end)

    {:noreply, assign(socket, deploy_step: "Starting deploy...")}
  end

  def handle_info(:create_org, socket) do
    s = self()

    spawn(fn ->
      :timer.sleep(1000)
      send(s, {:create_repo, "org"})
    end)

    {:noreply, assign(socket, deploy_step: "Creating GitHub org...")}
  end

  def handle_info({:create_repo, _org}, socket) do
    s = self()

    spawn(fn ->
      :timer.sleep(1000)
      send(s, {:push_contents, "repo"})
    end)

    {:noreply, assign(socket, deploy_step: "Creating GitHub repo...")}
  end

  def handle_info({:push_contents, _repo}, socket) do
    s = self()

    spawn(fn ->
      :timer.sleep(1000)
      send(s, :done)
    end)

    {:noreply, assign(socket, deploy_step: "Pushing to repo...")}
  end

  def handle_info(:done, socket) do
    {:noreply, assign(socket, deploy_step: "Done!")}
  end
end
