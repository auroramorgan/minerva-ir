module Minerva
  class Block
    attr_reader :parent, :name

    def initialize(parent, name, arguments = {})
      @parent, @name = parent, name

      @arguments = arguments

      @nodes = []
      @assignments = {}

      yield self
    end

    def function
      self.parent
    end

    def module
      self.parent.module
    end

    def assign(hash)
      @assignments.merge!(hash)
    end

    def add_node(node)
      node.tap { |n| @nodes.push(n) }
    end

    def add(a, b)
      self.add_node(ArithmeticNode.new(self, :add, a, b))
    end

    def call(function, *args)
      self.add_node(CallNode.new(self, function, *args))
    end

    def conditional(test, branches)
      self.add_node(ConditionalNode.new(self, test, branches.to_a))
    end

    def sub(a, b)
      self.add_node(ArithmeticNode.new(self, :sub, a, b))
    end

    def lt(a, b)
      self.add_node(ComparisonNode.new(self, :slt, a, b))
    end

    def return(value)
      self.add_node(ReturnNode.new(self, value))
    end

    def to_llvm(blocks, phi_nodes, mod)
      blocks[self.name].build do |b|
        assignments = @assignments.to_a.map { |k, v| [v, k] }.to_h

        if parent.entry == self.name
          llvm_values = @arguments.keys.zip(phi_nodes[self.name][self.name]).to_h
        else
          llvm_values = @arguments.map.with_index do |(name, type), i|
            phi = phi_nodes[self.name].map { |k, v| [blocks[k], v[i]] }.to_h

            [name, b.phi(type.to_llvm, phi, name.to_s)]
          end.to_h
        end

        @nodes.each do |n|
          name = assignments[n]

          llvm_node = n.to_llvm(b, llvm_values, name.to_s, blocks, phi_nodes, mod)

          llvm_values[name] = llvm_node if name
        end
      end
    end
  end
end
