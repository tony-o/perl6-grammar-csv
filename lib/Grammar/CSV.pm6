use Grammar::Tracer;
grammar Grammar::CSV {
  token TOP {
    <line> $*EOL?
  }
  token line {
    <value>+ % $*SEP?
    $*EOL
  }
  token value {
    \s*
    [
         <quoted>
      || <unquoted>
    ]
    \s* 
  }
  token quoted {
    $*QUOTE
    .*?
    <!after $*ESCAPE> $*QUOTE
  }
  token unquoted {
    .*? <before [ $*SEP || $*EOL ]>
  }
}
