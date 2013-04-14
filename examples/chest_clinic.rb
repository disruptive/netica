#!/usr/bin/env jruby
require 'netica'

# Use Netica::Environment.engage to create a Netica Environ singleton object:
processor = Netica::Environment.engage

# Create an ActiveNetwork, using a `.dne` file created in the Netica Application.
my_network = Netica::ActiveNetwork.new("some_identifiying_token", "#{File.dirname(__FILE__)}/ChestClinic.dne")

# View the nodes in the network.
p my_network.network.nodes

# Read the value of a Belief node.
tb_node = my_network.network.node("Tuberculosis")
belief = tb_node.value("present")
p "The probability of tuberculosis is #{belief}."

# Set the state of the XRay node to Abnormal.
xray_node = my_network.network.node("XRay")
xray_node.value = "abnormal"

# Then, re-read the value of the Belief node.
belief2 = tb_node.value("present")
p "Given an abnormal X-ray... The probability of tuberculosis is #{belief2}."