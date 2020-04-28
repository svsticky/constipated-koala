class AddLanguagePreference < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :language, :integer, null: false, default: 0
  end
end
