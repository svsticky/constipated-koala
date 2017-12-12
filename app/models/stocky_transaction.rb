class StockyTransaction < ApplicationRecord
  LOCATIONS=%w(shop basement mongoose waste member activity)
  NOT_VALID_MESSAGE="%{value} is not a valid location"

  validates :from, inclusion: { in: LOCATIONS, message: NOT_VALID_MESSAGE }
  validates :to, inclusion: { in: LOCATIONS, message: NOT_VALID_MESSAGE }

  belongs_to :checkout_product
end
