grammar Grammar::CSV {
  token TOP {
    <line> 
  }
  token line {
    <value>+ % $*SEP
  }
  token value {
    \s*
    [
         <quoted>
      || <unquoted>
      || <empty>
    ]
    \s* 
  }
  token quoted {
    $*QUOTE
    .*?
    <!after $*ESCAPE> $*QUOTE
  }
  token unquoted {
    <!quote> .*? <?before [ $*SEP || $*EOL ]>
  }
  token empty {
    '' <?before [ $*SEP || $*EOL ]>
  }
  token quote {
    $*QUOTE
  }
}
