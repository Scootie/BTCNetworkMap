BTCWalletMap
============
This is a proof of concept program that serves to demonstate the pseudo-anonymous nature of crypto-currency using BTC addresses in a node link map/diagram.

##Abstract
Much has been made about the anonymous nature of bitcoins. However, this is a misconception. Under most circumstances, it's very possible to track down the sender/receiver of BTC. At some point, all BTC holders must have converted from fiat currency. This holds true for miners who cash out and or those who seek to invest in BTC.

The majority of the time, this conversion occurs via formal exchanges like [Coinbase](http://coinbase.com), [Circle](http://www.circle.com), etc... As these entities, interact with real-life bank accounts, they posses transaction records that provides evidence of current balances. Thus, tracking an individual, is simply a matter of mapping out the BTC address that's sending and receiving to this these exchanges.

Even for an individual with multiple wallets addresses, it's still possible to do deep financial analysis with a high degree of confidence. As "specific" BTC blocks are transmitted as part of a BTC transaction, correlation analysis between send/receive addresses and the specific blocks narrows down individual transactions. 

Even if BTC transactions occur locally (i.e. [localbitcoins.com](http://localbitcoins.com)), the nature of the local transaction makes it possible for government entities to check real-life cameras (from stores, traffic, etc...) to find a specific person.

##About the Code
This project provided me the first opportunity to write something in Ruby. It took a couple of days to learn the language, but it feels a bit leaner and cleaner than Python.

The core of this program is a parsing script (rubychain.rb) that takes a single BTC address input. From this "node", we query "n" of recent transactions, which contain a list of input/output BTC addresses. These addresses are parsed to preserve "node links." From each of these addresses, we go to "n" depth and repeat the processes, exploring children connections.

Due to taint (the mixing of BTC from multiple addresses to a single/few addresses), it's possible to create an map with thousands of BTC addresses and links, with only a shallow depth and dozen transaction records per address.

The following address [1Lym9twRJ4xjbHSt5zBGx7Tkb3EFEXn17y](https://blockchain.info/taint/1Lym9twRJ4xjbHSt5zBGx7Tkb3EFEXn17y) provides a good example. This is a random address I pulled off blockchain.info. Each transaction has no more than 50% taint. 

![No Children](https://github.com/Scootie/BTCWalletMap/blob/master/examples/taint_nochildren.png)

Without any children addresses and a transaction history set to 10, we end up with 298 unique BTC addresses with 352 connections between them. 

![Two Children](https://github.com/Scootie/BTCWalletMap/blob/master/examples/taint_2children.png)

If we increase children depth to 2, the number explodes to 4968 unique BTC addresses with 7695 connections.

This script at the software level utilizes ruby's thread library. Everytime a child node is found and is within the specified parsing depth, a new "thread" is issued to traverse down and explore associated addresses and connections. For this reason, the script may take sometime to fully complete, and write to a json file.   

##Information Sources
[Blockchain.info](http://www.blockchain.info) and [Chain.com](http://chain.com) both provide excellent APIs for several programming langauges that allow you to connect to the BTC network and parse information about addresses, wallets, transactions, etc... I originally wrote much of the code to function with Blockchain's Ruby API. The company frankly provides better striaghtforward coherent documentation, but I ran into an issue where their API engine only allows you to retrieve than last 50 transactions for any given address. This can be overcome by switching to the http get requests to filter on JSON data, but you have to use page offsets to get the "next 50" transactions. 

For optimization reasons, I wanted to minimize the number of actual API queries. This is where Chain.com comes out ahead, as their API allows you to specify a maximum of 500 transactions per query.

## Requirements
  
* [SigmaJS](http://sigmajs.org)
* Ruby 1.9 or higher
* Chain.com's Ruby lib
  * Chain.com API key (free, you just need to register)
  
## Installation instructions

Will be added soon.

## License

Copyright Caleb Ku 2014. Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
