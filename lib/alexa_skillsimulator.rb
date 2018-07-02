#!/usr/bin/env ruby

# file: alexa_skillsimulator.rb

require 'time'
require 'rest-client'
require 'console_cmdr'
require 'securerandom'


class AlexaShell < ConsoleCmdr

  def initialize(manifest, model, debug: false)
    @alexa = AlexaSkillSimulator.new(manifest, model, debug: debug)
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
    
    if command =~ /^what can i say/ then
      return "you can say the following: \n\n" \
          + "open #{@alexa.invocation}\n" + @alexa.utterances.keys.join("\n")
    end
    
    return (@running=false; '' ) if command.downcase =~ /^bye|quit|stop|exit$/
    
    return false unless command =~ /^open|tell|ask$/
    
    response = @alexa.ask command.downcase
    "Alexa says: " + response

    
  end

  def on_keypress(key)    
    @running = false if key == :ctrl_c
    super(key)
  end

end


class AlexaSkillSimulator

  attr_reader :invocation, :utterances

  def initialize(manifest, model, debug: false)

    @debug = debug

    @locale = manifest['manifest']['publishingInformation']['locales']\
        .keys.first
    puts '@locale: ' + @locale.inspect if @debug
    
    @invocation = model['interactionModel']['languageModel']['invocationName']
    
    # get the utterances
 
    @utterances = model['interactionModel']['languageModel']\
                                        ['intents'].inject({}) do |r, intent|
      intent['samples'].each {|x| r[x] = intent['name']}
      r
    end

    puts '  debugger::@utterances: ' + @utterances.inspect if @debug

    # get the endpoint
    @endpoint = manifest['manifest']['apis']['custom']['endpoint']['uri']

    puts '  debugger: @endpoint: ' + @endpoint.inspect if @debug
    
  end
  
  def ask(s)
    
    puts
    puts '  debugger: s: ' + s.inspect if @debug
    
    invocation = @invocation.gsub(/ /,'\s')
    
    regex = %r{

      (?<ask>(?<action>tell|ask)\s#{invocation}\s(?<request>.*)){0}
      (?<open>(?<action>open)\s#{invocation}){0}
      \g<ask>|\g<open>
    }x
        
    r2 = s.match(regex)
    
    puts '  debugger: r2: ' + r2.inspect if @debug
    puts      
                
    response = if r2 then
    
      case r2[:action]
      
      when 'open'

          respond()
        
      else
        
        r = @utterances[r2[:request]]
        puts '  debugger: r: ' + r.inspect if @debug
        puts

        if r then

          puts '  debugger: your intent is to ' + r if @debug

          respond(r)      
          
        else
          "I'm sorry I didn't understand what you said"
        end        
        
      end
              
    else
      
      "hmmm, I don't know that one."
      
    end
    
   response
        
  end


  private

  def post(url, h)

    r = RestClient.post(url, h.to_json, 
                       headers={content_type: :json, accept: :json})
    JSON.parse r.body, symbolize_names: true

  end

  def respond(intent=nil)

    h = {"version"=>"1.0",
     "session"=>
      {"new"=>true,
       "sessionId"=>"amzn1.echo-api.session.1",
       "application"=>
        {"applicationId"=>"amzn1.ask.skill.0"},
       "user"=>
        {"userId"=>
          "amzn1.ask.account.I"}},
     "context"=>
      {"System"=>
        {"application"=>
          {"applicationId"=>
            "amzn1.ask.skill.0"},
         "user"=>
          {"userId"=>
            "amzn1.ask.account.I"},
         "device"=>
          {"deviceId"=>
            "amzn1.ask.device.A",
           "supportedInterfaces"=>{}},
         "apiEndpoint"=>"https://api.eu.amazonalexa.com",
         "apiAccessToken"=>
          "A"}},
     "request"=> {}
    }
    
    h['request'] = if intent then
    {
      "type"=>"IntentRequest",
      "requestId"=>"amzn1.echo-api.request.0",
      "timestamp"=>Time.now.utc.iso8601,
      "locale"=>@locale,
      "intent"=>{"name"=>intent, "confirmationStatus"=>"NONE"},
      "dialogState"=>"STARTED"
    }
    else
      {
        "type"=>"LaunchRequest",
        "requestId"=>"amzn1.echo-api.request.a",
        "timestamp"=> Time.now.utc.iso8601,
        "locale"=>@locale,
        "shouldLinkResultBeReturned"=>false
      }      
    end
    
    r = post @endpoint, h
    puts '  degbugger: r: ' + r.inspect if @debug

    r[:response][:outputSpeech][:text]
  end

end
