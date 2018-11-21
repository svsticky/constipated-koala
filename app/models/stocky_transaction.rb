# :nodoc:
class StockyTransaction < ApplicationRecord
  LOCATIONS = %w[shop basement mongoose waste member activity].freeze
  NOT_VALID_MESSAGE = "%{value} is not a valid location".freeze

  validates :from, inclusion: { in: LOCATIONS, message: NOT_VALID_MESSAGE }
  validates :to, inclusion: { in: LOCATIONS, message: NOT_VALID_MESSAGE }

  belongs_to :checkout_product_type

  after_commit :update_stock

  def update_stock
    if from == 'basement'
      checkout_product_type.storage_stock -= amount
    elsif from == 'mongoose'
      checkout_product_type.chamber_stock -= amount
    end

    if to == 'basement'
      checkout_product_type.storage_stock += amount
    elsif to == 'mongoose'
      checkout_product_type.chamber_stock += amount
    end

    checkout_product_type.save!
  end
end
