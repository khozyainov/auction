defmodule Auction.Bid do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bids" do
    field(:amount, :integer)
    belongs_to(:item, Auction.Item)
    belongs_to(:user, Auction.User)
    timestamps()
  end

  def changeset(bid, params \\ %{}) do
    bid
    |> cast(params, [:amount, :user_id, :item_id])
    |> validate_required([:amount, :user_id, :item_id])
    |> assoc_constraint(:item)
    |> assoc_constraint(:user)
  end

  def changeset_bid_item(bid, params \\ %{}) do
    bid
    |> changeset(params)
    |> validate_biggest_bid()
  end

  defp validate_biggest_bid(%Ecto.Changeset{changes: %{item_id: item_id}} = changeset) do
    biggest_amount = Auction.get_max_bid_for_item(item_id)
    validate_change(changeset, :amount, fn :amount, amount ->
      if is_integer(biggest_amount) && amount <= biggest_amount do
        [amount: "Bid must be bigger!"]
      else
        []
      end
    end)
  end
end
