module Stormpath
  module Test
    class ResourceFactory
      URL_PREFIX = 'https://api.stormpath.com/v1'

      def initialize
        @id_count = 0
      end

      def resource(type, depth = 1, associations = [])
        id = id_for type
        plural = "#{type}s"
        resource = { 'href' => "#{URL_PREFIX}/#{plural}/#{id}" }

        if depth > 0
          resource['name'] = "#{type} #{id}"
          associations.each do |assoc|
            resource[assoc] = if assoc =~ /s$/
              collection type, assoc.sub(/s$/, ''), depth - 1
            else
              resource assoc, depth - 1
            end
          end
        end

        resource
      end

      def collection(parent, type, depth = 1)
        id = id_for parent
        collection = {
          'href' => "#{URL_PREFIX}/#{parent}s/#{id}/#{type}s",
          'items' => [
            resource(type, depth),
            resource(type, depth)
          ]
        }

        collection
      end

      def id_for(type)
        @id_count += 1
        "#{type[0, 3]}#{@id_count}"
      end
    end
  end
end
