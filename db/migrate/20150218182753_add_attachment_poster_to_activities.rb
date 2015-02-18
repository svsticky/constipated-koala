class AddAttachmentPosterToActivities < ActiveRecord::Migration
  def self.up
    change_table :activities do |t|
      t.attachment :poster
      t.text :description
    end
  end

  def self.down
    remove_attachment :activities, :poster
  end
end
