#:nodoc:
class CheckoutBalanceZeroByDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :checkout_balances, :balance, from: nil, to: 0
  end
end
