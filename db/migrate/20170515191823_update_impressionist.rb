class UpdateImpressionist < ActiveRecord::Migration[5.1]
  def change
    add_column :impressions, :params, :text
    add_index :impressions, [:impressionable_type, :impressionable_id, :params], name: 'poly_params_request_index', unique: false, length: { params: 100 }
  end
end
