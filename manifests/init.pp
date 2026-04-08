# @summary The main class to set up webhook
# @example
#   include webhook
# @param ip the ip address to bind to
# @param port the ip address to bind to
# @param verbose enable verbose
# @param nopanic enable nopanic
# @param headers An array of headers to add to the response
# @param x_request_id use X-Request-Id header, if present, as request ID
# @param x_request_id_limit truncate X-Request-Id header to limit
# @param cert the ssl cert to use
# @param key the ssl key to use
# @param logfile the logfile to use, infers verbose
# @param urlprefix url prefix to use for served hook
# @param debug enable debug
# @param gid set group ID after opening listening port
# @param uid set group ID after opening listening port
# @param hooks a hash of hooks to set up, keyed by hook id
class webhook (
  Stdlib::IP::Address            $ip                           = '0.0.0.0',
  Stdlib::Port                   $port                         = 9000,
  String                         $urlprefix                    = 'hooks',
  Boolean                        $debug                        = false,
  Boolean                        $nopanic                      = true,
  Boolean                        $verbose                      = false,
  Array[String]                  $headers                      = [],
  Boolean                        $x_request_id                 = false,
  Hash[String[1], Webhook::Hook] $hooks                        = {},
  Optional[Integer]              $x_request_id_limit           = undef,
  Optional[Stdlib::Unixpath]     $cert                         = undef,
  Optional[Stdlib::Unixpath]     $key                          = undef,
  Optional[Stdlib::Unixpath]     $logfile                      = undef,
  Optional[Integer[1]]           $gid                          = undef,
  Optional[Integer[1]]           $uid                          = undef,
) {
  stdlib::ensure_packages(['webhook'])
  $secure = $cert =~ Stdlib::Unixpath and $key =~ Stdlib::Unixpath
  $config_path = '/etc/webhook.conf'
  $config = $hooks.map |$id, $hook| {
    $hook.merge({ 'id' => $id })
  }
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
    'urlprefix'          => $urlprefix,
    'secure'             => $secure,
    'setgid'             => $gid,
    'setuid'             => $uid,
    'verbose'            => $verbose,
    'x-request-id'       => $x_request_id,
    'x-request-id-limit' => $x_request_id_limit,
  }.webhook::clean_hash.webhook::argparse

  file { $config_path:
    ensure  => 'file',
    content => [$config].to_json(),
    notify  => Service['webhook'],
  }
  $override_content = @("CONTENT")
    [Service]
    ExecStart=
    ExecStart=/usr/bin/webhook ${command_arguments}
    | CONTENT
  systemd::dropin_file { 'puppet.conf':
    unit    => 'webhook.service',
    content => $override_content,
    notify  => Service['webhook'],
  }
  service { 'webhook':
    ensure => 'running',
    enable => true,
  }
}
