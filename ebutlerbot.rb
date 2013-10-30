require 'socket'
require 'cinch'

class EButlerBot
  PARTINGS = %w(bye goodbye cya seeya quit)
  PASSWORD = "AbrAhAdAbrA"

  def initialize(server, port, channel)
    @channel = channel
    @socket= TCPSocket.open(server, port)
    @nick = "JarvisEButlerBot"
    say "NICK #{@nick}"
    say "USER eButlerBot 0 * eButlerBot"
    say "JOIN #{@channel}"
    chat "How may I be of service to you today, young masters?"
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

  def quit?(msg)
    PARTINGS.each do |p|
      say "QUIT" if msg.include? p
      @socket.close if msg.include? p
    end
  end

  def ping?(msg)
    ping = msg.downcase.include? "ping"
    return unless ping
    msg =~ /[:].+/
    msg = $~.to_s
    say(msg.downcase.gsub("ping", "PONG")) if ping
  end

  def time?(msg)
    chat(Time.now) if msg.include? "time"
  end

  def new_user?(msg)
    msg =~ /^[:](\w+)[!]/
    user_joined = $~.to_s
    user_joined = user_joined.split('')
    user_joined.shift
    user_joined.pop
    user_joined = user_joined.join('')
    chat "Introducing the distinguished, #{user_joined}." unless user_joined == @nick
  end
end

EButlerBot.new("chat.freenode.net", 6667, "#project89")