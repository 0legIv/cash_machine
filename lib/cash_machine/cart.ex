defmodule CashMachine.Cart do
  use GenServer

  alias CashMachine.ProductsStore

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    state = %{
      products: %{},
      total: 0
    }

    {:ok, state}
  end

  def clean() do
    GenServer.call(__MODULE__, :clean)
  end

  @spec add_product(String.t()) :: :ok | :wrong_product
  def add_product(product) do
    GenServer.call(__MODULE__, {:add_product, product})
  end

  @spec calculate_total(map(), map()) :: float()
  def calculate_total(cart, products_store) do
    Enum.reduce(cart, 0, fn {product, quantity}, total_price ->
      case Map.get(products_store[product], :price_rule) do
        nil ->
          calculate(products_store, product, quantity, nil)

        price_rule ->
          min_quantity = Map.get(price_rule, :min_quantity, 0)
          total_price + calculate(products_store, product, quantity, min_quantity)
      end
    end)
  end

  @spec calculate(map(), String.t(), integer(), integer()) :: float()
  def calculate(products_store, product, quantity, min_quantity)
      when quantity >= min_quantity and min_quantity != nil do
    price_rule = get_in(products_store, [product, :price_rule])
    product_price = get_in(products_store, [product, :price])
    items_with_discount = trunc(quantity * price_rule.products_with_discount)
    with_discount_price = items_with_discount * product_price * (1 - price_rule.price_reduction)
    without_discount_price = (quantity - items_with_discount) * product_price

    (with_discount_price + without_discount_price)
    |> Float.round(2)
  end

  def calculate(products, product, quantity, _) do
    product_price = get_in(products, [product, :price])
    product_price * quantity
  end

  def get_cart do
    GenServer.call(__MODULE__, :get_cart)
  end

  def handle_call(:get_cart, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:clean, _from, _state) do
    new_state = %{
      products: %{},
      total: 0
    }

    {:reply, :ok, new_state}
  end

  def handle_call({:add_product, product}, _from, state) do
    products_store = ProductsStore.get_state()

    if Map.has_key?(products_store, product) do
      quantity = Map.get(state.products, product, 0) + 1
      new_state = put_in(state, [:products, product], quantity)
      total = calculate_total(new_state.products, products_store)

      {:reply, :ok, put_in(new_state, [:total], total)}
    else
      {:reply, :wrong_product, state}
    end
  end
end
