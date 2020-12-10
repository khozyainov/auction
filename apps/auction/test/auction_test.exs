defmodule AuctionTest do
  use ExUnit.Case
  alias Auction.{Item, Repo}
  import Ecto.Query
  doctest Auction, import: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "list_items/0" do
    setup do
      {:ok, item1} = Repo.insert(%Item{title: "a"})
      {:ok, item2} = Repo.insert(%Item{title: "b"})
      {:ok, item3} = Repo.insert(%Item{title: "c"})
      %{items: [item1, item2, item3]}
    end

    test "returns all Items", %{items: items} do
      assert items = Auction.list_items()
    end
  end

  describe "get_item/1" do
    setup do
      {:ok, item1} = Repo.insert(%Item{title: "a"})
      {:ok, item2} = Repo.insert(%Item{title: "b"})
      %{items: [item1, item2]}
    end

    test "returns a single item by id", %{items: items} do
      item = Enum.at(items, 1)
      assert item = Auction.get_item(item.id)
    end
  end

  describe "insert_item/1" do
    test "adds an Item to db" do
      count_query = from i in Item, select: count(i.id)
      before_count = Repo.one(count_query)
      {:ok, _item} = Auction.insert_item(%{title: "test item"})
      assert Repo.one(count_query) == before_count + 1
    end

    test "the Item in the database has the attributes provided" do
      attrs = %{title: "test item", desc: "test description"}
      {:ok, item} = Auction.insert_item(attrs)
      assert item.title == attrs.title
      assert item.desc == attrs.desc
    end

    test "returns an error on error" do
      assert {:error, _changeset} = Auction.insert_item(%{foo: :bar})
    end
  end
end
