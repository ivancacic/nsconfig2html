#este archivo toma un ns.conf y extrae los balanceos de carga para poder construir las
# tablas que hacen parte de la documentación. Las tablas resultantes estan en formato HTML.

use strict;
use warnings;

my $file = $ARGV[0];
if($file !~ /conf/){
die "Not a valid argumet\n";
}

my %server = ();
my %service = ();
my %vserver = ();
my %bindings = ();
#$bindings{"TEST"} = [];

my $out;
open($out, ">" ,"conf.html") or die "Cloud not open output file\n";
open my $info, $file or die "Could not open $file: $!";

print $out "<html><head><h2>Currently only LB config is displayed in html table format<h2></head><body>";

#first pass to detect servers
print "Server list:\n";

print $out "<table border=1pt><tr><td>Server Name</td><td>IP</td></tr>\n";
while( my $line = <$info>)  {   
   
    if($line =~ /add server/){
    	my @values = split(' ',$line);
    	$server{ $values[2] } = $line;
        print $values[2]."\n";
        print $out "<tr><td>".$values[2]."</td>";
        print $out "<td>".$values[3]."</td><tr>\n";
        }
}
print $out "</table><br><br>\n";

close $info;
open $info, $file or die "Could not open $file: $!";

print "Service List:\n";
print $out "<table border=1pt><tr><td>Service Name</td><td>Server</td><td>Port</td></tr>";
while( my $line = <$info>)  {   
   
    if($line =~ /add service/){
    	my @values = split(' ',$line);
    	$service{ $values[2] } = $line;
        print $values[2]."\n";
        print $out "<tr><td>".$values[2]."</td>";
        print $out "<td>".$values[3]."</td>";
        #"<td>".$values[4]."</td>"; this is the type of service
        print $out "<td>".$values[5]."</td></tr>\n";
        }
}
print $out "</table><br><br>\n";


close $info;
open $info, $file or die "Could not open $file: $!";

print "Virtual Server List:\n";
print $out "<table border=1pt><tr><td>Virtual Server Name</td><td>IP</td><td>Port</td></tr>\n";
#first pass to detect virtual servers
while( my $line = <$info>)  {   
   
    if($line =~ /add lb vserver/){
        my @values = split(' ',$line);
    	$vserver{ $values[3] } = $line;
        print $values[3]."\n";
        print $out "<tr><td>".$values[3]."</td>";
                #"<td>".$values[4]."</td>"; this is the type of service
        print $out "<td>".$values[5]."</td>";
        print $out "<td>".$values[6]."</td></tr>\n";
    }
}
print $out "</table><br><br>\n";
open $info, $file or die "Could not open $file: $!";

print "Virtual Server - Services:\n";
#first pass to detect services bound to virtual servers 
while( my $line = <$info>)  {   
   
    if($line =~ /bind lb vserver/){
        my @values = split(' ',$line);
        if(exists $bindings{$values[3]}){
    		$bindings{$values[3],push($bindings{$values[3]},$values[4])};
    	}else{
    		$bindings{$values[3]} = [$values[4]];
    	}
        #print $values[3]." - ".$values[4]."\n";
    }
}

print $out "<table border=1pt><tr><td>Virtual Server Name</td><td>Service Name</td></tr>\n";
#print VS services bindings:
while ((my $key,my $value) = each(%bindings)){
     print $key." \n";
     print $out "<tr><td rowspan=".scalar @$value.">".$key."</td>"; 
     my $first = 0;
     for my $val (@$value){
     	print "      ".$val."\n";
     	if($first!=0){ print $out "<tr>"; }
     	print $out "<td>".$val."</td></tr>";
     }
}
print $out "</table><br><br>\n";

close $info;