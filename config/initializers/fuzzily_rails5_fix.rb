Fuzzily::Searchable.module_eval() do
  def self.included(by)
    case ActiveRecord::VERSION::MAJOR
    when 2 then by.extend Rails2ClassMethods
    when 3 then by.extend Rails3ClassMethods
    when 4 then by.extend Rails4ClassMethods
    when 5 then by.extend Rails4ClassMethods
    end
  end
end
