defmodule CartTest do
  use ExUnit.Case

  alias CashMachine.Cart
  alias CashMachine.ProductsStore

  @test_products ["GR1", "SR1", "CF1"]
  @wrong_products ["WR2", "WR1", "WR3"]

  @test_cart1 %{"GR1" => 3, "SR1" => 1, "CF1" => 1}
  @test_cart2 %{"GR1" => 2}
  @test_cart3 %{"SR1" => 3, "GR1" => 1}
  @test_cart4 %{"GR1" => 1, "CF1" => 3, "SR1" => 1}

  setup do
    Cart.clean()
  end

  describe "Cart state" do
    test "add products to the cart correctly" do
      assert Enum.all?(@test_products, fn product -> Cart.add_product(product) == :ok end)

      assert Enum.all?(@test_products, fn product ->
               Map.has_key?(Cart.get_cart()[:products], product)
             end)
    end

    test "add products to the cart that doesn't exist" do
      assert Enum.all?(@wrong_products, fn product ->
               Cart.add_product(product) == :wrong_product
             end)

      assert Cart.get_cart()[:products] == %{}
    end
  end

  describe "calculate/4" do
    test "calculate price of GR1 when the quantity is 1" do
      products = ProductsStore.get_state()

      assert Cart.calculate(products, "GR1", 1, 2) == 3.11
    end

    test "calculate price of GR1 when the quantity is more or equal 2" do
      products = ProductsStore.get_state()
      price = get_in(products, ["GR1", :price])
      assert Cart.calculate(products, "GR1", 2, 2) == price
      assert Cart.calculate(products, "GR1", 3, 2) == price * 2
      assert Cart.calculate(products, "GR1", 4, 2) == price * 2
      assert Cart.calculate(products, "GR1", 5, 2) == price * 3
    end

    test "calculate price of SR1 when the quantity is less than 3" do
      products = ProductsStore.get_state()
      price = get_in(products, ["SR1", :price])
      assert Cart.calculate(products, "SR1", 1, 3) == price
      assert Cart.calculate(products, "SR1", 2, 3) == price * 2
    end

    test "calculate price of SR1 when the quantity is more or equal 3" do
      products = ProductsStore.get_state()
      price_after_discount = 4.5
      assert Cart.calculate(products, "SR1", 3, 2) == price_after_discount * 3
      assert Cart.calculate(products, "SR1", 4, 2) == price_after_discount * 4
      assert Cart.calculate(products, "SR1", 5, 2) == price_after_discount * 5
    end

    test "calculate price of CF1 when the quantity is less than 3" do
      products = ProductsStore.get_state()
      price = get_in(products, ["CF1", :price])
      assert Cart.calculate(products, "CF1", 1, 3) == price
      assert Cart.calculate(products, "CF1", 2, 3) == price * 2
    end

    test "calculate price of CF1 when the quantity is more or equal 3" do
      products = ProductsStore.get_state()
      price = get_in(products, ["CF1", :price])
      assert Cart.calculate(products, "CF1", 3, 2) == (price * 3 * 2 / 3) |> Float.round(2)
      assert Cart.calculate(products, "CF1", 4, 2) == (price * 4 * 2 / 3) |> Float.round(2)
      assert Cart.calculate(products, "CF1", 5, 2) == (price * 5 * 2 / 3) |> Float.round(2)
    end
  end

  describe "calculate_total/2" do
    test "calculate total price for products from test_cart1" do
      products = ProductsStore.get_state()

      assert Cart.calculate_total(@test_cart1, products) == 22.45
    end

    test "calculate total price for products from test_cart2" do
      products = ProductsStore.get_state()

      assert Cart.calculate_total(@test_cart2, products) == 3.11
    end

    test "calculate total price for products from test_cart3" do
      products = ProductsStore.get_state()

      assert Cart.calculate_total(@test_cart3, products) == 16.61
    end

    test "calculate total price for products from test_cart4" do
      products = ProductsStore.get_state()

      assert Cart.calculate_total(@test_cart4, products) == 30.57
    end
  end
end
