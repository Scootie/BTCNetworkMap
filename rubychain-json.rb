#Copyright (c) 2014 Caleb Ku
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

require 'chain'
require 'pp'
require 'thread'
require 'json'

myapikey="whatismyapikey"
myapisecret="whatismyapisecret"
myaddress="theaddress"
numberoftxs=20
depth=2
json_filename="output.json"

class Chaininfo

	@@chainclient
	@@all_links=[]
	@@all_wallets=[]
	@@lookdeep
	@@lock=Mutex.new
	@@allthreads=[]

	def initialize(apikey, apisecret,txnumber)
		@@chainclient = Chain::Client.new(key_id: apikey, key_secret: apisecret)
		@@tx_number = txnumber
	end


	def self.addtoset(set,addme)
		if (set.include? addme) == false
			set.push(addme)	
		end
		return set
	end


	def self.nodelinks(input_array,output_array)
		array_map=[]
		input_array.each do |inputs|
			output_array.each do |outputs|
				tx_map=[]
				tx_map.push(inputs)
				tx_map.push(outputs)
				array_map = addtoset(array_map,tx_map)
			end

		end
		return array_map
	end

 

	def self.tx_parsespider(transaction_array,origin_addy)
		input_array=[]
		output_array=[]
		more_addy=[]
		transaction_array['inputs'].each do |tx_input|
			if tx_input.has_key?("addresses")
				tx_input['addresses'].each do |input_addy|
					input_array=addtoset(input_array,input_addy)
					if input_addy!=origin_addy
						more_addy=addtoset(more_addy,input_addy)
					end
				end
			end
		end
		transaction_array['outputs'].each do |tx_output|
			tx_output['addresses'].each do |output_addy|
				output_array=addtoset(output_array,output_addy)
					if output_addy!=origin_addy
						more_addy=addtoset(more_addy,output_addy)
					end
			end
		end


		if input_array.empty?
			input_array.push("NewCoins")
		end

		return input_array, output_array, more_addy
	end



	def alltxs(queryaddress,spiderdepth)
		@@chainclient.each_address_transactions(queryaddress).take(@@tx_number).each do |tx_array|
			inputs, outputs, inqueue_addy=self.class.tx_parsespider(tx_array,queryaddress)
			tx_links=self.class.nodelinks(inputs,outputs)
			
			@@lock.synchronize do
				tx_links.each do |links|
					@@all_links=self.class.addtoset(@@all_links,links)
				end
				inqueue_addy.each do |sub_addy|
					@@all_wallets=self.class.addtoset(@@all_wallets,sub_addy)
				end
			end
			
			if spiderdepth>0
				spiderdepth-=1
				inqueue_addy.each do |sub_addy|
					@@allthreads << Thread.new do 
						
						alltxs(sub_addy,spiderdepth)
					end
				end
			end
			
		end
	end
	
	def totalmap
		@@allthreads.map(&:join)
		return @@all_wallets, @@all_links
		
	end	


end


start=Chaininfo.new(myapikey, myapisecret, numberoftxs)
start.alltxs(myaddress,depth)
startwallet , startlinks = start.totalmap

json_nodes=[]
json_nodes[0]={"id"=> "n0", "label" => myaddress,"x"=>0, "y"=>0, "size"=> 30}

nodes_keymap=startwallet
nodes_keymap.insert(0,myaddress)
coinoffset=1

if (startlinks.assoc("NewCoins"))!=nil
	coinoffset=2
	nodes_keymap.insert(1,"NewCoins")
	json_nodes[1]={"id"=> "n1", "label" => "NewCoins","x"=>20, "y"=>20, "size"=> 20}
end

startwallet.each_with_index do |wallet,i|
	j=i+coinoffset
	x_cord= Random.new.rand(1..100)
	y_cord=Random.new.rand(1..100)
	json_nodes[j]={"id"=> "n#{j}", "label" => wallet,"x"=>x_cord, "y"=>y_cord, "size"=> 3}
end

json_links=[]
startlinks.each_with_index do |link, i|
	x_cord=link[0]
	y_cord=link[1]
	nodex_cord=nodes_keymap.index(x_cord)
	nodey_cord=nodes_keymap.index(y_cord)
	json_links[i]={"id"=> "e#{i}", "source"=> "n#{nodex_cord}", "target"=> "n#{nodey_cord}"}
end

master_output={"nodes"=>json_nodes, "edges"=>json_links}


File.open(json_filename,"w") do |f|
  f.write(JSON.pretty_generate(master_output))
end
