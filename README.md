# Introducing the Alexa_skillsimulator gem


    require 'alexa_modelbuilder'
    require 'alexa_skillsimulator'


    s =<<LINES
    name: American cities quiz game
    invocation: quiz game

    PlayGame

      start the game
      start the quiz
      play the quiz
      start a quiz  

    Answer
      is the city {city}

      slots:
        City: AMAZON.US_CITY


    AMAZON.StopIntent

    types: 
      US_STATE_ABBR: AK, AL, AZ

    endpoint: https://yourlocalwebserver.com/quizgame
    LINES

    amd = AlexaModelBuilder.new(s)

    ask = AlexaSkillSimulator.new amd.to_manifest, amd.to_model, debug: true
    ask.start

The above example simulates interacting with an Alexa Skill using the Alexa_skillsimulator gem. It uses the supplied manifest and interaction model to respond to user requests, including posting and fetching the response from the endpoint (e.g. local web server).

## Resources

* alexa_skillsimulator https://rubygems.org/gems/alexa_skillsimulator

alexa skill simulator skills test assistant bot
