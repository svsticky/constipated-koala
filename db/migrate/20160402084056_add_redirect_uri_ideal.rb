#:nodoc:
class AddRedirectUriIdeal < ActiveRecord::Migration[4.2]
  def change
    add_column :ideal_transactions, :redirect_uri, :string, after: :transaction_id
  end
end
