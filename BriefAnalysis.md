
##Brief Analysis
The core of this program is a parsing script (rubychain.rb) that takes a single BTC address input. From this "node", we query "n" of recent transactions, which contain a list of input/output BTC addresses. These addresses are parsed to preserve "node links." From each of these addresses, we go to "n" depth and repeat the processes, exploring children connections.

Due to taint (the mixing of BTC from multiple addresses to a single/few addresses), it's possible to create an map with thousands of BTC addresses and links, with only a shallow depth and dozen transaction records per address. We'll use the BTC donate address associated with [Christopher Gurnee's btcrecover program](https://github.com/gurnec/btcrecover). 

```Ruby
Legend
Query BTC Address: Red
NewCoins: Blue
Other BTC Addresses: Green
```

![1Deep-5TX](/examples/gephi-207-206.png)

Set to a depth of 1 and 5 transactions, we end up with 207 unique BTC addresses with 206 connections between them. (Unconnected green hub is due to limitations in API calls, which default to 50 addresses per transaction. Read [changelog](/changelog.md) for more information about "verbose" parsing.) 

![1Deep-10TX](/examples/gephi-2997-3097.png)

If we increase transaction number to 10 transactions, the number edges up to 2997 unique BTC addresses with 3097 connections.

![2Deep-10TX](/examples/gephi-20212-45968.png)

If we increase depth to 2, the number explodes further to 20212 unique BTC addresses with 45968 connections. 

Doing confidence and correlation statistics could take up several pages of dicussion, but as a brief recap. Even with the first example (Depth:1, transactions: 5) we find that there are actually very few donations made to this address. However, the few donations that are actually made occur from "NewCoins", which makes some sense as BTCrecover is a tool meant to help recover wallets when their owners have forgotten the password. This data tells us that most of those donating are miners. Additionally, we see a lot of 2nd degree connections with one specific BTC address, which may indicate an address in the same wallet or one used for an exchange.

Analysis can be made even more comprehensive by expanding the code to indicate the breathe of each transaction. For example, using thicker and larger lines to illustrate transactions involving large amounts of BTC. Another option is to an indefinite number to the crawling depth and instead loop until the shortest connection between two addresses is found. This would be highly relevant in a situation when checking an address against a known database of exchanges used for fiat conversion. 

I'm unable to create larger data models in gephi because my workstation can only process so many nodes before it crashes with my meager hardware. However, this demonstates the potential use of this type of analysis.

##Information Sources
[Blockchain.info](http://www.blockchain.info) and [Chain.com](http://chain.com) both provide excellent APIs for several programming langauges that allow you to connect to the BTC network and parse information about addresses, wallets, transactions, etc... I originally wrote much of the code to function with Blockchain's Ruby API. The company frankly provides better striaghtforward coherent documentation, but I ran into an issue where their API engine only allows you to retrieve than last 50 transactions for any given address. This can be overcome by switching to the http get requests to filter on JSON data, but you have to use page offsets to get the "next 50" transactions. 

For optimization reasons, I wanted to minimize the number of actual API queries. This is where Chain.com comes out ahead, as their API allows you to specify a maximum of 500 transactions per query. By querying information about each address instead of each transaction, we reduce the overhead involved with the an overwhelming number of API calls. 

At the software level, this script utilizes ruby's thread library. Everytime a child node is found and is within the specified parsing depth, a new "thread" is issued to traverse down and explore associated addresses and connections. For this reason, the script may take sometime to fully complete, and write to a json file.
