# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Get the version info
--- request
GET /=/version
--- response_like
^"EEEE OpenAPI \d+\.\d+\.\d+ \(revision \d+\) with the (?:Pg|PgFarm) (?:\([-\w]+\) )?backend\.\\nCopyright \(c\) 2007-2008 by Yahoo! China EEEE Works\.\\n"$

