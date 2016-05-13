#!/usr/bin/ruby
require 'socket'

# File: server_utils.rb
#
# Functions: exit(client, stop_flag)
#			 list(client, current_path)
#            send_file(client, current_path, input, client_port)
#            get_file(client, current_path, input, client_port)
#
# Date: October 4, 2015
#
# Deisgner: Manuel Gonzales
# Programmer: Manuel Gonzales
#
# Notes:
# Helper methods for the server for command puporses and sending and receiving files.

SERVER_TCP_PORT = 7005

#used when a client disconnects, used to stop the thrread and close the socket
def exit(client, stop_flag)

	puts "Client #{client.peeraddr[3]} Disconnected"
	client.puts "\nThanks for your visit"
	client.puts "exiting"
	client.close
	stop_flag = true

end

#used to send the list to the clients when requested
def list(client, current_path)

	files = Dir.glob("#{current_path}/files/*")
	client.puts "\nList of Files:"
	files.each{ |file|
	file.slice! "#{current_path}/files/"}
	client.puts files

end

#Gets a file from the client and saves it in the 'files' folder in the current directory.
#(send) flag is used by the client ergo the name
def send_file(client, current_path, input, client_port)

	if(File.exist?("#{current_path}/files/#{input}"))
			client.puts "\nFile already exists on server"
	else
		client.puts "receiving"

		client_serv = TCPSocket.new("#{client.peeraddr[3]}", client_port)
		client_serv.puts "#{input}"

		file_bool = client_serv.gets.chomp
		if(file_bool == "false")

		else
			received_file = File.open("#{current_path}/files/#{input}", "wb")

			filecontent = client_serv.read 
			received_file.print filecontent	    			
			received_file.close
			client_serv.close

			puts "File #{input} Received"
		end
	end
end

#Sends a file from the 'files' in the current directory to the client.
#(get) flag is used by the client ergo the name
def get_file(client, current_path, input, client_port)

	if(!File.exist?("#{current_path}/files/#{input}"))
		client.puts "\nFile not available"
	else
		client.puts "sending"

		client_serv = TCPSocket.new("#{client.peeraddr[3]}", client_port)
		client_serv.puts "#{input}"

		file_boolean = client_serv.gets.chomp
		if(file_boolean == "false")

		else
			file_sending = File.open("#{current_path}/files/#{input}", "rb")

			filecontent = file_sending.read
			client_serv.puts(filecontent)	    				
			client_serv.close
			file_sending.close

			puts "File #{input} Sent"
		end
	end					
end