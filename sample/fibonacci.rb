require 'json'
require 'minerva'

#
# pub fn fibonacci(n: u64) -> u64 {
#   return if n == 0 || n == 1 { 1 } else { fibonacci(n - 1) + fibonacci(n - 2) };
# }
#

i64 = Minerva::Primitive.i64

ir = Minerva::Module.new('fibonacci') do |mod|
  mod.function(:fibonacci, { n: i64 }, i64) do |f|
    f.entry = :entry

    f.block(:entry, { n: i64 }) do |b|
      b.assign a: b.lt(:n, i64.constant(3))
      b.conditional(:a, return: [], else: [:n])
    end

    f.block(:return) do |b|
      b.return i64.constant(1)
    end

    f.block(:else, { n: i64 }) do |b|
      b.assign a: b.sub(:n, i64.constant(1)), b: b.sub(:n, i64.constant(2))
      b.assign f_a: b.call(:fibonacci, :a), f_b: b.call(:fibonacci, :b)
      b.assign c: b.add(:f_a, :f_b)
      b.return :c
    end
  end
end.to_llvm

ir.dump