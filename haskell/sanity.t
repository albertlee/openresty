#!/usr/bin/env perl

use strict;
use warnings;

use IPC::Run3;
use Test::Base 'no_plan';
use Test::LongString;

run {
    my $block = shift;
    my $desc = $block->description;
    my ($stdout, $stderr);
    run3 ['./restyscript', $block->in], \undef, \$stdout, \$stderr;
    is $? >> 8, 0, "compiler returns 0 - $desc";
    warn $stderr if $stderr;
    my @ln = split /\n+/, $stdout;
    my $ast = $block->ast;
    if (defined $ast) {
        is "$ln[0]\n", $ast, "AST ok - $desc";
    }
    is "$ln[1]\n", $block->out, "Pg/SQL output ok - $desc";
};

__DATA__

=== TEST 1: basic
--- in
select foo, bar from Bah
--- ast
Select [Column (Symbol "foo"),Column (Symbol "bar")] From [Model (Symbol "Bah")]
--- out
select "foo", "bar" from "Bah"



=== TEST 2: select only
--- in
select foo
--- ast
Select [Column (Symbol "foo")]
--- out
select "foo"



=== TEST 3: spaces around separator (,)
--- in
select id,name , age from  Post , Comment
--- ast
Select [Column (Symbol "id"),Column (Symbol "name"),Column (Symbol "age")] From [Model (Symbol "Post"),Model (Symbol "Comment")]
--- out
select "id", "name", "age" from "Post", "Comment"



=== TEST 4: simple where clause
--- in
select id from Post where a > b
--- ast
Select [Column (Symbol "id")] From [Model (Symbol "Post")] Where (OrExpr [AndExpr [RelExpr (">",Column (Symbol "a"),Column (Symbol "b"))]])
--- out
select "id" from "Post" where ((("a" > "b")))



=== TEST 5: floating-point numbers
--- in
select id from Post where 00.003 > 3.14 or 3. > .0
--- out
select "id" from "Post" where (((0.003 > 3.14)) or ((3.0 > 0.0)))



=== TEST 6: integral numbers
--- in
select id from Post where 256 > 0
--- ast
Select [Column (Symbol "id")] From [Model (Symbol "Post")] Where (OrExpr [AndExpr [RelExpr (">",Integer 256,Integer 0)]])
--- out
select "id" from "Post" where (((256 > 0)))



=== TEST 7: simple or
--- in
select id from Post  where a > b or b <= c
--- out
select "id" from "Post" where ((("a" > "b")) or (("b" <= "c")))



=== TEST 8: and in or
--- in
select id from Post where a > b and a like b or b = c and d >= e or e <> d'
--- out
select "id" from "Post" where ((("a" > "b") and ("a" like "b")) or (("b" = "c") and ("d" >= "e")) or (("e" <> "d")))



=== TEST 9: literal strings
--- in
select id from Post where 'a''\'' = 'b\\\n\r\b\a'
--- out
select "id" from "Post" where ((('a''''' = 'b\\\n\r\ba')))

