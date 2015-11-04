module Minerva
  class Primitive
    def initialize(type)
      @type = type
    end

    def self.i64
      Primitive.new(LLVM::Int64)
    end

    def constant(value)
      Constant.new(self, value)
    end

    def to_llvm
      @type
    end
  end
end
