grammar Grammar::CSV {
  token TOP {
    [ <line> $*EOL? ]+
  }
  token line {
    ^^
      <value>* % $*SEP
    $$
  }
  token value {
    [
      | <-[$*QUOTE]> <-[$*SEP]>
      | <quoted>
    ]*
  }
  token quoted {
    $*QUOTE
    .+?
    $*QUOTE <!before $*ESCAPE>
  }
}
