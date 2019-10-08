defmodule CashMachineTest do
  use ExUnit.Case
  doctest CashMachine

  test "greets the world" do
    assert CashMachine.hello() == :world
  end
end
