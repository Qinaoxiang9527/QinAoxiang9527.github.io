# Ruby 3.2+ removed taint tracking; older Liquid (4.0.3) still calls tainted? on strings and nil.
unless Object.method_defined?(:tainted?)
  class Object
    def tainted?
      false
    end

    def untaint
      self
    end
  end
end
