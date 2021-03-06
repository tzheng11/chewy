module Chewy
  class Query
    module Pagination
      # Returns request total found documents count
      #
      #   PlacesIndex.query(...).filter(...).total_count
      #
      def total_count
        _response['hits'].try(:[], 'total') || 0
      end
    end
  end
end
