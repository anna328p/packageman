require 'socket'
require 'date'

s = TCPServer.new 8080

serve_dir = ARGV[1] || Dir.pwd
index = ['index.html', 'index.htm']

class File
	def mime_type
		`file --brief --mime-type #{self.path}`.strip
	end
end

notfound = '<html><head><title>404 Not Found</title></head><body><h1>404 Not Found</h1></body></html>'

loop do
	client = s.accept
	headers = Array.new
	while (str = client.gets.chomp) != ''
		headers << str
	end
	p headers
	if headers[0] =~ /HTTP\/.\..$/
		if headers[0].split[0] == 'GET' || (head = headers[0].split[0] == 'HEAD')
			file = serve_dir + headers[0].split[1..-2].join(' ')
			size = 0
			file_found = false
			if File.directory? file
				index.each do |i|
					filename = "#{file}#{i}"
					if File.exist? filename
						file = filename
						file_found = true
						break
					end
				end
			elsif !File.directory? file
				if (size = File.size? file)
					file_found = true
				end
			else
				file_found = false
			end

			if file_found
				f = File.open file, 'r'
				client.puts "HTTP/1.0 200 OK"
				client.puts "Date: #{Date.new.strftime "%a, %d %b %Y %H:%M:%S %Z"}"
				client.puts "Server: dkudriavtsev's SimpleHTTPServer v0.1"
				client.puts "Content-Type: #{f.mime_type}"
				client.puts "Content-Length: #{size}"
				unless head
					client.puts
					client.puts f.read
				end
				f.close
			else
				client.puts "HTTP/1.0 404 Not Found"
				client.puts "Date: #{Date.new.strftime "%a, %d %b %Y %H:%M:%S %Z"}"
				client.puts "Server: dkudriavtsev's SimpleHTTPServer v0.1"
				unless head
					client.puts "Content-Type: text/html"
					client.puts "Content-Length: #{notfound.size}"
					client.puts
					client.puts notfound
				end
			end
		else
			client.puts "HTTP/1.0 500 Internal Server Error"
		end
		puts headers.inspect
	end
	client.close
end

