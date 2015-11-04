module Minerva
  class Function
    attr_reader :name, :parent
    attr_reader :arguments, :return_type

    attr_accessor :entry

    def initialize(parent, name, arguments, return_type)
      @parent, @name = parent, name

      @arguments = arguments
      @return_type = return_type

      @entry = nil
      @blocks = {}

      yield self
    end

    def module
      self.parent
    end

    def block(name, *args, &block)
      @blocks[name] = Block.new(self, name, *args, &block)
    end

    def to_llvm(mod)
      argument_types = self.arguments.values.map(&:to_llvm)
      return_type = self.return_type.to_llvm
      
      mod.functions.add(self.name, argument_types, return_type) do |f, *args|
        self.arguments.keys.zip(args) { |name, arg| arg.name = name.to_s }

        blocks = @blocks.map { |k, v| [k, f.basic_blocks.append(v.name.to_s)] }.to_h

        phi_nodes = @blocks.map { |k, v| [k, {}] }.to_h
        phi_nodes[self.entry][self.entry] = args

        @blocks.values.each do |b|
          b.to_llvm(blocks, phi_nodes, mod)
        end
      end
    end
  end
end
