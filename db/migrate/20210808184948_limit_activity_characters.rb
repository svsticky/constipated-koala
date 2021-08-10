class LimitActivityCharacters < ActiveRecord::Migration[6.0]
  def up
    Activity.where('length(name) > 52').each {|activity|
    activity.comments = activity.notes + "\n Activity name was too long\n Original: #{activity.name}"
    activity.name = activity.name[0..51]
    activity.save
  }
  
    change_column :activities, :name, :string, :limit => 52
  end

  def down
    change_column :activities, :name, :string, :limit => nil
  end
end
