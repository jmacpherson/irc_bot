require 'socket'
require 'cinch'

class VortexBot
  PARTINGS = %w(bye goodbye cya seeya quit)
  PASSWORD = "AbrAhAdAbrA"

  def initialize(server=nil)
    @nick = "VortexBot"
    @channel = "#project89"
    @server = server
  end

  def run!
    openSocket! if @server.nil?

    @server.puts "USER VortexBot 0 * Testing"
    @server.puts "NICK #{@nick}"
    @server.puts "JOIN #{@channel}"
    @server.puts "PRIVMSG #{@channel} :Hi friends!"

    until @server.eof? do
      respond_to! @server.gets
    end
  end

  def respond_to!(msg)
    puts msg
    new_user?(msg) if msg.downcase.include? "join #{@channel}"
    quit?(msg)
    ping?(msg)
    time?(msg)
  end

  def quit?(msg)
    PARTINGS.each do |p|
      @server.puts "QUIT" if msg.include? p
      @server.close if msg.include? p
    end
  end

  def ping?(msg)
    ping = msg.include? "PING"
    return unless msg.strip().end_with? "PRIVMSG #{@channel} :!vortexbot" or ping
    @server.puts msg.gsub("PING", "PONG") if ping
  end

  def time?(msg)
    message(Time.now) if msg.include? "time"
  end

  def new_user?(msg)
    msg =~ /[:](.+)[!]/
    user_joined = $~
    user_joined = user_joined.split('')
    user_joined.shift
    user_joined.pop
    user_joined = user_joined.join('')
    message "#{user_joined}"
  end

  def message(content)
    @server.puts "PRIVMSG #{@channel} :#{content}"
  end

  def openSocket!
    host = "chat.freenode.net"
    port = "6667"
    @server = TCPSocket.open(host, port)
  end
end

VortexBot.new.run!