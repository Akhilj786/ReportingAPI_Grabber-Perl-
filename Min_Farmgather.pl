#!usr/bin/perl
use lib '../Reporting_Parser';#Path for dbconn.pm
use strict;
use warnings;
use JSON;
use Data::Dumper;
use LWP;
use DBD::mysql;
use DBI;
use DateTime;
use Database_conn::dbconn;
use XML::Simple;
use LWP::Simple;

my $ browser=LWP::UserAgent->new;
my $datetime=DateTime->now;
my $date_val=$datetime->ymd;

#Parsing API for Farmlist
my $parser = new XML::Simple;
my $url = 'http://reports.zenfs.com:8080/assets/get_farm_list.php?startdate=$date_val-00:00:00';
my $content = get $url or die "Unable to get $url\n";
my $data = $parser->XMLin($content);

#my @farm_list = keys %{$data->{'Farm'}};
#my @del_index=grep{$farm_list[$_] eq '*'} 0..$#farm_list;
#splice(@farm_list,$del_index[0],1);

my @farm_list=qw(usm1 use12 use18 use26 usw10 usw26 use70 usw70);

my $data_conv=9.09495e-13;#Convert byte to TB
my $FinalURL;
PreJson();

sub PreJson {
    #For every farm parse JSON store required parameter
    my $preURL="http://reports.zenfs.com:4080/v1/*:";
	my $postURL="/all/".$date_val."-00:00:00//day/?traffic=all&format=json";
    #my $postURL="/all/2013-08-22-00:00:00//day/?traffic=all&format=json";
    
    for(my $i=0;$i<=($#farm_list);$i++){
            my $Final_url=$preURL.$farm_list[$i].$postURL;
            Json_call($Final_url,$farm_list[$i]);
        }
    print "Done".$date_val."\n";	
}

sub Json_call{
    my $geturl=$_[0];
    my $farm_name=$_[1];
    my @time;
    my @value;
    my $i=0;
    my $rdata;
    my $size;
    my $response=$browser->get($geturl);
    
    #Response from reporting API
    if($response->is_success()){
            $rdata=$response->decoded_content();
            my $json_data=decode_json($rdata);
            my $array=$json_data->{'data-points'};
            $size=@$array;

        for($i;$i<$size;$i++){
                my $time_val=$json_data->{'data-points'}[$i]->{'time'};
                my @value_val=(($json_data->{'data-points'}[$i]->{'value'}));
                push(@time,$time_val);
                push(@value,@value_val);
 		}  
	}	
   table_storage($farm_name,$size,\@time,\@value);
 }

#Store farm details date wise
sub table_storage{

	my $fName=$_[0];
	my $size=$_[1];
	my $time_ref=$_[2];
	my $value_ref=$_[3];
    my $daysec_conv=86400;#Day to per second conversion factor
	my @dName;  

	for(my $i=0;$i<$size;$i++){
                my @split_val=split(/,/,$value_ref->[$i]);
                my $total_size=$split_val[0]*$data_conv;
                my $query="Insert into farm_use(fname,fdate,fsize,fget_ops,fput_ops) values(".
                          "'$fName','$time_ref->[$i]',$total_size,$split_val[4]/$daysec_conv,$split_val[5]/$daysec_conv)";
                #print $query."\n";
                my $sth = $DBIconnect->prepare($query);
                $sth->execute();
  }

}



