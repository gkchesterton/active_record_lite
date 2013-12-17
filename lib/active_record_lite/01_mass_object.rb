require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  def self.my_attr_accessible(*new_attributes)
    new_attributes.each do |attr|
    	self.attributes << attr
    end
  end

  def self.attributes
  	raise "must not call #attributes on MassObject directly" if self.superclass == AttrAccessorObject
    @attributes ||= []
  end

  def initialize(params = {})
    params.each do |attr, val|
    	if self.class.attributes.include?(attr.to_sym)
    		self.send("#{attr}=", val)
    	else
    		raise "mass assignment to unregistered attribute '#{attr}'"
    	end
    end
  end
end
