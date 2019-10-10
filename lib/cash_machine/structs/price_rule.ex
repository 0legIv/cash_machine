defmodule CashMachine.PriceRule do
  defstruct min_quantity: nil,
            price_reduction: nil,
            products_with_discount: nil

  @type t() :: %__MODULE__{
          min_quantity: Integer.t(),
          price_reduction: Float.t(),
          products_with_discount: Float.t()
        }

  @doc """
  The price rule fields:
    quantity - the minimum quantity of products needed for the discount

    price_reduction - the percent of the discount
    Example: 1/10 means 10% of discount will be applied

    products_with_discount - percent of products to which the discount will be applied()
    Example: 
  """
  def to_struct(min_quantity, price_reduction, products_with_discount) do
    %__MODULE__{
      min_quantity: min_quantity,
      price_reduction: price_reduction,
      products_with_discount: products_with_discount
    }
  end
end
