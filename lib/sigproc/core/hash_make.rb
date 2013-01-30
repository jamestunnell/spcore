module SigProc

class HashedArg
  DEFAULT_ARGS = {
    :reqd => true,
    :validator => ->(a){true},
    :array => false,
  }
  
  attr_reader :key, :type, :validator, :reqd, :default, :array
  
  def initialize args
    new_args = DEFAULT_ARGS.merge(args)
    
    @key = new_args[:key]
    @type = new_args[:type]
    raise ArgumentError, "args[:type] #{@type} is not a Class" unless @type.is_a?(Class)
    
    @validator = new_args[:validator]
    @reqd = new_args[:reqd]
    @array = new_args[:array]
    
    unless @reqd
      msg = "if hashed arg is not required, a default value or value generator (proc) must be defined via :default key"
      raise ArgumentError, msg unless args.has_key?(:default)
      @default = new_args[:default]
    end
  end

end

module HashMake
  
  # Use the included hook to also extend the including class with HashMake
  # class methods
  def self.included(base)
    base.extend(ClassMethods)
  end

  def hash_make args, assign_args = true
    raise ArgumentError, "args is not a Hash" if !args.is_a?(Hash)

    self.class::HASHED_ARGS.each do |arg|
      
      key = arg.key
      if args.has_key?(key)
        val = args[key]
      else
        if arg.reqd
          raise ArgumentError, "args does not have required key #{key}"
        else
          if arg.default.is_a?(Proc) && arg.type != Proc
            val = arg.default.call
          else
            val = arg.default
          end
        end
      end
      
      if arg.array
        raise "val #{val} is not an array" unless val.is_a?(Array)
        val.each do |item|
          raise "array item #{item} is not a #{arg.type}" unless val.is_a?(arg.type)
        end
      else
        raise "val #{val} is not a #{arg.type}" unless val.is_a?(arg.type)
      end
      
      if assign_args
        raise ArgumentError, "value #{val} is not valid" unless arg.validator.call(val)
        self.instance_variable_set("@#{key.to_s}".to_sym, val)
      end
    end
  end

  module ClassMethods    
  end
end
  
end
