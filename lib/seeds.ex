defmodule Blogex.Seeds do
  alias Blogex.Accounts

  def run do
    email = System.get_env("ADMIN_EMAIL") || "admin@admin.com"
    password = System.get_env("ADMIN_PASSWORD") || "roottooradmin"
    name = System.get_env("ADMIN_NAME") || "Admin"
    Accounts.create_admin_user(%{email: email, password: password, name: name})
  end
end
