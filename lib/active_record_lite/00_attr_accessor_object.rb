class AttrAccessorObject
  def self.my_attr_accessor(*attrs)
    
    attrs.each do |attr|
    	#define setter
    	define_method("#{attr}=") do |val|
    		instance_variable_set("@#{attr}", val)
    	end
    	#define setter
    	define_method("#{attr}") do
    		instance_variable_get("@#{attr}")
    	end

    end
  end
end
