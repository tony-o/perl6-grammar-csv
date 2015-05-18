#!/usr/bin/env perl6

use Grammar::CSV;
 
class CSV::Parser {
  has IO::Handle $.file_handle         = Nil;
  has Bool       $.contains_header_row = False;
  has Any        $.field_separator     = ','.encode;
  has Any        $.line_separator      = "\n".encode;
  has Any        $.field_operator      = '"'.encode;
  has Any        $.escape_operator     = '\\'.encode;
  has Int        $.chunk_size          = 1024;
  has Buf        $!lbuff               .=new;

  has Any        @!headers;

  method reset () {
    my $p = $.file_handle.path;
    $.file_handle.close;
    $.file_handle = open $p, :r;
  }

  method get_line () {
    return Nil if $.file_handle.eof && $!lbuff.elems == 0;
    my ($parsed, %line);
    
    my $*QUOTE  = $.field_operator.^can('decode') ?? $.field_operator.decode !! $.field_operator;
    my $*SEP    = $.field_separator.^can('decode') ?? $.field_separator.decode !! $.field_separator;
    my $*EOL    = $.line_separator.^can('decode') ?? $.line_separator.decode !! $.line_separator;
    my $*ESCAPE = $.escape_operator.^can('decode') ?? $.escape_operator.decode !! $.escape_operator;
    my $eol     = 0;
    my $stl     = 0; 
    my $itl     = 0;
    my $added   = 0;
    my $eof     = 0;
    while $!lbuff.grep({ .decode ~~ $.line_separator.decode }) || $parsed !~~ Match {
      $!lbuff ~= $.file_handle.read($.chunk_size) if !$.file_handle.eof; 
      while Any ~~ $parsed && $itl < $!lbuff.elems {
        while $!lbuff.subbuf($itl++, $.line_separator.decode.chars).decode ne $.line_separator.decode && $itl < $!lbuff.elems { }
        next unless $itl < $!lbuff.elems;
        $parsed = Grammar::CSV.parse($!lbuff.subbuf(0, $itl).decode);
        last if $parsed ~~ Match;
      }
#hack
      $added = $parsed !~~ Match && $.file_handle.eof ?? $*EOL.chars !! 0;
      $parsed = Grammar::CSV.parse($!lbuff.decode ~ $*EOL) if $added;
      last if $.file_handle.eof && $parsed !~~ Match;
      next if $parsed !~~ Match;
      try $!lbuff = $!lbuff.subbuf($itl);
      my @values = $parsed<line><value>.map({ 
        .EXISTS-KEY('quoted') ??
          .Str.substr($*QUOTE.chars, *-($*QUOTE.chars + $*EOL.chars + $added)) !!
          .Str // Nil.Str 
      });
      if $.contains_header_row && @!headers.elems == 0 {
        @!headers = @values;
        $parsed = Any;
        next;
      }
      last if Match ~~ $parsed;
    }
    return Nil if Match !~~ $parsed;
    $itl = 0;
    for 0 .. max(@!headers.elems, $parsed<line><value>.elems)-1 {
      %line{@!headers[$_] // $_} = $parsed<line><value>[$_].EXISTS-KEY('quoted') ??
          $parsed<line><value>[$_].Str.substr($*QUOTE.chars, *-($*QUOTE.chars + $*EOL.chars + $added)) !!
          $parsed<line><value>[$_].Str // Nil.Str 
    }
    return %line;
  };

};
