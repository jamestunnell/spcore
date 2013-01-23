module SigProc

class HashedArg
  DEFAULT_ARGS = {
    :reqd => true,
    :validator => ->(a){true}
  }
  
  attr_reader :key, :type, :validator, :reqd, :default
  def initialize args
    new_args = DEFAULT_ARGS.merge(args)
    
    @key = new_args[:key]
    @type = new_args[:type]
    @validator = new_args[:validator]
    @reqd = new_args[:reqd]
    
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

  def hash_make args
    raise ArgumentError, "args is not a Hash" if !args.is_a?(Hash)

    self.class::HASHED_ARGS.each do |arg|
      
      key = arg.key
      if args.has_key?(key)
        val = args[key]
      else
        if arg.reqd
          raise ArgumentError, "args does not have required key #{key}"
        else
          if arg.default.is_a?(Proc)
            val = arg.default.call
          else
            val = arg.default
          end
        end
      end
      raise ArgumentError, "value #{val} is not valid" unless arg.validator.call(val)
      
      assigner_sym = "#{key.to_s}=".to_sym
      raise "current object #{self} does not include method #{assigner_sym.inspect}" unless self.methods.include?(assigner_sym)
      self.send(assigner_sym, val)
    end
  end

  module ClassMethods    
  end
end
  
end
