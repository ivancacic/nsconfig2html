#este archivo toma un ns.conf y extrae los balanceos de carga para poder construir las
# tablas que hacen parte de la documentación. Las tablas resultantes estan en formato HTML.

use strict;
use warnings;
use Data::Dumper;


#input the config line, return a hash that the keys are the -someting in the config line
sub extract_params{
		my $line = $_[0];
		my %params;
        my @params_temp = split('-',$line);
        my @arr;
        #print "+++++++++ Dump split en - arreglo:\n".Dumper(@params_temp)."\n+++++++++++++arreglo fin -------- \n";
	for my $elem (@params_temp){
		@arr = split(/ /, $elem);
  		$params{$arr[0]} = $arr[1];
  		#print "\n Key ".$arr[0]." Value ".$arr[1]."\n";
  		#print "==========Dump sub split en ' ':\n".Dumper(@arr)."\n ========= arreglo fin --------------- \n";
  	}
  	
  	return %params;
}


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


print "Virtual Server - Services:\n";
#first pass to detect services bound to virtual servers 
while( my $line = <$info>)  {   
   
    if($line =~ /bind lb vserver/){
        my @values = split(' ',$line);
        if(exists $bindings{$values[3]}){
        	my @svcs = @{$bindings{$values[3]}};
        	push @svcs,$values[4];
    		$bindings{$values[3]} = \@svcs;
    	}else{
    		my @svcs;
    		push @svcs,$values[4];
    		$bindings{$values[3]} = \@svcs;
    	}
        #print $values[3]." - ".$values[4]."\n";
    }
    
}

print $out "<table border=1pt><tr><td>Virtual Server Name</td><td>Service Name</td></tr>\n";
print "VS services bindings:\n";
#print "=======================\n".Dumper(%bindings)."\n++++++++++++++++++++";
for (keys %bindings){
     print " Key:  ".$_." \n";
     my @value = @{$bindings{$_}};
     #print "=====\n".Dumper(@value)."======\n";
     print $out "<tr><td rowspan=".scalar @value.">".$_."</td>"; 
     for my $i (0 .. $#value){
     #for my $val (@value){
     	#print "      Val en i ".$i.": ".$value[$i]."\n";
     	if($i==0){ 
     	print "      Val en i ".$i.": ".$value[$i]."\n";
     	print "<tr>"; 
     	}else{
     		print "      Val en i ".$i.": ".$value[$i]."\n";
     	}
     	print $out "<td>".$value[$i]."</td></tr>";
     }
}
print $out "</table><br><br>\n";
open $info, $file or die "Could not open $file: $!";

print "Virtual Server List:\n";
print $out "<table border=1pt><tr><td>Virtual Server Name</td><td>Category</td><td>Value</td></tr>\n";
#first pass to detect virtual servers
while( my $line = <$info>)  {   
   
    if($line =~ /add lb vserver/){
        my @values = split(' ',$line);
        my %params = extract_params($line);
    	$vserver{ $values[3] } = $line;
    	my @services =  @{$bindings{$values[3]}};
    	#print "Dump arr".Dumper(@services)."\n";

    	#print "==============\n".Dumper(@services)."\n+++++++\n";
        print $values[3]."\n";
        my $rowspan = 6 + scalar @services;
        print $out "<tr><td rowspan=".$rowspan.">".$values[3]."</td><td>Tipo</td><td>".$values[4]."</td></tr>\n";
        print $out "<tr><td>IP</td><td>".$values[5]."</td></tr>\n";
        print $out "<tr><td>Puerto</td><td>".$values[6]."</td></tr>\n";
    	############## Add aditional lines if you need more rows with information, 
    	############## params is a hash that uses the key as the -param i.e. -persistenceType without the '-' 
    	print $out "<tr><td>persistenceType</td><td>".$params{"persistenceType"}."</td></tr>\n";
    	if(exists $params{"timeout"})
    	{ 
    	 	print $out "<tr><td>Persistence Timeout</td><td>".$params{"timeout"}."</td></tr>\n";
    	 }else{
    	 	print $out "<tr><td>Persistence Timeout</td><td></td></tr>\n";
    	 }
    	if(exists $params{"lbmethod"})
    	{ 
    		print $out "<tr><td>Loadbalance Method</td><td>".$params{"lbmethod"}."</td></tr>\n";
    	}else{
    		print $out "<tr><td>Loadbalance Method</td><td>ROUNDROBIN</td></tr>\n";
    	}
    	
    	#print "\n++++++++++\n".Dumper(@services)."\n==========\n";
    	for my $i (0 .. @services-1){
    		#print "iteracion: ".$i." VS: ".$values[3]." Services: ".@services[$i]."\n";
    		if ($i==0){ 
    			print $out "<tr><td rowspan=".scalar @services.">Services</td><td>".$services[$i]."</td></tr>\n";
    		}else{
    			print $out "<tr><td>".$services[$i]."</td></tr>\n";	
    		}
    	}
    	#print "Dump hash".Dumper(\%params)."\n";
    #persistenceType
    #timeout
    #cltTimeout
    }
}
print $out "</table><br><br>\n";

close $info;