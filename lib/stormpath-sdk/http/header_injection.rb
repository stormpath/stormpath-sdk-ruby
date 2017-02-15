module Stormpath
  module Http
    class HeaderInjection
      attr_reader :request, :resource

      def initialize(request, resource)
        @request = request
        @resource = resource
      end

      def self.for(request, resource = nil)
        raise ArgumentError, 'Stormpath::Http::Request is required' unless request.is_a?(Stormpath::Http::Request)
        new(request, resource)
      end

      def perform
        if resource.try(:form_data?)
          apply_form_data_request_headers
        else
          apply_default_request_headers
        end
      end

      private

      def apply_default_request_headers
        request.http_headers.store('Accept', 'application/json')
        apply_default_user_agent

        if request.body && request.body.present?
          request.http_headers.store('Content-Type', 'application/json')
        end
      end

      def apply_form_data_request_headers
        request.http_headers.store('Content-Type', 'application/x-www-form-urlencoded')
        apply_default_user_agent
      end

      def apply_default_user_agent
        request.http_headers.store('User-Agent', user_agent_header_value)
      end

      def user_agent_header_value
        "stormpath-sdk-ruby/#{Stormpath::VERSION} ruby/#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}" \
        " #{Gem::Platform.local.os}/#{Gem::Platform.local.version}"
      end
    end
  end
end
