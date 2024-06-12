# @summary The main class to set up webhook
# @example
#   include webhook
# @param command the command to run when receiving a message
# @param response_code the response code to return on success
# @param ip the ip address to bind to
# @param port the ip address to bind to
# @param include_command_output
#   boolean whether webhook should wait for the command to finish and return
#   the raw output as a response to the hook initiator
# @param include_command_output_error
#   boolean whether webhook should include command stdout & stderror as a
#   response in failed executions
# @param parse_as_json specifies the list of arguments that contain JSON strings
# @param debug enable debug
# @param verbose enable verbose
# @param nopanic enable nopanic
# @param working_directory the working directory to use
# @param http_methods a list of allowed HTTP methods, such as POST and GET
# @param response_headers A list of headers to add to the response
# @param arguments mappings of payload arguments to command arguments
# @param environment
#   mappings of payload environments to set when calling the command
# @param headers An array of headers to add to the response
# @param trigger_rule A hash of trigger rules
# @param x_request_id use X-Request-Id header, if present, as request ID
# @param x_request_id_limit truncate X-Request-Id header to limit
# @param incoming_content_type sets the Content-Type of the incoming HTTP request
# @param response_message the message to send on a successful response
# @param cert the ssl cert to use
# @param key the ssl key to use
# @param logfile the logfile to use, infers verbose
# @param gid set group ID after opening listening port
# @param uid set group ID after opening listening port
class webhook (
  Stdlib::Unixpath            $command,
  Stdlib::HttpStatus          $response_code                = 200,
  Stdlib::IP::Address         $ip                           = '0.0.0.0',
  Stdlib::Port                $port                         = 9000,
  Boolean                     $include_command_output       = false,
  Boolean                     $include_command_output_error = false,
  Boolean                     $parse_as_json                = false,
  Boolean                     $debug                        = false,
  Boolean                     $nopanic                      = true,
  Boolean                     $verbose                      = false,
  Array[String]               $http_methods                 = [],
  Array[Webhook::Header]      $response_headers             = [],
  Array[Webhook::Arguments]   $arguments                    = [],
  Array[Webhook::Env]         $environment                  = [],
  Array[String]               $headers                      = [],
  Hash                        $trigger_rule                 = {},
  Boolean                     $x_request_id                 = false,
  Optional[Integer]           $x_request_id_limit           = undef,
  Optional[Stdlib::Unixpath]  $working_directory            = undef,
  Optional[String[1]]         $incoming_content_type        = undef,
  Optional[String[1]]         $response_message             = undef,
  Optional[Stdlib::Unixpath]  $cert                         = undef,
  Optional[Stdlib::Unixpath]  $key                          = undef,
  Optional[Stdlib::Unixpath]  $logfile                      = undef,
  Optional[Integer[1]]        $gid                          = undef,
  Optional[Integer[1]]        $uid                          = undef,
) {
  ensure_packages(['webhook'])
  $secure = $cert =~ Stdlib::Unixpath and $key =~ Stdlib::Unixpath
  $config_path = '/etc/webhook.conf'
  $config = {
    'id'                                          => 'webhook',
    'execute-command'                             => $command,
    'command-working-directory'                   => $working_directory,
    'success-http-response-code'                  => $response_code,
    'incoming-payload-content-type'               => $incoming_content_type,
    'http-methods'                                => $http_methods,
    'include-command-output-in-response'          => $include_command_output,
    'include-command-output-in-response-on-error' => $include_command_output_error,
    'parse-parameters-as-json'                    => $parse_as_json,
    'response-message'                            => $response_message,
    'response-headers'                            => $response_headers,
    'pass-arguments-to-command'                   => $arguments,
    'pass-environment-to-command'                 => $environment,
    'trigger-rule'                                => $trigger_rule,
  }.filter |$key, $value| { $value =~ Boolean or $value }
  $command_arguments = {
    'cert'               => $cert,
    'debug'              => $debug,
    'header'             => $headers,
    'hotreload'          => true,
    'ip'                 => $ip,
    'key'                => $key,
    # not supported in focal
    # 'logfile'            => $logfile,
    'nopanic'            => $nopanic,
    'hooks'              => $config_path,
    'port'               => $port,
    'secure'             => $secure,
    'setgid'             => $gid,
    'setuid'             => $uid,
    'verbose'            => $verbose,
    'x-request-id'       => $x_request_id,
    'x-request-id-limit' => $x_request_id_limit,
  }.filter |$key, $value| { $value =~ Boolean or $value }.webhook::argparse

  file { $config_path:
    ensure  => 'file',
    content => $config.to_json(),
  }
  $override_content = @("CONTENT")
    [Service]
    ExecStart=
    ExecStart=/usr/bin/webhook ${command_arguments}
    | CONTENT
  systemd::dropin_file { 'puppet.conf':
    unit    => 'webhook.service',
    content => $override_content,
    notify  => Service['webhook']
  }
  service { 'webhook':
    ensure => 'running',
    enable => true,
  }
}
