# encoding: UTF-8

require 'rosette/core'
require 'yaml'

module Rosette
  module Extractors

    class YamlExtractor < Rosette::Core::StaticExtractor
      def extract_each_from(yaml_content)
        if block_given?
          each_entry(yaml_content) do |key, meta_key|
            yield make_phrase(key, meta_key)
          end
        else
          to_enum(__method__, yaml_content)
        end
      end

      protected

      def parse(yaml_content)
        YAML.load(yaml_content)
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
              yield obj, cur_path.join('.')
          end
        end
      end

      # alias
      RailsExtractor = DottedKeyExtractor
    end

  end
end
