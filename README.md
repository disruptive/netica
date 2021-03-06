# Netica

The Netica gem provides tools for interacting with Bayesian networks using JRuby and the Netica-J API, published by [Norsys Software Corp.](http://www.norsys.com).

## Installation

Download the Netica-J API from Norsys and place the NeticaJ.jar file in your JRuby load path. Possible locations include...

    /Library/Java/Extensions
    /Network/Library/Java/Extensions
    /System/Library/Java/Extensions
    /usr/lib/java

Add this line to your application's Gemfile:

    gem 'netica'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install netica

## Usage

Here's an example, based the Probabilistic Inference example in the Netica-J Manual.

Use Netica::Environment.engage to create a Netica Environ singleton object:

    processor = Netica::Environment.engage
    => true

Create an ActiveNetwork, using a `.dne` file created in the Netica Application.

    my_network = Netica::ActiveNetwork.new("some_identifiying_token", "./examples/ChestClinic.dne")
    => #<Netica::ActiveNetwork:0x58767e95 @network=#<Netica::BayesNetwork:0x4b709592 @current_network=#<Java::NorsysNetica::Net:0x75e82fc2>, @dne_file_path="./examples/ChestClinic.dne">, @token="some_identifiying_token">

View the nodes in the network.

    my_network.network.nodes
    => #<Java::NorsysNetica::NodeList:1738447710 size:8 nodes:["NatureNode:VisitAsia", "NatureNode:Tuberculosis", "NatureNode:Smoking", "NatureNode:Cancer", "NatureNode:TbOrCa", "NatureNode:XRay", "NatureNode:Bronchitis", "NatureNode:Dyspnea"]>


Read the value of a Belief node.

    tb_node = my_network.network.node("Tuberculosis")
    => #<Java::NorsysNetica::NatureNode:Tuberculosis value:{"present"=>0.010399998165667057, "absent"=>0.9896000027656555}>

    tb_node.value("present")
    => 0.010399998165667057

Set the state of the XRay node to Abnormal.

    xray_node = my_network.network.node("XRay")
    => #<Java::NorsysNetica::NatureNode:XRay value:{"abnormal"=>0.1102900430560112, "normal"=>0.8897099494934082}>

    xray_node.value = "abnormal"
    => "abnormal"

Then, re-read the value of the Belief node.

    p tb_node.value("present")
    0.09241089224815369
    => 0.09241089224815369

## Release Notes

### Version 1.0.0.pre

* Split ActiveNetwork's out-of-process storage and retrieval methods into a new subclass, StorableNetwork.
* Add filename parameter to StorableNetwork#find, allowing a stored network's .dne file to be updated.
* Built and tested with JRuby 1.7.9

### Version 0.0.20

Delete a stored network by token with ActiveNetwork#destroy_by_token.

### Version 0.0.19

Add `load_from_storage` parameter to ActiveNetwork#find so we can retrieve the state of a network in storage without instantiating it. Defaults to true.

### Version 0.0.18

* Return a hash from ActiveNetwork#destroy indicating the outcome of deletion in each storage location. 
* Make the java_library_path task visible in `rake -vT`

### Version 0.0.17

* We don't wait, we sleep when a network is locked.

### Version 0.0.16

* Add ActiveNetwork#destroy

### Version 0.0.15

* Lock in-use ActiveNetworks to prevent editing collisions

### Version 0.0.14

* User may specify optional container for Active Networks

### Version 0.0.11

* Move ActiveNetworks inside Environ

### Version 0.0.10

* Log Specifics of Node Changes

### Version 0.0.9

* Attempt to make Netica Environ a Singleton in JRuby 1.7

### Version 0.0.8

* Added Batch Processing as BayesNetwork#analyze, which takes a hash of node names and their values including an "id", and a list of output nodes, and returns the resulting values of the output nodes, along with the "id".

### Version 0.0.7

* Added Node Set identification and collection to BayesNetwork

### Version 0.0.6

* Changed BayesNetwork#getNode to BayesNetwork#node
* Find a location for the NeticaJ.jar file using `rake netica:java_library_path`
* Expand documentation

## Legal

Netica and Norsys are registered trademarks of Norsys Software Corp.