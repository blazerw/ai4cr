# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require "./../data/parameterizable" 

 module Ai4cr
   
  module NeuralNetwork
    
    # = Hopfield Net =
    # 
    # A Hopfield Network is a recurrent Artificial Neural Network.
    # Hopfield nets are able to memorize a set of patterns, and then evaluate 
    # an input, returning the most similar stored pattern (although
    # convergence to one of the stored patterns is not guaranteed).
    # Hopfield nets are great to deal with input noise. If a system accepts a 
    # discrete set of inputs, but inputs are subject to noise, you can use a 
    # Hopfield net to eliminate noise and identified the given input.
    #
    # = How to Use =
    # 
    #   data_set = Ai4cr::Data::DataSet.new :data_items => array_of_patterns
    #   net = Ai4cr::NeuralNetworks::Hopfield.new.train data_set
    #   net.eval input
    #     => one of the stored patterns in array_of_patterns
    class Hopfield
      
      getter :weights, :nodes
            
      def initialize(
        @eval_iterations : Int32 = 500,
        @active_node_value : Int32 = 1,
        @inactive_node_value : Int32 = -1,
        @threshold : Int32 = 0
      ); end

      # Prepares the network to memorize the given data set.
      # Future calls to eval (should) return one of the memorized data items.
      # A Hopfield network converges to a local minimum, but converge to one 
      # of the "memorized" patterns is not guaranteed.
      def train(data_set : Ai4cr::Data::DataSet)
        @data_set = data_set
        initialize_nodes(@data_set.not_nil!)
        initialize_weights(@data_set.not_nil!)
        return self
      end

      # You can use run instead of eval to propagate values step by step.
      # With this you can verify the progress of the network output with 
      # each step.
      # 
      # E.g.:
      #   pattern = input
      #   100.times do
      #      pattern = net.run(pattern)
      #      puts pattern.inspect
      #   end
      def run(input : Array(Int32))
        set_input(input)
        propagate
        return @nodes.not_nil!
      end

      # Propagates the input until the network returns one of the memorized
      # patterns, or a maximum of "eval_iterations" times.
      def eval(input)
        if @data_set.nil?
          raise ArgumentError.new("eval called before train, or @data_set is nil.")
        end
        set_input(input)
        @eval_iterations.times do
          propagate  
          break if @data_set.not_nil!.data_items.includes?(@nodes)
        end
        return @nodes
      end
      
      # Set all nodes state to the given input.
      # inputs parameter must have the same dimension as nodes
      protected def set_input(inputs : Array(Int32))
        unless @nodes && inputs.size == @nodes.not_nil!.size
          raise ArgumentError.new("Inputs size does not match @nodes size.")
        end
        inputs.each_with_index { |input, i| @nodes.not_nil![i] = input}
      end
      
      # Select a single node randomly and propagate its state to all other nodes
      protected def propagate
        raise ArgumentError.new("Nodes not set in propagate.") if @nodes.nil?
        sum = 0
        i = Random.rand(@nodes.not_nil!.size)
        @nodes.not_nil!.each_with_index {|node, j| sum += read_weight(i,j)*node }
        @nodes.not_nil![i] = (sum > @threshold) ? @active_node_value : @inactive_node_value
      end
      
      # Initialize all nodes with "inactive" state.
      # protected
      def initialize_nodes(data_set : Ai4cr::Data::DataSet)
        @nodes = Array(Int32).new(data_set.data_items.first.size, 
          @inactive_node_value)
      end
      
      # Create a partial weigth matrix:
      #   [ 
      #     [w(1,0)], 
      #     [w(2,0)], [w(2,1)],
      #     [w(3,0)], [w(3,1)], [w(3,2)],
      #     ... 
      #     [w(n-1,0)], [w(n-1,1)], [w(n-1,2)], ... , [w(n-1,n-2)]
      #   ]
      # where n is the number of nodes.
      # 
      # We are saving memory here, as:
      # 
      # * w[i][i] = 0 (no node connects with itself)
      # * w[i][j] = w[j][i] (weigths are symmetric)
      # 
      # Use read_weight(i,j) to find out weight between node i and j
      # protected
      def initialize_weights(data_set)
        raise ArgumentError.new("Nodes not set when initializing weights.") if @nodes.nil?
        @weights = Array(Array(Int32)).new(@nodes.not_nil!.size-1) do |l|
          Array(Int32).new(l+1, 0)
        end
        @nodes.not_nil!.each_index do |i|
          i.times do |j|
            @weights.not_nil![i-1][j] = data_set.data_items.reduce(0) { |sum, item| sum+= item[i]*item[j] }
          end
        end
      end
      
      # read_weight(i,j) reads the weigth matrix and returns weight between 
      # node i and j
      protected def read_weight(index_a : Int32, index_b : Int32)
        return 0 if index_a == index_b
        raise ArgumentError.new("@weigths nil in read_weight.") if @weights.nil?
        index_a, index_b = index_b, index_a if index_b > index_a
        return @weights.not_nil![index_a-1][index_b]
      end
      
    end
    
  end
  
end
