module Minerva
  class Module
    attr_reader :name, :functions

    def initialize(name)
      @name = name
      @functions = []

      yield self
    end

    def function(*args, &block)
      @functions.push(Function.new(self, *args, &block))
    end

    def to_llvm
      LLVM::Module.new(self.name).tap do |mod|
        @functions.each { |f| f.to_llvm(mod) }
      end
    end
  end
end
