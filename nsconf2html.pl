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

open my $info, $file or die "Could not open $file: $!";

#first pass to detect servers
print "Server list:\n";

while( my $line = <$info>)  {   
   
    if($line =~ /add server/){
    	my @values = split(' ',$line);
    	$server{ $values[2] } = $line;
        print $values[2]."\n";
        }
}

close $info;
open my $info, $file or die "Could not open $file: $!";

print "Service List:\n";
while( my $line = <$info>)  {   
   
    if($line =~ /add service/){
    	my @values = split(' ',$line);
    	$service{ $values[2] } = $line;
        print $values[2]."\n";
        }
}

close $info;
open my $info, $file or die "Could not open $file: $!";

print "Virtual Server List:\n";
#first pass to detect virtual servers
while( my $line = <$info>)  {   
   
    if($line =~ /add lb vserver/){
        my @values = split(' ',$line);
    	$vserver{ $values[3] } = $line;
        print $values[3]."\n";
    }
}

open my $info, $file or die "Could not open $file: $!";

print "Virtual Server - Services:\n";
#first pass to detect virtual servers
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

#print VS services bindings:
while ((my $key,my $value) = each(%bindings)){
     print $key." \n"; 
     for my $val (@$value){
     print "      ".$val."\n";
     }
}

close $info;