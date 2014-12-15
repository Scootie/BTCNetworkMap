
##Brief Analysis
The core of this program is a parsing script (rubychain.rb) that takes a single BTC address input. From this "node", we query "n" of recent transactions, which contain a list of input/output BTC addresses. These addresses are parsed to preserve "node links." From each of these addresses, we go to "n" depth and repeat the processes, exploring children connections.

Due to taint (the mixing of BTC from multiple addresses to a single/few addresses), it's possible to create an map with thousands of BTC addresses and links, with only a shallow depth and dozen transaction records per address.

The following address [1Lym9twRJ4xjbHSt5zBGx7Tkb3EFEXn17y](https://blockchain.info/taint/1Lym9twRJ4xjbHSt5zBGx7Tkb3EFEXn17y) provides a good example. This is a random address I pulled off blockchain.info. Each transaction has no more than 50% taint. 

![No Children](https://github.com/Scootie/BTCWalletMap/blob/master/examples/taint_nochildren.png)

Without any children addresses and a transaction history set to 10, we end up with 298 unique BTC addresses with 352 connections between them. 

![Two Children](https://github.com/Scootie/BTCWalletMap/blob/master/examples/taint_2children.png)

If we increase children depth to 2, the number explodes to 4968 unique BTC addresses with 7695 connections.

![BTCRecover](https://github.com/Scootie/BTCWalletMap/blob/master/examples/btcchris.png)

Let's look at a more "typical" example. We'll use the BTC donate address associated with [Christopher Gurnee's btcrecover program](https://github.com/gurnec/btcrecover). This is a lot more coherent even without implementing 3D modeling. Doing confidence and correlation statistics could take up several pages of dicussion, but as a brief recap. Even though we query 20 transactions and a depth of 2, we find that there are actually very few donations made to this address. However, the few donations that are actually made occur from "NewCoins", which makes some sense as BTCrecover is a tool meant to help recover wallets when their owners have forgotten the password. This data tells us that most of those donating are miners. Additionally, we see a high correlation address associated with the donation address (upper left-hand corner), which makes it likely that it's an alternative address in the same wallet(lower right-hand corner).


##Information Sources
[Blockchain.info](http://www.blockchain.info) and [Chain.com](http://chain.com) both provide excellent APIs for several programming langauges that allow you to connect to the BTC network and parse information about addresses, wallets, transactions, etc... I originally wrote much of the code to function with Blockchain's Ruby API. The company frankly provides better striaghtforward coherent documentation, but I ran into an issue where their API engine only allows you to retrieve than last 50 transactions for any given address. This can be overcome by switching to the http get requests to filter on JSON data, but you have to use page offsets to get the "next 50" transactions. 

For optimization reasons, I wanted to minimize the number of actual API queries. This is where Chain.com comes out ahead, as their API allows you to specify a maximum of 500 transactions per query.

At the software level, this script utilizes ruby's thread library. Everytime a child node is found and is within the specified parsing depth, a new "thread" is issued to traverse down and explore associated addresses and connections. For this reason, the script may take sometime to fully complete, and write to a json file.
