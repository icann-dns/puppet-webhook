function webhook::clean_hash (
  Hash $input,
) >> Hash {
  $input.filter |$key, $value| {
    $value ? {
      Boolean  => true,
      Hash     => !$value.empty,
      Array    => !$value.empty,
      NotUndef => true,
      default  => false,
    }
  }
}
