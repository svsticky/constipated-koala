#:nodoc:
class Participant < ApplicationRecord
  belongs_to :member
  belongs_to :activity

  validates :notes, length: { maximum: 100 } # This was 30 previously, but we saw no reason to keep it that short

  before_destroy :rewrite_logs_before_delete!, prepend: true
  is_impressionable dependent: :ignore

  def price=(price)
    write_attribute(:price, price.to_s.tr(',', '.').to_f) if price.present?
    write_attribute(:price, nil) if price.blank?
  end

  def currency
    return activity.price if self[:price].nil?

    self.price ||= 0
  end

  before_validation do
    self.paid = false if price_changed?
    self[:price] = nil if activity.price == self.price
  end

  # Update logs before deleting a Participant to keep what happened
  def rewrite_logs_before_delete!
    impressions.each do |i|
      prefix = "#{ activity.name } (#{ activity.id }) - "
      message = case i.action_name
                when "update"
                  I18n.t(i.message,
                         scope: [:activerecord, :attributes, :impression,
                                 i.impressionable_type.downcase, i.action_name])
                else
                  I18n.t(i.action_name,
                         scope: [:activerecord, :attributes, :impression,
                                 i.impressionable_type.downcase])
                end

      newmessage = prefix + message
      i.update(message: newmessage)
      i.update(impressionable_id: nil)
    end
  end
end
