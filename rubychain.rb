# -*- coding: UTF-8 -*-
#Copyright (c) 2014 Caleb Ku
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

require 'chain'
require 'thread'
require 'nokogiri'
require 'set'
require 'hashie'
require 'json'

myapikey="apikey"
myapisecret="apisecret"
myaddress="origin-btc-address"
verbosetx= "no" #yes or no
numberoftxs=5
depth=1
filename="rubychain"
type="json" #gexf or json


class Chaininfo

	@@chainclient
	@@all_wallets=Set.new
	@@lookdeep
	@@lock=Mutex.new
	@@allthreads=[]
	@@link_tree = Hashie::Mash.new
	@@morethan50tx

	def initialize(apikey, apisecret,origin, txnumber, verbosetx)
		@@chainclient = Chain::Client.new(key_id: apikey, key_secret: apisecret)
		@@tx_number = txnumber
		@@all_wallets<< origin
		@@morethan50tx = verbosetx
	end

	def self.nodelinks(input_array,output_array)
		array_map=Set.new
		input_array.each do |inputs|
			output_array.each do |outputs|

				if inputs!=outputs
					tx_map=[]
					tx_map.push(inputs)
					tx_map.push(outputs)
					array_map << tx_map
				end
			end

		end
		return array_map
	end

 

	def self.tx_parsespider(transaction_array,origin_addy)
		input_array=Set.new
		output_array=Set.new
		more_addy=Set.new

		if @@morethan50tx == "yes"
			outputcounter=0
			transaction_array['outputs'].each do |txs|
				outputcounter+=1
			end

			if outputcounter>49
				transaction_array=@@chainclient.get_transaction(transaction_array['hash'])
			end
		end

		transaction_array['inputs'].each do |tx_input|
			if tx_input.has_key?("addresses")
				tx_input['addresses'].each do |input_addy|
					input_array << input_addy
					if input_addy!=origin_addy
						more_addy << input_addy
					end
				end
			end
		end
		transaction_array['outputs'].each do |tx_output|
			tx_output['addresses'].each do |output_addy|
				output_array << output_addy
					if output_addy!=origin_addy
						more_addy << output_addy
					end
			end
		end

		if input_array.empty?
			input_array << "NewCoins"
		end

		return input_array, output_array, more_addy
	end



	def alltxs(queryaddress,spiderdepth)
		@@chainclient.each_address_transactions(queryaddress).take(@@tx_number).each do |tx_array|
			inputs, outputs, inqueue_addy=self.class.tx_parsespider(tx_array,queryaddress)
			tx_links=self.class.nodelinks(inputs,outputs)

			@@lock.synchronize do

				tx_links.each do |links|
					if @@link_tree.key?(links[0])==false
						@@link_tree[links[0]]=Set.new
					end
					@@link_tree[links[0]] << links[1]		
				end
				inqueue_addy.each do |sub_addy|
					if (@@all_wallets.include? sub_addy) == true
						inqueue_addy.delete(sub_addy)
					else
						@@all_wallets << sub_addy
					end
				end
			end
			if spiderdepth>0
		
				inqueue_addy.each_with_index do |sub_addy, i|
					@@allthreads.push(Thread.new {

						alltxs(sub_addy,spiderdepth-=1)

						})

				end
			end
			
		end
	end
	
	def totalmap
		
		@@allthreads.each {|t| t.join}
		return @@all_wallets, @@link_tree
		
	end	


end


class Outputter
	def givemegexf(gexf_filename,wallets,tree,origin)
		totalnodes=0
		tree.each do |source, targetset|
			totalnodes+=targetset.length
		end

		wallets.delete("NewCoins")
		wallets.delete(origin)
		nodes_keymap=wallets.to_a

		nodes_keymap.insert(0,origin)

		if tree.key?("NewCoins")==true
			nodes_keymap.insert(1,"NewCoins")
		end

		gexf= Nokogiri::XML::Builder.new do |xml|
			xml.gexf('xmlns:viz'=> 'xmlns:viz="http:///www.gexf.net/1.1draft/viz','xmlns'=>'http://www.gexf.net/1.1draft', 'version'=>'1.1'){

				xml.meta(lastmodifieddate=Time.now.utc) {
					xml.creator 'BTCNetworkMap'	
				}
				xml.graph('defaultedgetype'=>'directed', 'idtype'=>'string' ,'type'=>'static'){
					xml.attributes('class'=>'node', 'mode'=>'static'){
						xml.attribute('id'=>'modularity_class', 'title'=>'Modularity_Class', 'type'=>'integer')
					}
					xml.nodes('count'=>"#{nodes_keymap.length}") {
					nodes_keymap.each_with_index do |address, i|
						xml.node('id'=>"#{i}", 'label'=>"#{address}") {
							xml.attvalues{
								xml.attvalue('for'=>'modularity_class', 'value'=>'0')
							}
							if i==0
								xml['viz'].size('value'=>'30')
								xml['viz'].color('b'=>'91', 'g'=>'91', 'r'=>'245')
							elsif i==1 && address=="NewCoins"
								xml['viz'].size('value'=>'20')
								xml['viz'].color('b'=>'245', 'g'=>'91', 'r'=>'91')
							else
								xml['viz'].size('value'=>'4')
								xml['viz'].color('b'=>'194', 'g'=>'245', 'r'=>'91')
							end
							xml['viz'].position('x'=>Random.rand(0...400), 'y'=>Random.rand(0...400), 'z'=>0)						
						}
					end
					}
					xml.edges('count'=>"#{totalnodes}"){
					edgecounter=0
					tree.each do |source, targetset|
						node_source_cord=nodes_keymap.index(source)
						targetset.each do |target|
							node_target_cord=nodes_keymap.index(target)
							xml.edge('id'=>"#{edgecounter}", 'source'=>"#{node_source_cord}",'target'=>"#{node_target_cord}")
							edgecounter+=1
						end
					end
					}
				}
			}
		end

		File.open("#{gexf_filename}.gexf","w") do |f|
		  f.write(gexf.to_xml)
		end
	
	end

	def givemejson(json_filename,wallets,tree,origin)
		wallets.delete("NewCoins")
		wallets.delete(origin)

		json_nodes=[]
		json_nodes[0]={"id"=> "n0", "label" => origin,"x"=>0, "y"=>0, "size"=> 30}

		nodes_keymap=wallets.to_a
		nodes_keymap.insert(0,origin)
		coinoffset=1

		if tree.key?("NewCoins")==true
			nodes_keymap.insert(1,"NewCoins")
			coinoffset=2
			json_nodes[1]={"id"=> "n1", "label" => "NewCoins","x"=>20, "y"=>20, "size"=> 20}
		end

		wallets.each_with_index do |wallet,i|
			j=i+coinoffset
			x_cord= Random.new.rand(1..100)
			y_cord=Random.new.rand(1..100)
			json_nodes[j]={"id"=> "n#{j}", "label" => wallet,"x"=>x_cord, "y"=>y_cord, "size"=> 3}
		end

		json_links=[]
		edgecounter=0
		tree.each do |source, targetset|
			treesource_cord=nodes_keymap.index(source)
			targetset.each do |target|
				treetarget_cord=nodes_keymap.index(target)
				json_links[edgecounter]={"id"=> "e#{edgecounter}", "source"=> "n#{treesource_cord}", "target"=> "n#{treetarget_cord}"}
				edgecounter+=1
			end
		end
		master_output={"nodes"=>json_nodes, "edges"=>json_links}

		File.open("#{json_filename}.json","w") do |f|
			f.write(JSON.pretty_generate(master_output))
		end

	end

end

start=Chaininfo.new(myapikey, myapisecret, myaddress, numberoftxs,verbosetx)
start.alltxs(myaddress,depth)
startwallet , node_tree = start.totalmap

outputfile = Outputter.new
if type=="gexf"
	outputfile.givemejson(filename, startwallet,node_tree, myaddress)
elsif type=="json"
	outputfile.givemegexf(filename, startwallet,node_tree, myaddress)
end
