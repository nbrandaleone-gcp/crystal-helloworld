require "http/server"
require "option_parser"

# Cloud Run has a runtime contract.
# https://cloud.google.com/run/docs/reference/container-contract

# The container instance then receives a SIGTERM signal indicating 
# the start of a 10 second period before being shut down 
# (with a SIGKILL signal).
# If the container instance does not catch the SIGTERM signal, it is 
# immediately shut down.

# Handle Ctrl+C (SIGTERM) and kill (SIGKILL) signal.
Signal::INT.trap  { puts "Caught Ctrl+C..."; exit }
Signal::TERM.trap { puts "Caught kill..."; exit }

# Listen on default socket 
bind = "0.0.0.0"

# Grab port from environmental variable. All keys/values are strings.
# Can be overriden via --port flag
ENV["PORT"] ||= "8080"
port = ENV["PORT"].to_i

OptionParser.parse do |parser|
  parser.on("-p PORT", "--port PORT", "define port (8080) for server") do |opt|
    port = opt.to_i
  end
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

server = HTTP::Server.new do |context|
  context.response.content_type = "text/plain"
  context.response << "Hello world, got #{context.request.path}\n"
#  context.response.print "Hello world! The time is #{Time.local}\n"
end

address = server.bind_tcp(bind, port)
puts "Listening on http://#{address}"
server.listen
