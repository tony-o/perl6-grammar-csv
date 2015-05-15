use Grammar::Tracer;
grammar Grammar::CSV {
  token TOP {
    [ <line> $*EOL? ]+
  }
  token line {
    ^^
      <value>+ % $*SEP?
    $$
  }
  token value {
    \s*
    [
       <quoted>
      || <-[$*QUOTE]> <-[$*SEP]>*?
    ]
    \s*
  }
  token quoted {
    $*QUOTE
    .*?
    <!after $*ESCAPE> $*QUOTE
  }
}
