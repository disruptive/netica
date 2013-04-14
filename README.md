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


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Legal

Netica and Norsys are registered trademarks of Norsys Software Corp.