#:nodoc: NOTE don't destroy records we want to preserve even after destroying the object
module Impressionist
  #:nodoc:
  module IsImpressionable
    extend ActiveSupport::Concern

    #:nodoc:
    module ClassMethods
      def is_impressionable(options = {}) # rubocop:disable PredicateName
        define_association options.delete(:dependent)
        @impressionist_cache_options = options

        true
      end

      private

      def define_association(dependent = nil)
        # Don't remove the logs recording if it is destroyed
        case dependent
        when :ignore then
          has_many(:impressions,
                   :as => :impressionable)
        when :nullify then
          has_many(:impressions,
                   :as => :impressionable,
                   :dependent => :nullify)
        else
          has_many(:impressions,
                   :as => :impressionable,
                   :dependent => :destroy)
        end
      end
    end
  end
end
