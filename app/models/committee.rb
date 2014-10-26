class Committee < ActiveRecord::Base
  validates :name, presence: true

  attr_accessor :tags_name_ids
  fuzzily_searchable :query
  is_impressionable

  has_many :committeeMembers,
    :dependent => :destroy
  has_many :members, :through => :committeeMembers

  has_one :activity

  def self.search(query)
    Committee.find_by_fuzzy_query(query, :limit => 10)
  end

  # query for fuzzy search 
  def query
    "#{self.name}"
  end

  def query_changed?
    name_changed?
  end
end
