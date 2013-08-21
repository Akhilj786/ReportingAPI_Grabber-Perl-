#!usr/bin/perl
#First Commit
use strict;
use warnings;
use DBD::mysql;
use Database_conn::dbconn;
my @farm_list=qw(usm1 use12 use18 use26 usw10 usw26 use70 usw70);
for(my $i=0;$i<=($#farm_list);$i++){
  my $query="select fdate,fsize from farm_use where fname like '$farm_list[$i]'";
                my $fullstring="fdate".","."fsize\n";                
                my $sth = $DBIconnect->prepare($query);
                $sth->execute();
                open FILE, "+> /Users/akhilja/Desktop/Graph/$farm_list[$i].csv" or die $!;
                my $row;
                while($row=$sth->fetchrow_hashref()){
                                        my $fsize=$row->{fsize};
                                        my $fdate=$row->{fdate};
                                        $fullstring.=$fdate.",".$fsize."\n";

                }
                #print $fullstring."\n\n";
                print FILE $fullstring;
                close FILE;


}