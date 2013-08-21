#!usr/bin/perl
package Database_conn::dbconn;
use strict;
use warnings;
use DBD::mysql;
use DBI;
our (@ISA, @EXPORT, %EXPORT_TAGS, $VERSION);

use Exporter;
$VERSION = 0.01;
@ISA = qw(Exporter);

@EXPORT   = qw($DBIconnect);      # Symbols to autoexport (:DEFAULT tag)
%EXPORT_TAGS = ();

our $database = "Farm_Mobstor";

our $host = "127.0.0.1";
our  $port = "3306";

our  $user = "root";
our  $pw = "";

#DATA SOURCE NAME
our $dsn = "dbi:mysql:$database:localhost:3306";


# PERL DBI CONNECT
our $DBIconnect = DBI->connect($dsn, $user, $pw);
#print "Connected to DB";

1;

