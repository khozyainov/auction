defmodule AuctionWeb.ItemView do
  use AuctionWeb, :view

  def active_item_bidding?(ends_at) do
    case DateTime.compare(ends_at, DateTime.utc_now()) do
      :gt -> true
      _ -> false
    end
  end
end
