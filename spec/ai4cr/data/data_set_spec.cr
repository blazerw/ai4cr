# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require "./../../spec_helper"

alias CellType = Ai4cr::Data::DataSet::CellType

describe Ai4cr::Data::DataSet do
  it "loads CSV with labels" do
    set = Ai4cr::Data::DataSet.new.load_csv_with_labels("#{File.dirname(__FILE__)}/data_set.csv")
    # assert_equal 120, set.data_items.length
    set.data_items.size.should eq(120)
    # assert_equal ["zone", "rooms", "size", "price"], set.data_labels
    set.data_labels.should eq(["zone", "rooms", "size", "price"])
    # assert_equal ["Moron Sur (GBA)","2","[28 m2 - 39 m2]","[29K-35K]"], set.data_items.first
    set.data_items.first.should eq(["Moron Sur (GBA)","2","[28 m2 - 39 m2]","[29K-35K]"])
  end

  it "loads and parses floats from CSV with labels" do
    set = Ai4cr::Data::DataSet.new.parse_csv_with_labels("#{File.dirname(__FILE__)}/data_set.csv")
    # assert_equal 120, set.data_items.length
    set.data_items.size.should eq(120)
    # assert_equal ["zone", "rooms", "size", "price"], set.data_labels
    set.data_labels.should eq(["zone", "rooms", "size", "price"])
    # assert_equal ["Moron Sur (GBA)",2.0,"[28 m2 - 39 m2]","[29K-35K]"], set.data_items.first
    set.data_items.first.should eq(["Moron Sur (GBA)",2.0,"[28 m2 - 39 m2]","[29K-35K]"])
  end

  it "builds domains" do
    domains =  [  Set.new(["New York", "Chicago"]), 
                  Set.new(["M", "F"]), 
                  [5, 85],
                  Set.new(["Y", "N"]) ]
    data = Array(Array(CellType)).new(6)
    data << [ "New York".as(CellType), "M".as(CellType), 23.as(CellType), "Y".as(CellType) ]
    data << [ "Chicago", "M", 85, "Y"]
    data << [ "New York", "F", 32, "Y"]
    data << [ "New York", "M", 5, "N"]
    data << [ "Chicago", "M", 15, "N"]
    data << [ "Chicago", "F", 45, "Y"]
    labels = ["city", "gender", "age", "result"]
    set = Ai4cr::Data::DataSet.new(data_items: data, data_labels: labels)
    # assert_equal domains, set.build_domains
    set.build_domains.should eq(domains)
    # assert_equal domains[0], set.build_domain("city")
    set.build_domain("city").should eq(domains[0])
    # assert_equal domains[1], set.build_domain(1)
    set.build_domain(1).should eq(domains[1])
    # assert_equal domains[2], set.build_domain("age")
    set.build_domain("age").should eq(domains[2])
    # assert_equal domains[3], set.build_domain("result")
    set.build_domain("result").should eq(domains[3])
  end

  it "sets data labels" do
    labels = ["A", "B"]
    set = Ai4cr::Data::DataSet.new.set_data_labels(labels)
    # assert_equal labels, set.data_labels
    set.data_labels.should eq(labels)
    set = Ai4cr::Data::DataSet.new(data_labels: labels)
    # assert_equal labels, set.data_labels
    set.data_labels.should eq(labels)
    set = Ai4cr::Data::DataSet.new(data_items: [[ 1.as(CellType), 2.as(CellType), 3.as(CellType)]])
    # assert_raise(ArgumentError) { set.set_data_labels(labels) }
    expect_raises(ArgumentError) { set.set_data_labels(labels) }
  end

  it "sets data items" do
    items = [  [ "New York", "M", "Y"],
               [ "Chicago", "M", "Y"],
               [ "New York", "F", "Y"],
               [ "New York", "M", "N"],
               [ "Chicago", "M", "N"],
               [ "Chicago", "F", "Y"] ]
    set = Ai4cr::Data::DataSet.new.set_data_items(items)
    # assert_equal items, set.data_items
    set.data_items.should eq(items)
    # assert_equal 3, set.data_labels.length
    set.data_labels.size.should eq(3)
    items << items.first[0..-2]
    expect_raises(ArgumentError) { set.set_data_items(items) }
    expect_raises(ArgumentError) { set.set_data_items(nil) }
    expect_raises(ArgumentError) { set.set_data_items([1]) }
  end

  it "gets mean or mode" do
    items = [  [ "New York", 25, "Y"],
               [ "New York", 55, "Y"],
               [ "Chicago", 23, "Y"],
               [ "Boston", 23, "N"],
               [ "Chicago", 12, "N"],
               [ "Chicago", 87, "Y"] ]
    set = Ai4cr::Data::DataSet.new.set_data_items(items)
    # assert_equal ["Chicago", 37.5, "Y"], set.get_mean_or_mode
    set.get_mean_or_mode.should eq(["Chicago", 37.5, "Y"])
  end

  it "is indexable" do
    items = [  [ "New York", 25, "Y"],
               [ "New York", 55, "Y"],
               [ "Chicago", 23, "Y"],
               [ "Boston", 23, "N"],
               [ "Chicago", 12, "N"],
               [ "Chicago", 87, "Y"] ]
    set = Ai4cr::Data::DataSet.new.set_data_items(items)
    # assert_equal set.data_labels, set[0].data_labels
    set[0].data_labels.should eq(set.data_labels)
    # assert_equal [[ "New York", 25, "Y"]], set[0].data_items
    set[0].data_items.should eq([[ "New York", 25, "Y"]])
    # assert_equal [[ "Chicago", 23, "Y"],[ "Boston", 23, "N"]], set[2..3].data_items
    set[2..3].data_items.should eq([[ "Chicago", 23, "Y"],[ "Boston", 23, "N"]])
    # assert_equal items[1..-1], set[1..-1].data_items
    set[1..-1].data_items.should eq(items[1..-1])
  end

  it "has category label" do
    labels = ["Feature_1", "Feature_2", "Category Label"]
    set = Ai4cr::Data::DataSet.new(data_labels: labels)
    # assert_equal "Category Label", set.category_label
    set.category_label.should eq("Category Label")
  end

end
