# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PocElixirPhoenix.Repo.insert!(%PocElixirPhoenix.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PocElixirPhoenix.Repo
alias PocElixirPhoenix.Accounts.User

# Create example users with different roles
users = [
  %{
    email: "superuser@example.com",
    password: "superuser123456",
    role: "superuser"
  },
  %{
    email: "admin@example.com",
    password: "admin123456789",
    role: "admin"
  },
  %{
    email: "user@example.com",
    password: "user123456789",
    role: "user"
  }
]

Enum.each(users, fn user_attrs ->
  case Repo.get_by(User, email: user_attrs.email) do
    nil ->
      %User{}
      |> User.email_changeset(user_attrs)
      |> User.password_changeset(user_attrs)
      |> User.role_changeset(user_attrs)
      |> User.confirm_changeset()
      |> Repo.insert!()
      |> IO.inspect(label: "Created user")

    existing_user ->
      IO.puts("User #{existing_user.email} already exists")
  end
end)
