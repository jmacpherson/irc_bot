require 'socket'
require 'cinch'

class ProjectBot
  PARTINGS = %w(bye goodbye cya seeya quit)
  PASSWORD = "pass"

  def initialize(server, port, channel)
    @channel = channel
    @socket= TCPSocket.open(server, port)
    @user = "ProjectBot"
    say "NICK #{@user}"
    say "USER ProjectBot 0 * ProjectBot"
    say "JOIN #{@channel}"
    run!
  end

  def run!
    until @socket.eof? do
      msg = stream
      puts msg
      quit?(msg)
      ping?(msg)
      time?(msg)
      user_join(msg) if msg.downcase.include? "join #{@channel}"
    end
  end

  def stream
    @socket.gets
  end

  def public_command_console(msg)
    # This method will execute various internal commands we may want the bot to do, 
  end

  def private_command_console(msg)
    # This method will execute various private commands like kick or message a user..
  end

  def options_settings(msg)
    # this method will allow us to turn on an off various auto-settings of the bot, such as turning password check on and off.
  end

# MESSAGE METHODS

  # Talk directly to the IRC server
  def say(msg)
    puts msg
    @socket.puts msg
  end

  # Send a message to a particular room
  def chat(msg)
    say "PRIVMSG #{@channel} :#{msg}"
  end

  # Send a private message to a particular server
  def private_message(user, msg)
    say("privmsg #{user} :#{msg}")
  end

# REPOND METHODS

  # Respond to a ping
  def ping?(msg)
    ping = msg.include? "PING"
    return unless msg.strip().end_with? "PRIVMSG #{@channel} :!ProjectBot" or ping
    @socket.puts msg.gsub("PING", "PONG") if ping
  end

  # Give the time
  def time?(msg)
    chat(Time.now) if msg.include? "time"
  end

# AUTOMATIC METHODS
 
  def user_join(msg)
    user = get_user_name(msg)
    data = get_file("user_list.txt") 
    unless data.include?(user)
      kick(user)
    else
      password_check(user) unless user == @user
    end
  end

  def password_check(user)
    private_message(user, "Please PM the password. 60 seconds and counting...")
    counter = 0
      until counter == 10
        sleep 1
        msg = stream
        say("1")
          if msg.include?(user) && msg.include?(PASSWORD)
            private_message(user, "Password validated.  Please enjoy your stay.")
            make_admin(user)
            return
          else
             counter +=1
          end
    end
    kick(user)
  end

  def make_admin(user)
    data = admin_list
    say("mode #{@channel} +o #{user}") if data.include?(user)
  end

  def admin?(user)
    admin_list.include?(user)
  end

# COMMAND METHODS

  def kick(user)
    say "kick #{@channel} #{user} :And stay out!"
  end

  def quit?(msg)
    # REDEFINE ME
    # this method needs to accept a quit command only from an admin
    # PARTINGS.each do |p|
    #   @socket.puts "QUIT" if msg.include? p
    #   @socket.close if msg.include? p
    # end
  end

# GET METHODS

  def get_file(file)
    list = File.open(file, "r")
    data = list.read.split("\n")
    list.close
    data
  end

  def admin_list
    get_file("admin_list.txt")
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


ProjectBot.new("chat.freenode.net", 6667, "#project89")

# future functions

# return user list
# add new user
# add new admin

