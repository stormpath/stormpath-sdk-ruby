#
# Copyright 2012 Stormpath, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class Stormpath::Resource::Collection
  include Enumerable

  attr_reader :href, :client, :item_class, :collection_href, :criteria

  def initialize(href, item_class, client, options={})
    @client = client
    @href = href
    @item_class = item_class
    @collection_href = options[:collection_href] || @href
    @criteria ||= {}
  end

  def data_store
    client.data_store
  end

  def search query
    query_hash = if query.is_a? String
      { q: query }
    elsif query.is_a? Hash
      query
    end

    criteria.merge! query_hash
    self
  end

  def offset offset
    criteria.merge! offset: offset
    self
  end

  def limit limit
    criteria.merge! limit: limit
    self
  end

  def order statement
    criteria.merge! order_by: statement
    self
  end

  def each(&block)
    PaginatedIterator.iterate(collection_href, client, item_class, @criteria, &block)
  end

  private

    module PaginatedIterator

      def self.iterate(collection_href, client, item_class, criteria, &block)
        page = CollectionPage.new collection_href, client, criteria
        page.item_type = item_class
        page.items.each(&block)

        if criteria[:limit].nil? and page.items.count == 25
          criteria[:offset] ||=0
          criteria[:offset] += 25
          iterate(collection_href, client, item_class, criteria, &block)
        end
      end

    end

    class CollectionPage < Stormpath::Resource::Base
      ITEMS = 'items'

      prop_accessor :offset, :limit

      attr_accessor :item_type

      def items
        to_resource_array get_property(ITEMS)
      end

      def to_resource properties
        data_store.instantiate item_type, properties
      end

      def to_resource_array vals
        Array.new.tap do |items|
          if vals.is_a? Array
            vals.each do |val|
              resource = to_resource val
              items << resource
            end
          end
        end
      end

    end#class Stormpath::Resource::Collection::CollectionPage

end#Stormpath::Resource::Collection
