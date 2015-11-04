module Minerva  
  class Constant
    def initialize(type, value)
      @type, @value = type, value
    end

    def to_llvm
      @type.to_llvm.from_i(@value)
    end
  end
end
