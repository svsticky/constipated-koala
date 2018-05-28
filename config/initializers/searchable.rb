require 'fuzzily/trigram'
require 'ostruct'

# NOTE allow to search on subset of a model
Fuzzily::Searchable::ClassMethods.module_eval do
  private

  def _find_by_fuzzy(_o, pattern, options = {})
    options[:limit] ||= 10
    options[:offset] ||= 0

    trigrams = _o.trigram_class_name.constantize
                 .offset(options[:offset])
                 .for_model(self.name)
                 .for_field(_o.field.to_s)
                 .matches_for(pattern)

    records = _load_for_ids(trigrams.map(&:owner_id), options[:limit])

    # order records as per trigram query (no portable way to do this in SQL)
    trigrams.map { |t| records[t.owner_id] }.compact
  end

  def _load_for_ids(ids, limit)
    {}.tap do |result|
      ids.each { |id|
        if find_by_id(id).present?
          result[id] = find_by_id(id)
          break if ((limit -= 1) == 0)
        end
      }
    end
  end
end
