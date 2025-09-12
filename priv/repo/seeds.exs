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
alias PocElixirPhoenix.Categories.Category

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

# Create example categories
categories = [
  %{
    name: "Electronics",
    description: "Electronic devices, gadgets and technology accessories"
  },
  %{
    name: "Clothing & Fashion",
    description: "Apparel, footwear and fashion accessories"
  },
  %{
    name: "Home & Garden",
    description: "Home goods, decoration and gardening supplies"
  },
  %{
    name: "Sports & Fitness",
    description: "Sports equipment, athletic wear and fitness accessories"
  },
  %{
    name: "Books & Media",
    description: "Books, magazines, music, movies and digital content"
  },
  %{
    name: "Health & Beauty",
    description: "Personal care products, cosmetics and supplements"
  },
  %{
    name: "Automotive",
    description: "Vehicles, parts and automotive accessories"
  },
  %{
    name: "Toys & Games",
    description: "Children's toys, board games and entertainment"
  },
  %{
    name: "Food & Beverages",
    description: "Food items, drinks and gourmet products"
  },
  %{
    name: "Tools & Hardware",
    description: "Work tools, DIY supplies and construction equipment"
  },
  %{
    name: "Arts & Crafts",
    description: "Art supplies, craft materials and creative products"
  },
  %{
    name: "Pet Supplies",
    description: "Pet products and accessories"
  },
  %{
    name: "Office & Stationery",
    description: "Office supplies, stationery and school materials"
  },
  %{
    name: "Music & Instruments",
    description: "Musical instruments and audio equipment"
  },
  %{
    name: "Services",
    description: "Professional services and consulting"
  }
]

Enum.each(categories, fn category_attrs ->
  case Repo.get_by(Category, name: category_attrs.name) do
    nil ->
      %Category{}
      |> Category.changeset(category_attrs)
      |> Repo.insert!()
      |> IO.inspect(label: "Created category")

    existing_category ->
      IO.puts("Category #{existing_category.name} already exists")
  end
end)
