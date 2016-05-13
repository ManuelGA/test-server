#!/usr/bin/ruby
require_relative "./client_utils"

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
# This script will connect to the server and it will also serve as a 'server' to receive
# files.

#arguments to connect
case ARGV.length
	when 1

		address = ARGV.shift
		port_serv = SERVER_TCP_PORT
		port_clt = CLT_TCP_PORT

	when 2

		address = ARGV.shift
		port_serv = ARGV.shift
		port_clt = CLT_TCP_PORT

		if is_number?(port_serv)
		else
			puts 'Invalid Server Port Number'
			puts 'Usage: executable_name [server_address] [port]'
			exit
		end

	when 3

		address = ARGV.shift
		port_serv = ARGV.shift

		if is_number?(port_serv)
		else
			puts 'Invalid Server Port Number'
			puts 'Usage: executable_name [server_address] [port]'
			exit
		end

		port_clt = ARGV.shift
		if is_number?(port_clt)
		else
			puts 'Invalid Client Port Number'
			puts 'Usage: executable_name [server_address] [port]'
			exit
		end

	else
		puts 'Usage: executable_name [server_address] [port]'
		exit
end



client = TCPSocket.new( address, port_serv )
client_serv = TCPServer.new('', port_clt)

message = ""
#used for either sending or receiving
getflag = true

port_str = port_clt.to_s
client.puts "#{port_str}"

#listne to messages from terminal
Thread.new{

	while(message = gets.chomp)
			
		client.puts message


	end
}

Thread.new{
		
		while(response = client.gets.chomp)

			#type of response received from the server
			case response

				when "exiting"

	    			puts 'Disconnected'
	    			client.close
	    			exit

	    		when "sending"
	    			
	    			getflag = true

	    		when "receiving"

	    			getflag = false

	    		else

	    			puts response	    			
    		end
		end
}

#loop to serve as server to receive/send files
while(true)
	Thread.start(client_serv.accept) do |server|

		if(getflag)

			get_file(server)

		else

			send_file(server)
		end
	end
end


