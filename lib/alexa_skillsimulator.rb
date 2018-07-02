#!/usr/bin/env ruby

# file: alexa_skillsimulator.rb

require 'time'
require 'rest-client'
require 'securerandom'


class AlexaSkillSimulator


  def initialize(manifest, model, debug: false)

    @debug = debug

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

  def start()

    puts
    puts 'Starting ... (to exit press CTRL-C)'

    while true do

      puts
      puts 'Alexa is ready'
      puts
      print '> '
      s = gets.downcase.chomp
      puts
      puts '  debugger: s: ' + s.inspect if @debug

      r = @utterances[s]
      puts '  debugger: r: ' + r.inspect if @debug
      puts

      if r then

        puts '  debugger: your intent is to ' + r if @debug

        response = respond()
        puts "Alexa says: " + response
        
      else
        puts "Alexa says: I'm sorry I didn't understand what you said"
      end

    end

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
     "request"=>
      {"type"=>"LaunchRequest",
       "requestId"=>"amzn1.echo-api.request.a",
       "timestamp"=> Time.now.utc.iso8601,
       "locale"=>"en-US",
       "shouldLinkResultBeReturned"=>false}}

    r = post @endpoint, h
    puts '  degbugger: r: ' + r.inspect if @debug
    puts

    r[:response][:outputSpeech][:text]
  end

end
