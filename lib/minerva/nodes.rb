module Minerva
  class Node
    attr_reader :parent

    def initialize(parent)
      @parent = parent
    end

    protected

    def llvm_values(values, *args)
      args.map do |arg|
        case arg
        when Symbol
          values[arg]
        else
          arg.to_llvm
        end
      end
    end
  end

  class ArithmeticNode < Node
    def initialize(block, type, a, b)
      super(block)

      @type, @a, @b = type, a, b
    end

    def to_llvm(block, values, name, _, _, _)
      llvm_arguments = llvm_values(values, @a, @b)

      case @type
      when :add, :sub
        block.send(@type, *llvm_arguments, name)
      else
        fail ArgumentError, "unsupported arithmetic node"
      end
    end
  end

  class CallNode < Node
    def initialize(block, function, *args)
      super(block)

      @function, @args = function, args
    end

    def to_llvm(block, values, name, _, _, mod)
      llvm_arguments = llvm_values(values, *@args)

      block.call(mod.functions.named(@function.to_s), *llvm_arguments, name)
    end
  end

  class ComparisonNode < Node
    def initialize(block, type, a, b)
      super(block)

      @type, @a, @b = type, a, b
    end

    def to_llvm(block, values, name, _, _, _)
      llvm_arguments = llvm_values(values, @a, @b)

      block.icmp(@type, *llvm_arguments, name)
    end
  end

  class ConditionalNode < Node
    def initialize(block, test, branches)
      super(block)

      fail ArgumentError, "odd number of branch targets" if branches.length != 2

      @test, @a, @b = test, branches[0], branches[1]
    end

    def to_llvm(block, values, _, blocks, phi_nodes, _)
      llvm_arguments = llvm_values(values, @test)

      phi_nodes[@a[0]][parent.name] = llvm_values(values, *@a[1])
      phi_nodes[@b[0]][parent.name] = llvm_values(values, *@b[1])

      block_a, block_b = blocks[@a[0]], blocks[@b[0]]
      
      fail ArgumentError, "branches do not refer to blocks" unless block_a && block_b

      block.cond(*llvm_arguments, block_a, block_b)
    end
  end

  class ReturnNode < Node
    def initialize(block, value)
      super(block)

      @value = value
    end

    def to_llvm(block, values, _, _, _, _)
      llvm_arguments = llvm_values(values, @value)

      block.ret(*llvm_arguments)
    end
  end
end
