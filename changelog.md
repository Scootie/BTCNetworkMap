Changelog
============
## v0.9
* Speed optimizations using Ruby's built in Set function (changed from Array)
* Master record of edges (links, btc address connections) is now a Hash (implementing Mash from Hashie)
  * tree structured in combination with Sets 
    * {source1 => <Set: target1, target2>, source2 => <Set: target2, target3>, }
* Output option to gexf or json
* json output unchanged, continues to use base template from [sigma.js](https://github.com/jacomyal/sigma.js/)
* gexf output optimized for [Gephi](http://www.gephi.org) , implements layout similar to [LesMiserables.gexf from Gephi](https://github.com/gephi/gephi-toolkit-demos/blob/master/src/org/gephi/toolkit/demos/resources/LesMiserables.gexf) 
* moved output functions into seperate class to clean up code
* implemented "verbosetx" setting to solve problem with unconnected nodes. Chain's API limits input/output addresses per transaction to 50 when you query an address using each_address_transactions. New setting checks to see if there are more than 50 addresses, when such a case arises, issues a new API call to get complete transaction information.