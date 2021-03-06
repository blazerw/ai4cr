require "./../../spec_helper"

describe Ai4cr::NeuralNetwork::Backpropagation do
  describe "#init_network" do
    describe "when given a net with structure of [4, 2]" do
      structure = [4, 2]
      inputs = [1, 2, 3, 4]
      outputs = [5, 6]
      expected_activation_nodes = [[1.0, 1.0, 1.0, 1.0, 1.0], [1.0, 1.0]]
      expected_weights_size = 1
      expected_weights_first_size = 5
      expected_weights_first_sub_size = 2
      net = Ai4cr::NeuralNetwork::Backpropagation.new(structure).init_network

      it "sets @activation_nodes to expected nested array" do
        net.activation_nodes.should eq(expected_activation_nodes)
      end

      it "sets @weights to expected size" do
        net.weights.size.should eq(expected_weights_size)
      end

      it "sets @weights.first to expected size" do
        net.weights.first.size.should eq(expected_weights_first_size)
      end

      it "sets each sub-array w/in @weights.first to expected size" do
        net.weights.first.each do |weights_n|
          weights_n.size.should eq(expected_weights_first_sub_size)
        end
      end

      describe "#train" do
        it "returns a Float64" do
          net.train(inputs, outputs).should be_a(Float64)
        end

        it "updates the net" do
          net.train(inputs, outputs)
          net.activation_nodes.should_not eq(expected_activation_nodes)
        end
      end
    end

    describe "when given a net with structure of [2, 2, 1]" do
      structure = [2, 2, 1]
      inputs = [1, 2]
      outputs = [3]
      expected_activation_nodes = [[1.0, 1.0, 1.0], [1.0, 1.0, 1.0], [1.0]]
      expected_weights_size = 2
      expected_weights_first_size = 3
      expected_weights_first_sub_size = 2
      net = Ai4cr::NeuralNetwork::Backpropagation.new(structure).init_network

      it "sets @activation_nodes to expected nested array" do
        net.activation_nodes.should eq(expected_activation_nodes)
      end

      it "sets @weights to expected size" do
        net.weights.size.should eq(expected_weights_size)
      end

      it "sets @weights.first to expected size" do
        net.weights.first.size.should eq(expected_weights_first_size)
      end

      it "sets each sub-array w/in @weights.first to expected size" do
        net.weights.first.each do |weights_n|
          weights_n.size.should eq(expected_weights_first_sub_size)
        end
      end

      describe "#train" do
        it "returns a Float64" do
          net.train(inputs, outputs).should be_a(Float64)
        end

        it "updates the net" do
          net.train(inputs, outputs)
          net.activation_nodes.should_not eq(expected_activation_nodes)
        end
      end
    end

    describe "when given a net with structure of [2, 2, 1] with bias disabled" do
      structure = [2, 2, 1]
      inputs = [1, 2]
      outputs = [3]
      expected_activation_nodes = [[1.0, 1.0], [1.0, 1.0], [1.0]]
      expected_weights_size = 2
      expected_weights_first_size = 2 # one less than prev example since bias is disabled here
      expected_weights_first_sub_size = 2
      net = Ai4cr::NeuralNetwork::Backpropagation.new(structure).init_network
      net.disable_bias = true
      net.init_network

      it "sets @activation_nodes to expected nested array" do
        net.activation_nodes.should eq(expected_activation_nodes)
      end

      it "sets @weights to expected size" do
        net.weights.size.should eq(expected_weights_size)
      end

      it "sets @weights.first to expected size" do
        net.weights.first.size.should eq(expected_weights_first_size)
      end

      it "sets each sub-array w/in @weights.first to expected size" do
        net.weights.first.each do |weights_n|
          weights_n.size.should eq(expected_weights_first_sub_size)
        end
      end

      describe "#train" do
        it "returns a Float64" do
          net.train(inputs, outputs).should be_a(Float64)
        end

        it "updates the net" do
          net.train(inputs, outputs)
          net.activation_nodes.should_not eq(expected_activation_nodes)
        end
      end
    end
  end

  describe "#eval" do
    describe "when given a net with structure of [3, 2]" do
      it "returns output nodes of expected size" do
        in_size = 3
        out_size = 2
        inputs = [3, 2, 3]
        structure = [in_size, out_size]
        net = Ai4cr::NeuralNetwork::Backpropagation.new(structure)
        y = net.eval(inputs)
        y.size.should eq(out_size)
      end
    end

    describe "when given a net with structure of [2, 4, 8, 10, 7]" do
      it "returns output nodes of expected size" do
        in_size = 2
        layer_sizes = [4, 8, 10]
        out_size = 7
        structure = [in_size] + layer_sizes + [out_size]
        inputs = [2, 3]
        net = Ai4cr::NeuralNetwork::Backpropagation.new(structure)
        y = net.eval(inputs)
        y.size.should eq(out_size)
      end
    end
  end

  describe "#dump" do
    describe "when given a net with structure of [3, 2]" do
      structure = [3, 2]
      net = Ai4cr::NeuralNetwork::Backpropagation.new([3, 2]).init_network
      # s = Marshal.dump(net)
      # x = Marshal.load(s)
      # s = net.to_json
      # x = Ai4cr::NeuralNetwork::Backpropagation.from_json(s)
      s = net.marshal_dump
      structure = s[:structure]
      x = Ai4cr::NeuralNetwork::Backpropagation.new(structure).init_network
      x.marshal_load(s)

      it "@structure of the dumped net matches @structure of the loaded net" do
        assert_equality_of_nested_list net.structure, x.structure
      end

      it "@disable_bias on the dumped net matches @disable_bias of the loaded net" do
        net.disable_bias.should eq(x.disable_bias)
      end

      it "@learning_rate of the dumped net approximately matches @learning_rate of the loaded net" do
        assert_approximate_equality net.learning_rate, x.learning_rate
      end

      it "@momentum of the dumped net approximately matches @momentum of the loaded net" do
        assert_approximate_equality net.momentum, x.momentum
      end

      it "@weights of the dumped net approximately matches @weights of the loaded net" do
        assert_approximate_equality_of_nested_list net.weights, x.weights
      end

      it "@last_changes of the dumped net approximately matches @last_changes of the loaded net" do
        assert_approximate_equality_of_nested_list net.last_changes, x.last_changes
      end

      it "@activation_nodes of the dumped net approximately matches @activation_nodes of the loaded net" do
        assert_approximate_equality_of_nested_list net.activation_nodes, x.activation_nodes
      end
    end
  end

  describe "#train" do
    describe "when given a net with structure of [3, 2]" do
      structure = [3, 2]
      net = Ai4cr::NeuralNetwork::Backpropagation.new([3, 2]).init_network

      it "returns an error of type Float64" do
        inputs = [1, 2, 3]
        outputs = [4, 5]
        error_value = net.train(inputs, outputs)
        error_value.should be_a(Float64)
      end
    end
  end
end
