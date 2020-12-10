defmodule Auction.FakeRepo do
  alias Auction.Item

  @items [
    %Item{
      id: 1,
      title: "First",
      desc: "first item",
      ends_at: ~N[2020-01-01 00:00:00]
    },
    %Item{
      id: 2,
      title: "Second",
      desc: "second item",
      ends_at: ~N[2020-02-02 00:00:00]
    }
  ]

  def all(Item), do: @items

  def get!(Item, id) do
    Enum.find(@items, fn(item) -> item.id === id end)
  end

  def get_by(Item, map) do
    Enum.find(@items, fn(item) ->
      Enum.all?(Map.keys(map), fn(key) ->
        Map.get(item, key) === map[key]
      end)
    end)
  end
end
