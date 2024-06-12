function webhook::argparse (
  Hash[String[2], Variant[Boolean, String, Numeric, Array[Variant[String, Numeric]]]] $args,
  String                                                                              $prefix    = '',
) >> String {
  $args.map |$key, $value| {
    $value ? {
      Boolean => $value.bool2str("-${key}", ''),
      Array   => $value.map |$v| { "-${key} ${v}" }.join(' '),
      default => "-${key} ${value.shell_escape}",
    }
  }.join(' ').strip
}
