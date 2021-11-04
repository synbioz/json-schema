module JSON
  class Schema
    class Validator
      attr_accessor :attributes, :formats, :uri, :names
      attr_reader :default_formats

      def initialize()
        @attributes = {}
        @formats = {}
        @default_formats = {}
        @uri = nil
        @names = []
        @metaschema_name = ''
      end

      def extend_schema_definition(schema_uri)
        warn "[DEPRECATION NOTICE] The preferred way to extend a Validator is by subclassing, rather than #extend_schema_definition. This method will be removed in version >= 3."
        validator = JSON::Validator.validator_for_uri(schema_uri)
        @attributes.merge!(validator.attributes)
      end

      def validate(current_schema, data, fragments, processor, options = {})
        current_schema.schema.each do |attr_name,attribute|
          # Added: don't try to validate if
          # - Attribute is false and does not needs to validate anything (eg: uniqueItems) some still needs validation (eg: additionalProperties)
          # - Attribute is nil and it makes crash the validation (eg: divisibleBy). This should fixed on mountapi side
          if @attributes.has_key?(attr_name.to_s) && (attribute != false || @attributes[attr_name.to_s].validate_on_false?) && !attribute.nil?
            @attributes[attr_name.to_s].validate(current_schema, data, fragments, processor, self, options)
          end
        end
        data
      end

      def metaschema
        resources = File.expand_path('../../../../resources', __FILE__)
        File.join(resources, @metaschema_name)
      end
    end
  end
end
