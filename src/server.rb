#!/usr/bin/ruby
require_relative "./server_utils"

# File: server.rb
#
# Functions: main exec
#
# Date: October 4, 2015
#
# Deisgner: Manuel Gonzales
# Programmer: Manuel Gonzales
#
# Notes:
# This script will start the server to deal with multiple clients at a time
# and will communicate with them.

case ARGV.length
	when 0
		port = SERVER_TCP_PORT

	when 1
		port = ARGV.shift

	else
		puts 'Usage: executable_name [port]'
end

#start server
server = TCPServer.new('', port)
server_running = true;

current_path = Dir.pwd

#create folder
if(!File.exist?("#{current_path}/files"))
	Dir.mkdir("#{current_path}/files")
end

#thread used to stop the server manually, it will take 10 seconds in order to have
#time to notify clients
Thread.new{

		while(escape = gets.chomp)

			if (escape .casecmp "stop") == 0

				server.close
				server_running = false				
				puts "Server Stopping..."
				sleep(10)
				puts "Server Stopped"
				exit!

			else
				puts "Unknown Command"
		end	
	end
} 

while(true)

	Thread.start(server.accept) do |client|

		stop_flag = false
		client_port = client.gets.chomp.to_i
		puts "Client #{client.peeraddr[3]} Connected"


		while(input = client.gets.chomp)

			#when server is stopped notify the client
			if(!server_running)

				client.puts "\nServer Failure"
				client.puts "exiting"
				client.close
				break

			end

			input_strings = input.split(" ")

			if input_strings.size < 1

			else if input_strings.size > 20

				client.puts "\nToo many arguments"
				client.puts "Usage: EXIT, LIST, SEND filename, GET filename"

			else

				first_input = input_strings[0]
				input.slice! "#{first_input} "				

				#type of message received
				case first_input.downcase
				when "exit"

					exit(client, stop_flag)
					
				when "list"				
					
					list(client, current_path)

				when "send"
					
					send_file(client, current_path, input, client_port)

				when "get"

					get_file(client, current_path, input, client_port)
					
				else
					client.puts "\nUnknown Command"
					client.puts "Usage: EXIT, LIST, SEND filename, GET filename"
				end
			end

			if(stop_flag)
				break
			end
				
			end
		end
	end
end 


