require 'rubygems'
require 'plivohelper'

#URL of the Plivo REST service
REST_API_URL = 'http://192.168.1.100:8088'

# Sid and AuthToken
SID = 'tremendoelplivo'
AUTH_TOKEN = 'tremendoelplivo'

#Define Channel Variable - http://wiki.freeswitch.org/wiki/Channel_Variables
extra_dial_string = "bridge_early_media=true,hangup_after_bridge=true"

# Create a REST object
plivo = Plivo::Rest.new(REST_API_URL, SID, AUTH_TOKEN)

# Initiate a new outbound call to user/1000 using a HTTP POST
call_params = {
    'From'=> 'peter_gibbons', # Caller Id
    'To' => 'luis101', # User Number to Call
    'Gateways' => "user/", # Gateway string to try dialing our separated by comma. First in list will be tried first
    'GatewayCodecs' => "'PCMA,PCMU'", # Codec string as needed by FS for each gateway separated by comma
    'GatewayTimeouts' => "60",      # Seconds to timeout in string for each gateway separated by comma
    'GatewayRetries' => "1", # Retry String for Gateways separated by comma, on how many times each gateway should be retried
    'ExtraDialString' => extra_dial_string,
    'AnswerUrl' => "http://192.168.1.2:3000/answer/",
    'HangupUrl' => "http://192.168.1.2:3000/hangup/",
}


request_uuid = ""

#Perform the Call on the Rest API
begin
    result = plivo.call(call_params).body
rescue Exception=>e
    print e
end

print result

if false
    sleep(10)
    # Hangup a call using a HTTP POST
    hangup_call_params = {
        'RequestUUID' => request_uuid.strip(), # Request UUID to hangup call
    }

    #Perform the Call on the Rest API
    begin
        print plivo.hangup_call(hangup_call_params)
    rescue Exception=>e
        print e
    end
end
