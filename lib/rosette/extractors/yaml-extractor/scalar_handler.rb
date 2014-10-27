# encoding: UTF-8

module Rosette
  module Extractors
    class YamlExtractor < Rosette::Core::StaticExtractor
      class ScalarHandler < Psych::Handler
        attr_reader :stack, :last_scalar
        attr_accessor :parser

        def initialize
          @stack = []
          super
        end

        def mark
          parser.mark
        end

        def scalar(value, anchor, tag, plain, quoted, style)
          scalar = YamlScalar.new(mark.line, value)
          case current
          when Hash
            if @last_scalar
              current[last_scalar.value] = scalar
              @last_scalar = nil
            else
              @last_scalar = scalar
            end
          when Array
            current << scalar
            @last_scalar = scalar
          end
        end

        def start_mapping(anchor, tag, implicit, style)
          if stack.empty?
            stack.push({})
            return
          end
          case current
          when Hash
            h = Hash.new
            current[last_scalar.value] = h
            stack.push(h)
          when Array
            h = Hash.new
            current << h
            stack.push(h)
          end
          @last_scalar = nil
        end

        def end_mapping
          stack.pop if stack.size > 1
          @last_scalar = nil
        end

        def start_sequence(anchor, tag, implicit, style)
          if stack.empty?
            stack.push([])
            return
          end
          case current
          when Hash
            arr = []
            current[last_scalar.value] = arr
            stack.push(arr)
          when Array
            arr = []
            current << arr
            stack.push(arr)
          end
          @last_scalar = nil
        end

        def end_sequence
          stack.pop if stack.size > 1
          @last_scalar = nil
        end

        def current
          stack.last
        end

        YamlScalar = Struct.new(:line_number, :value)
      end
    end
  end
end
