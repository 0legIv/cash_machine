defmodule CashMachine.ProductsStore do
  use GenServer

  alias CashMachine.PriceRule

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_state) do
    state = %{
      "GR1" => %{
        name: "Green tea",
        price: 3.11,
        price_rule: PriceRule.to_struct(2, 1, 0.5)
      },
      "SR1" => %{
        name: "Strawberries",
        price: 5,
        price_rule: PriceRule.to_struct(3, 1 / 10, 1)
      },
      "CF1" => %{
        name: "Coffee",
        price: 11.23,
        price_rule: PriceRule.to_struct(3, 1 / 3, 1)
      }
    }

    {:ok, state}
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
