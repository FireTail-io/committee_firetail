module Committee
  class SchemaValidator::HyperSchema::Router
    def initialize(schema, options = {})
      @prefix = options[:prefix]
      @prefix_regexp = /\A#{Regexp.escape(@prefix)}/.freeze if @prefix
      @schema = schema

      @validator_option = options[:validator_option]
    end

    def includes?(path)
      !@prefix || path =~ @prefix_regexp
    end

    def includes_request?(request)
      includes?(request.path)
    end

    def find_link(method, path)
      path = path.gsub(@prefix_regexp, "") if @prefix
      if method_routes = @schema.routes[method]
        method_routes.each do |pattern, link|
          if matches = pattern.match(path)
            hash = Hash[matches.names.zip(matches.captures)]
            return link, hash
          end
        end
      end
      nil
    end

    def find_request_link(request)
      find_link(request.request_method, request.path_info)
    end

    def build_schema_validator(request)
      Committee::SchemaValidator::HyperSchema.new(self, request, @validator_option)
    end
  end
end
