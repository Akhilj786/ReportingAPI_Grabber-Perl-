#!usr/bin/perl
#First Commit

use lib '/Users/akhilja/Desktop/MObStor/Reporting_Parser';
use strict;
use warnings;
use JSON;
use Data::Dumper;
use LWP;
use DBD::mysql;
my $ browser=LWP::UserAgent->new;
use DBI;
use DateTime;
use Database_conn::dbconn;
use XML::Simple;
use LWP::Simple;
my $parser = new XML::Simple;
my $url = 'http://reports.zenfs.com:8080/assets/get_farm_list.php?startdate=2013-08-09-11:30:00';
my $content = get $url or die "Unable to get $url\n";
my $data = $parser->XMLin($content);

#my @farm_list=qw(apac3 apac301 apac4 apac401 eu1 eu101 eu201 eum1 f30 f31 f34 f35 f50 f51 f52 f53 f54 f55 f57 f59 f69 inm1 sgm1 sgm2 tp2 tpm1 tusw26 tusw27 tusw28 tusw29 use10use100 use103 use105 use11 use12 use18 use26 use3 use44 use45 use70 usm1 usm10 usm2 usm3 usm4 usm5 usm6 usm7 usm8 usm9 usw10 usw100 usw103 usw105 usw11 usw12 usw18 usw26 usw3 usw44 usw45 usw70);
my @farm_list=qw(usm1 use12 use18 use26 usw10 usw26 use70 usw70);
#my @farm_list=keys %{$data->{'Farm'}};
my $data_conv=9.09495e-13;
my $FinalURL;
PreJson();
sub PreJson {
my $datetime=DateTime->now;
my $date_val=$datetime->ymd;
my $preURL="http://reports.zenfs.com:4080/v1/*:";
	my $postURL="/all/".$date_val."-00:00:00//day/?traffic=all&format=json";
#my $postURL="/all/2013-08-15-00:00:00//day/?traffic=all&format=json";
for(my $i=0;$i<=($#farm_list);$i++){
		my $Final_url=$preURL.$farm_list[$i].$postURL;
		Json_call($Final_url,$farm_list[$i]);
	}
print "Done".$date_val."\n";	
	}

sub Json_call{
  my $geturl=$_[0];
  my $farm_name=$_[1];
  #print "Given Url:",$geturl,"\n";

  my @time;
  my @value;

  my $i=0;
  my $rdata;
  my $size;
  #print "\nDomainName:",$_[1],"\t ";

  my $data_con=$_[3];
    my $response=$browser->get($geturl);
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
  
  

 

sub table_storage{

	my $fName=$_[0];
	my $size=$_[1];
	my $time_ref=$_[2];
	my $value_ref=$_[3];
	my @dName;  

	for(my $i=0;$i<$size;$i++){
		my @split_val=split(/,/,$value_ref->[$i]);
                my $total_size=$split_val[0]*$data_conv;
                my $query="Insert into farm_use(fname,fdate,fsize,fget_ops,fput_ops) values("."'$fName','$time_ref->[$i]',$total_size,$split_val[4]/86400,$split_val[5]/86400)";
                #print $query."\n";
               	my $sth = $DBIconnect->prepare($query);
               	$sth->execute();
  }

}
=pod
sub DName_call{


my  $host = "127.0.0.1";
my  $port = "3307";

my  $user = "root";
my  $pw = "";
my $dsn = "dbi:mysql:$database:localhost:3307";


my $DBIconnect = DBI->connect($dsn, $user, $pw);


my @dName;
my $query="SELECT distinct d_domainName from farm_domain";

   my $sth = $DBIconnect->prepare($query);
   $sth->execute();
 $sth->bind_columns(undef,\my $d_domainName);
 while($sth->fetch()){
  if($d_domainName=~/(test|ping|argus)+(.*)/){
    }
  
  else{
      push(@dName,$d_domainName);
      }
  
 }
  @dName;
 }


=cut



