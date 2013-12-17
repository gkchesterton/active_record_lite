require_relative '03_searchable'
require 'active_support/inflector'
require 'debugger'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = { foreign_key: "#{name}_id".to_sym, primary_key: :id, class_name: name.to_s.camelcase.singularize }
    options = defaults.merge(options)
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = { foreign_key: "#{self_class_name.to_s.underscore}_id".to_sym, primary_key: :id, class_name: name.to_s.camelcase.singularize }
    options = defaults.merge(options)
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    send(:define_method, "#{name}".to_sym, lambda { options.model_class.where( 
                                   options.primary_key.to_s => send("#{options.foreign_key}") )[0] })
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    debugger
    send(:define_method, "#{name}".to_sym, lambda do 
      options.model_class.where( 
      options.foreign_key.to_s => send("#{options.primary_key}") ) 
    end)  
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
