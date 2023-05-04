# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Blogex.Repo.insert!(%Blogex.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

require Logger

alias Blogex.Repo
alias Blogex.Accounts
alias Blogex.Accounts.User

email = "admin@example.com"
password = "roottooradmin"
name = "Admin"

case Repo.get_by(User, email: email) do
  nil ->
    Logger.info("Creating user #{email}")
    Accounts.create_admin_user(%{email: email, password: password, name: name})

  _ ->
    Logger.info("User #{email} already exists")
end
