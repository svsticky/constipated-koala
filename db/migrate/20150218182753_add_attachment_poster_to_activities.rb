#:nodoc:
class AddAttachmentPosterToActivities < ActiveRecord::Migration[4.2]
  def self.up
    change_table :activities do |t|
      t.text :description
    end
  end

  def self.down
    remove_attachment :activities, :description
  end
end
