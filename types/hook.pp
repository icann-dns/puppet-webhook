# @summary tyoe to define a webhook
# @param command the command to run when receiving a message
# @param response_code the response code to return on success
# @param include_command_output
#   boolean whether webhook should wait for the command to finish and return
#   the raw output as a response to the hook initiator
# @param include_command_output_error
#   boolean whether webhook should include command stdout & stderror as a
#   response in failed executions
# @param parse_as_json specifies the list of arguments that contain JSON strings
# @param working_directory the working directory to use
# @param http_methods a list of allowed HTTP methods, such as POST and GET
# @param response_headers A list of headers to add to the response
# @param arguments mappings of payload arguments to command arguments
# @param environment mappings of payload environments to set when calling the command
# @param trigger_rule A hash of trigger rules
# @param incoming_content_type sets the Content-Type of the incoming HTTP request
# @param response_message the message to send on a successful response
type Webhook::Hook = Struct[
  {
    'command' => String[1],
    Optional['working_directory'] => Stdlib::Unixpath,
    Optional['response_code'] => Integer[1],
    Optional['incoming_content_type'] => String[1],
    Optional['http_methods'] => Array[String],
    Optional['include_command_output_in_response'] => Boolean,
    Optional['include_command_output_in_response_on_error'] => Boolean,
    Optional['parse_parameters_as_json'] => Array[String[1]],
    Optional['response_message'] => String[1],
    Optional['response_headers'] => Array[Webhook::Header],
    Optional['pass_arguments_to_command'] => Array[Webhook::Arguments],
    Optional['pass_environment_to_command'] => Array[Webhook::Env],
    Optional['trigger_rule'] => Hash,
  }
]
