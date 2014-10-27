# encoding: UTF-8

require 'rosette/core'
require 'psych'
require 'rosette/extractors/yaml-extractor/scalar_handler'

module Rosette
  module Extractors

    class YamlExtractor < Rosette::Core::StaticExtractor
      def extract_each_from(yaml_content)
        if block_given?
          each_entry(yaml_content) do |key, meta_key, line_number|
            yield make_phrase(key, meta_key), line_number
          end
        else
          to_enum(__method__, yaml_content)
        end
      end

      def supports_line_numbers?
        true
      end

      protected

      def parse(yaml_content)
        scalar_handler = ScalarHandler.new
        parser = Psych::Parser.new(scalar_handler)
        scalar_handler.parser = parser
        parser.parse(yaml_content)
        scalar_handler.stack.pop
      end

      class DottedKeyExtractor < YamlExtractor
        protected

        def each_entry(yaml_content, &block)
          walk(parse(yaml_content), [], &block)
        end

        def walk(obj, cur_path, &block)
          case obj
            when Hash
              obj.each_pair do |key, val|
                walk(val, cur_path + [key], &block)
              end
            when Array
              obj.each_with_index do |val, idx|
                walk(val, cur_path + [idx.to_s], &block)
              end
            else
              yield obj.value, scrub_path(cur_path).join('.'), obj.line_number
          end
        end

        private

        def scrub_path(path)
          path  # no-op
        end
      end

      class RailsExtractor < DottedKeyExtractor
        private

        def scrub_path(path)
          path[1..-1]
        end
      end
    end

  end
end
