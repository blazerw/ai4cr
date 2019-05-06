# This is a unit test file for the hopfield neural network AI4r implementation
# 
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require "./../../spec_helper"

def common_data_set
  Ai4cr::Data::DataSet.new data_items: [
    [1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1],
    [-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1],
    [-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1],
  ]
end
describe Ai4cr::NeuralNetwork::Hopfield do

  it "can initialize nodes" do
    net = Ai4cr::NeuralNetwork::Hopfield.new
    data_set = Ai4cr::Data::DataSet.new data_items: [[1,1,0,0,1,1,0,0]]
    net.initialize_nodes(data_set).should eq([-1,-1,-1,-1,-1,-1,-1,-1])
  end

  it "can initialize weights" do
    net = Ai4cr::NeuralNetwork::Hopfield.new
    data_set = common_data_set
    net.initialize_nodes data_set
    net.initialize_weights(data_set)
    net.weights.not_nil!.size.should eq(15)
    net.weights.not_nil!.each_with_index { |w_row, i| w_row.size.should eq(i+1) }
  end

  it "runs" do
    net = Ai4cr::NeuralNetwork::Hopfield.new
    data_set = common_data_set
    net.train data_set
    pattern : Array(Int32) = [1,1,-1,1,1,1,-1,-1,1,1,-1,-1,1,1,1,-1]
    100.times do
      pattern = net.run(pattern)
    end
    pattern.should eq([1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1])
  end

  it "evals" do
    net = Ai4cr::NeuralNetwork::Hopfield.new
    data_set = common_data_set
    net.train data_set
    p = [1,1,-1,1,1,1,-1,-1,1,1,-1,-1,1,1,1,-1]
    net.eval(p).should eq(data_set.data_items[0])
    p = [-1,-1,1,1,1,-1,1,1,-1,-1,1,-1,-1,-1,1,1]
    net.eval(p).should eq(data_set.data_items[1])
    p = [-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,-1,-1]
    net.eval(p).should eq(data_set.data_items[2])
    p = [-1,-1,1,1,1,1,1,1,-1,-1,-1,-1,1,-1,-1,-1]
    net.eval(p).should eq(data_set.data_items[3])
  end

end
