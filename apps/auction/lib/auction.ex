defmodule Auction do
  alias Auction.{Bid, Item, Repo, User, Password}
  import Ecto.Query

  @repo Repo

  def new_item() do
    Item.changeset(%Item{})
  end

  def list_items do
    @repo.all(Item)
  end

  def get_item(id) do
    @repo.get!(Item, id)
  end

  def get_item_by(attrs) do
    @repo.get_by(Item, attrs)
  end

  def get_item_with_bids(id) do
    id
    |> get_item()
    |> @repo.preload(bids: [:user])
  end

  def get_item_with_ordered_bids(id) do
    bids_query =
      from b in Bid,
      order_by: [desc: :inserted_at],
      preload: [:user]

    query =
      from i in Item,
      where: i.id == ^id,
      preload: [bids: ^bids_query]

    @repo.one! query
  end

  def insert_item(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> @repo.insert()
  end

  def edit_item(id) do
    get_item(id)
    |> Item.changeset()
  end

  def update_item(%Auction.Item{} = item, updates) do
    item
    |> Item.changeset(updates)
    |> @repo.update()
  end

  def delete_item(%Item{} = item), do: @repo.delete(item)

  def get_user(id), do: @repo.get!(User, id)

  @doc """
  Retrieves a User from the db matching the provided username and password

  ## Return values

  Depending on what is found in the db, two different values could be returned:

    * an `Auction.User` struct: An `Auction.User` record was found that matched
      the `username` and `password` that was provided
    * `false`: No `Auction.User` could be found with the provided `username`
      and `password`

  You can then use the returned value to determine whether or not the User is
  authorized in your application. If an `Auction.User` is _not_ found based on
  `username`, the computational work of hashing a password is still done.

  ## Examples

    iex> insert_user(%{username: "geo", password: "geo_pass", password_confirmation: "geo_pass", email: "test@example.com"})
    ...> result = get_user_by_username_and_password("geo", "geo_pass")
    ...> match?(%Auction.User{username: "geo"}, result)
    true

    iex> get_user_by_username_and_password("no_user", "bad_password")
    false
  """
  def get_user_by_username_and_password(username, password) do
    with user when not is_nil(user) <- @repo.get_by(User, %{username: username}),
         true <- Password.verify_with_hash(password, user.hashed_password) do
      user
    else
      _ -> Password.dummy_verify()
    end
  end

  def new_user, do: User.changeset_with_password(%User{})

  def insert_user(params) do
    %User{}
    |> User.changeset_with_password(params)
    |> @repo.insert
  end

  def new_bid, do: Bid.changeset(%Bid{})

  def insert_bid(params) do
    %Bid{}
    |> Bid.changeset_bid_item(params)
    |> @repo.insert()
  end

  def get_max_bid_for_item(item_id) do
    query =
      from b in Bid,
      where: b.item_id == ^item_id,
      select: max(b.amount)

    @repo.one(query)
  end

  def get_bids_for_user(user) do
    query =
      from b in Bid,
      where: b.user_id == ^user.id,
      order_by: [desc: :inserted_at],
      preload: :item,
      limit: 10

    @repo.all(query)
  end
end
