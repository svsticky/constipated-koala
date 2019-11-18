class AddLanguageToMember < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :language, :integer
  end
end
