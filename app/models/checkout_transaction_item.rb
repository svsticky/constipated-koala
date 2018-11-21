# :nodoc:
class CheckoutTransactionItem < ApplicationRecord
  belongs_to :checkout_transaction
  belongs_to :checkout_product_type
end
