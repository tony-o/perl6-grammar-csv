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

  has Any        %!headers;

  method reset () {
    my $p = $.file_handle.path;
    $.file_handle.close;
    $.file_handle = open $p, :r;
  }

  method get_line () {
    return Nil if $.file_handle.eof;
    my ($parsed, %line);
    
    my $*QUOTE  = $.field_operator.decode;
    my $*SEP    = $.field_separator.decode;
    my $*EOL    = $.line_separator.decode;
    my $*ESCAPE = $.escape_operator.decode;
    $parsed = Grammar::CSV.parse($!lbuff.decode);
    while $!lbuff.grep({ .decode ~~ $.line_separator.decode }) || Any ~~ $parsed {
      $!lbuff ~= $.file_handle.read($.chunk_size); 
      $parsed = Grammar::CSV.parse($!lbuff.decode);
      $parsed.perl.say;
      return Nil;
    }
    $parsed.perl.say;
    return %line;
  };

};
