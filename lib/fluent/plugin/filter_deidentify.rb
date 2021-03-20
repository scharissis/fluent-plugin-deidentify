require "fluent/plugin/filter"

MASK, REPLACE, REMOVE = 'mask', 'replace', 'remove'
DEFAULT_MASK = '*****'

# Inputs:
# - record: Hash
# - regex: Regexp
def replace(record, regex, replacement="")
  if regex.is_a?(String) then
    regex = Regexp.new(regex)
  end
  process_all(record, {'operation' => REPLACE, 'regex' => regex, 'replacement' => replacement})
end

def remove(record, paths)
  process(record, paths, REMOVE)
end


def mask(record, paths, mask=DEFAULT_MASK)
  process(record, paths, MASK, {'mask' => mask})
end

def process_all(record, options)
  record.each {|key, value|
    if value.is_a?(Hash) then
      process_all(value, options)
    elsif value.is_a?(String) then
      if options['operation'] == REPLACE then
        regex = options['regex']
        replacement = options['replacement']
        if regex and replacement and regex.match(value)
          record[key] = replacement
        end
      end
    else
      return
    end
  }
end

# Inputs:
# - record: Hash (json)
# - paths: List of String
def process(record, paths, operation=MASK, options={'mask'=>DEFAULT_MASK})
  if !paths.is_a?(String) and !paths.is_a?(Array) then
    puts('Error: mask: input shoud be a list.')
    return
  end

  if paths.is_a?(String) then
    paths = [paths]
  end

  paths.each { |path|
    r = record
    k = nil
 
    # Support 'a.b.c' jsonpath format.
    if path.is_a?(String) and path.include?'.' then
      path = path.split('.')
    else
      path = [path]
    end

    path.each { |p|
      k = p
      if r[p] and r[p].is_a?(Hash) then
        r = r[p]
      else
        break
      end
    }
    if k and r[k] and r[k].is_a?(String) then
      if operation==MASK then
        r[k] = options['mask']
      elsif operation==REMOVE then
        r.delete(k)
      else
        puts("Unknown operation: #{operation}")
      end
    end
  }
end


def deidentify(record, rules)
  if !rules then return end

  # Remove
  if rules[REMOVE] then
    remove(record, rules[REMOVE].paths)
  end
 
  # Mask
  if rules[MASK] then
    mask(record, rules[MASK].paths, rules[MASK].mask)
  end

  # Replace
  if rules[REPLACE] then
    rules[REPLACE].each { |r|
      replace(record, r.regex, r.replacement)
    }
  end
end

module Fluent
  module Plugin
    class DeidentifyFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter("deidentify", self)

      desc 'Rules for masking'
      config_section :masker, param_name: :masker, multi: false, required: false do
        desc 'Masking paths'
        config_param :paths, :array, default: [], value_type: :string
        desc 'Masking mask'
        config_param :mask, :string, default: DEFAULT_MASK
      end

      desc 'Rules for removing'
      config_section :remover, param_name: :remover, multi: false, required: false do
        desc 'Removal paths'
        config_param :paths, :array, default: [], value_type: :string
      end

      desc 'Rules for replacing'
      config_section :replacer, param_name: :replacer, multi: true, required: false do
        desc 'Replacement regex'
        config_param :regex, :regexp
        desc 'Replacement replacement'
        config_param :replacement, :string
      end
      

      def configure(conf)
        super
        @rules = {REMOVE => @remover, MASK => @masker, REPLACE => @replacer}
      end

      def filter(tag, time, record)
        deidentify(record, @rules)
        record
      end
    end
  end
end
