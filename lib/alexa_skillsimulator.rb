#!/usr/bin/env ruby

# file: alexa_skillsimulator.rb

require 'console_cmdr'
require 'securerandom'
require 'alexa_utteranceresponder'


class AlexaShell < ConsoleCmdr

  def initialize(modelstxt=[], debug: false, userid: nil, deviceid: nil)
    
    @alexa = AlexaSkillSimulator.new(modelstxt, debug: debug, 
                                     userid: userid, deviceid: deviceid)
    super(debug: debug)
    
  end
  
  def start()   
    super()
  end
  
  def display_output(s='')
    
    print s + "\n\n => Alexa is ready\n\n> "
    
  end

  protected
  
  def clear_cli()
  end
  
  def cli_banner()
    puts
    puts 'Starting ... (to exit press CTRL-C)'     
    puts
    puts 'Alexa is ready'
    puts
    print '> '      
  end

  def on_enter(raw_command)
    
    command = raw_command.downcase
    
    puts 'on_enter: ' + command.inspect if @debug
    
    case command

    when /^open|tell|ask$/
      response = @alexa.ask command
      "Alexa says: " + response
      
    when /^what can i say/
      return "you can say the following: \n\n" \
          + "open #{@alexa.invocation}\n" + @alexa.utterances.keys.join("\n")
    
    when /^bye|quit|stop|exit$/
      return (@running=false; '' )
    
    else
      return @alexa.ask command
    end
    
  end

  def on_keypress(key)    
    @running = false if key == :ctrl_c
    super(key)
  end

end


class AlexaSkillSimulator

  attr_reader :invocation
  attr_accessor :deviceid

  def initialize(modelstxt=[], debug: false, userid: nil, deviceid: nil)

    @debug, @deviceid = debug, deviceid
    @aur = AlexaUtteranceResponder.new(modelstxt, userid: userid, deviceid: deviceid, debug: true)
    
  end
  
  def ask(s, deviceid: @deviceid, &blk)
    
    puts
    puts '  debugger: s: ' + s.inspect if @debug

    @aur.ask(s)

  end

end
