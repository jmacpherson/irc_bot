require 'socket'
require 'cinch'

class VortexBot
  PARTINGS = %w(bye goodbye cya seeya quit)
  PASSWORD = "AbrAhAdAbrA"

  def initialize(server, port, channel)
    @channel = channel
    @socket= TCPSocket.open(server, port)
    say "NICK ProjectBot"
    say "USER ProjectBot 0 * ProjectBot"
    say "JOIN #{@channel}"
    run!
  end

  def say(msg)
    puts msg
    @socket.puts msg
  end

  def chat(msg)
    say "PRIVMSG #{@channel} :#{msg}"
  end

  def run!
    until @socket.eof? do
      respond_to! @socket.gets
    end
  end

  def respond_to!(msg)
    puts msg
    new_user?(msg) if msg.downcase.include? "join #{@channel}"
    quit?(msg)
    ping?(msg)
    time?(msg)
  end

  #response methods

  def quit?(msg)
    PARTINGS.each do |p|
      @socket.puts "QUIT" if msg.include? p
      @socket.close if msg.include? p
    end
  end

  def ping?(msg)
    ping = msg.include? "PING"
    return unless msg.strip().end_with? "PRIVMSG #{@channel} :!vortexbot" or ping
    @socket.puts msg.gsub("PING", "PONG") if ping
  end

  def time?(msg)
    chat(Time.now) if msg.include? "time"
  end

  # private

  def new_user?(msg)
    user = get_user_name(msg)
    list = File.open("user_list.txt", "r")
    data = list.read.split("\n")
    puts data.include?(user)


    # list = user_list.read
    # user_list.close
    # chat list.class
    # chat list

  end

  def get_user_name(msg)
    msg =~ /[:](.+)[!]/
    user_joined = $~.to_s
    user_joined = user_joined.split('')
    user_joined.shift
    user_joined.pop
    user_joined = user_joined.join('')
  end

end



VortexBot.new("chat.freenode.net", 6667, "#project89")
