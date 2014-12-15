BTCWalletMap
============
This is a proof of concept program that serves to demonstate the pseudo-anonymous nature of crypto-currency using BTC addresses in a node link map/diagram.

##Abstract
Much has been made about the anonymous nature of bitcoins. However, this is a misconception. Under most circumstances, it's very possible to track down the sender/receiver of BTC. At some point, all BTC holders must have converted from fiat currency. This holds true for miners who cash out and or those who seek to invest in BTC.

The majority of the time, this conversion occurs via formal exchanges like [Coinbase](http://coinbase.com), [Circle](http://www.circle.com), etc... As these entities, interact with real-life bank accounts, they posses transaction records that provides evidence of current balances. Thus, tracking an individual, is simply a matter of mapping out the BTC address that's sending and receiving to this these exchanges.

Even for an individual with multiple wallets addresses, it's still possible to do deep financial analysis with a high degree of confidence. As "specific" BTC blocks are transmitted as part of a BTC transaction, correlation analysis between send/receive addresses and the specific blocks narrows down individual transactions. 

Even if BTC transactions occur locally (i.e. [localbitcoins.com](http://localbitcoins.com)), the nature of the local transaction makes it possible for government entities to check real-life cameras (from stores, traffic, etc...) to find a specific person.

##Settings

These settings need to be changed in the rubychain.rb file for the json to be generated.
```Ruby
myapikey="whatismyapikey"
myapisecret="whatismyapisecret"
myaddress="theaddress"
numberoftxs=20
depth=2
json_filename="output.json"
```

## Requirements
  
* [SigmaJS](http://sigmajs.org)
* Ruby 1.9 or higher
* Chain.com's Ruby lib
  * Chain.com API key (free, you just need to register)
  
## Installation instructions

Will be added soon.

## License

Copyright Caleb Ku 2014. Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
