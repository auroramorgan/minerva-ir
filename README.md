# Minerva IR #

Playing with an IR, it will hopefully allow me to play a bit with Rust semantics and think about how they would map to an IR.

In the very unlikely event that you want to build this, you need to change the Gemfile or checkout a `ruby-llvm` into a directory next to this one. `ruby-llvm` doesn't build properly on my machine, so I had to modify some stuff, but since the tests crash inside LLVM, I'm afraid to do a PR with the fixes.
