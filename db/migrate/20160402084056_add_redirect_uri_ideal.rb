class AddRedirectUriIdeal < ActiveRecord::Migration
  def change
    add_column :ideal_transactions, :redirect_uri, :string, after: :transaction_id
  end
end
