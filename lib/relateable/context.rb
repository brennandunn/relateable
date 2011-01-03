module Relateable
  class Context
    
    attr_reader :factors
    
    def initialize(klass, &block)
      @klass = klass
      @factors = []
      instance_eval(&block) if block_given?
    end
    
    def match(first, second)
      return 1.0 if @factors.empty?
      running_score = 0.0
      @factors.each do |factor|
        running_score += (factor.match(first, second) * factor.weight.to_f)
      end
      running_score.to_f / @factors.inject(0) { |sum, f| sum += f.weight ; sum }.to_f
    end
    
    def factor(name, options={}, &block)
      factor = Factor.new(name, options, &block)
      @factors << factor
      factor
    end
    
    
    class Factor
      attr_reader :name, :weight, :proc
      
      def initialize(name, options={}, &block)
        @name = name
        @weight = options[:weight] || 1
        @proc = block
      end
      
      def match(first, second)
        response = proc.call(first, second)
        return response ? 1.0 : 0.0 if response.is_a?(TrueClass) || response.is_a?(FalseClass)
        response
      end
      
    end
    
  end
end