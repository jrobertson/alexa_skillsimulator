#!/usr/bin/env ruby

# file: alexa_skillsimulator.rb

require 'askio'
require 'console_cmdr'
require 'securerandom'


class AlexaShell < ConsoleCmdr

  def initialize(manifest, model, debug: false, userid: nil, deviceid: nil)
    
    @alexa = AlexaSkillSimulator.new(manifest, model, debug: debug, 
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
      return false
    end
    
  end

  def on_keypress(key)    
    @running = false if key == :ctrl_c
    super(key)
  end

end


class AlexaSkillSimulator

  attr_reader :invocation

  def initialize(manifest, model, debug: false, userid: nil, deviceid: nil)

    @manifest, @model = manifest, model
    @debug, @userid, @deviceid = debug, userid, deviceid
    
  end
  
  def ask(s)
    
    puts
    puts '  debugger: s: ' + s.inspect if @debug

    aio = AskIO.new(@manifest, @model, debug: @debug, userid: @userid, 
                    deviceid: @deviceid)
    
    invocation = aio.invocation.gsub(/ /,'\s')
    
    regex = %r{

      (?<ask>(?<action>tell|ask)\s#{invocation}\s(?<request>.*)){0}
      (?<open>(?<action>open)\s#{invocation}){0}
      \g<ask>|\g<open>
    }x
        
    r2 = s.downcase.gsub(/,/,'').match(regex)
    
    puts '  debugger: r2: ' + r2.inspect if @debug
    puts      
      
    return "hmmm, I don't know that one." unless r2        
    return respond() if r2[:action] == 'open'
        
    r = aio.ask r2[:request]
    
    r ? r : "I'm sorry I didn't understand what you said"

  end


end
