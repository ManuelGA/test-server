#!/usr/bin/ruby
require 'socket'

# File: client_utils.rb
#
# Functions: is_number?(string)
#			 get_file(server)
#            send_file(server)
#
# Date: October 4, 2015
#
# Deisgner: Manuel Gonzales
# Programmer: Manuel Gonzales
#
# Notes:
# Helper methods for the client for sending and receiving files.

SERVER_TCP_PORT = 7005
CLT_TCP_PORT = 7007

#Checks if its a valid number, used for port checking
def is_number?(string)

  true if Integer(string) rescue false

end

#Gets a file from the srver and saves it into the current directory.
def get_file(server)

	filename = server.gets.chomp

	if(File.exist?("#{filename}"))

		puts "\nFile already exists"
		server.puts "false"		

	else

		server.puts "true"

		received_file = File.open(filename, "wb")
		filecontent = server.read
		received_file.print filecontent
		received_file.close

		puts "File #{filename} Received"
	end
end

#Sends a file from the current directory to the server
def send_file(server)

	current_path = Dir.pwd
	filename = server.gets.chomp

	if(!File.exist?("#{current_path}/#{filename}"))

		puts "\nFile does not exists, check again"
		server.puts "false"

	else

		server.puts "true"

		file_sending = File.open("#{current_path}/#{filename}", "rb")
		filecontent = file_sending.read 
		server.puts(filecontent)	    				
		server.close
		file_sending.close

		puts "File #{filename} Sent"
	end

end