# This file takes a ns.conf and extracts the load balancing configuration in order to build the tables that are part of the documentation. The resulting charts are in html format.

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

my %td = ();
my $has_td = 0;
my %ips = ();
my %server = ();
my %service = ();
my %vserver = ();
my %bindings = ();

my $out;
open($out, ">" ,"conf.html") or die "Could not open output file\n";





print $out "<html><head><h2>Currently only LB config is displayed in html table format<h2></head><body>";
#first pass to detect servers
print "IP list:\n";
open my $info, $file or die "Could not open $file: $!";
print $out "<table border=1pt><tr><td>IP</td><td>Netmask</td><td>vServer State</td></tr>\n";
while( my $line = <$info>)  {   
   
    if($line =~ /add ns ip /){ # Adding a space here drops IPv6
    	my @values = split(' ',$line);
    	$ips{ $values[3] } = $line; #3 es IP, 4 es netmask y 5 en aldelante son parms
        print $values[3]."\n";
        print $out "<tr><td>".$values[3]."</td>";
		print $out "<td>".$values[4]."</td>";
        print $out "<td>".$values[6]."</td><tr>\n";
        }
}
print $out "</table><br>\n";
close $info;

open $info, $file or die "Could not open $file: $!";
print $out "<h3>Routes</h3>\n";
print $out "<table border=1pt><tr><td>IP</td><td>Netmask</td><td>Gateway</td>";
if($has_td==1){
print $out "<td>TD</td>";
}
print $out "</tr>";
while( my $line = <$info>)  {   
   
    if($line =~ /add route /){
    	my @values = split(' ',$line);
    	my %svc_params = extract_params($line);
    	$service{ $values[2] } = $line;
        print $values[2]."\n";
        print $out "<tr><td>".$values[2]."</td>";
        print $out "<td>".$values[3]."</td>";
        print $out "<td>".$values[4]."</td>";
        if($has_td==1){
			print $out "<td>".$svc_params{"td"}."</td>";
		}
        print $out "</tr>\n";
        }
}
print $out "</table><br><br>\n";


print "Traffic Domains:\n";
open $info, $file or die "Could not open $file: $!";
print $out "<h3>Traffic Domains</h3>\n";
print $out "<table border=1pt><tr><td>Traffic Domain</td><td>Alias</td></tr>\n";
while( my $line = <$info>)  {   
   
    if($line =~ /add ns trafficDomain/){
    	my @values = split(' ',$line);
    	$td{ $values[3] } = $line; #3 es id, 5 es alias
        print "ID: ".$values[3]." Alias: ".$values[5]."\n";
        print $out "<tr><td>".$values[3]."</td>";
        print $out "<td>".$values[5]."</td><tr>\n";
        $has_td = 1;
    }
}
print $out "</table><br>\n";
close $info;


open $info, $file or die "Could not open $file: $!";
print $out "<h3>High Availability</h3>\n";
print $out "<table border=1pt><tr><td>Node ID</td><td>IP</td></tr>\n";
while( my $line = <$info>)  {   
   
    if($line =~ /add HA node/){
    	my @values = split(' ',$line);
        print "HA Node ".$values[4]."\n";
        print $out "<tr><td>".$values[3]."</td>";
        print $out "<td>".$values[4]."</td><tr>\n";
        }
}
print $out "</table><br>\n";
close $info;


open $info, $file or die "Could not open $file: $!";
#first pass to detect servers
print "Server list:\n";
print $out "<h3>Server List</h3>\n";
print $out "<table border=1pt><tr><td>Server Name</td><td>IP</td>";
if($has_td==1){
print $out "<td>TD</td>";
}
print $out "</tr>\n";
while( my $line = <$info>)  {   
   
    if($line =~ /add server/){
    	my @values = split(' ',$line);
    	$server{ $values[2] } = $line;
        print $values[2]."\n";
        print $out "<tr><td>".$values[2]."</td>";
        print $out "<td>".$values[3]."</td>";
        if($has_td==1)
        {
        print $out "<td>".$values[5]."</td>";
        }
        print $out "<tr>\n";
        }
}
print $out "</table><br>\n";
close $info;

open $info, $file or die "Could not open $file: $!";
print "Service List:\n";
print $out "<h3>Services</h3>\n";
print $out "<table border=1pt><tr><td>Service Name</td><td>Server</td><td>Type</td><td>Port</td>";
if($has_td==1){
print $out "<td>TD</td>";
}
print $out "</tr>";
while( my $line = <$info>)  {   
   
    if($line =~ /add service /){
    	my @values = split(' ',$line);
    	my %svc_params = extract_params($line);
    	$service{ $values[2] } = $line;
        print $values[2]."\n";
        print $out "<tr><td>".$values[2]."</td>";
        print $out "<td>".$values[3]."</td>";
        print $out "<td>".$values[4]."</td>";
        print $out "<td>".$values[5]."</td>";
        if($has_td==1){
			print $out "<td>".$svc_params{"td"}."</td>";
		}
        print $out "</tr>\n";
        }
}
print $out "</table><br><br>\n";

open $info, $file or die "Could not open $file: $!";
print $out "<h3>Service Groups</h3>\n";
print $out "<table border=1pt><tr><td>Service Group Name</td><td>Type</td>";
if($has_td==1){
print $out "<td>TD</td>";
}
print $out "</tr>";
while( my $line = <$info>)  {   
   
    if($line =~ /add serviceGroup/){
    	my @values = split(' ',$line);
    	my %svc_params = extract_params($line);
    	$service{ $values[2] } = $line;
        print $values[2]."\n";
        print $out "<tr><td>".$values[2]."</td>";
        print $out "<td>".$values[3]."</td>";
        if($has_td==1){
			print $out "<td>".$svc_params{"td"}."</td>";
		}
        print $out "</tr>\n";
        }
}
print $out "</table>&nbsp;\n";

open $info, $file or die "Could not open $file: $!";
print $out "<table border=1pt><tr><td>Service Group Name</td><td>Servers</td>";
if($has_td==1){
print $out "<td>TD</td>";
}
print $out "</tr>";
while( my $line = <$info>)  {   
   
    #if($line =~ /bind serviceGroup/){
	if($line =~ /bind serviceGroup/ && $line !~ /\-monitorName/){ #This will ignore monitor binds
    	my @values = split(' ',$line);
    	my %svc_params = extract_params($line);
    	$service{ $values[2] } = $line;
        print $values[2]."\n";
        print $out "<tr><td>".$values[2]."</td>";
        print $out "<td>".$values[3]."</td>";
        if($has_td==1){
			print $out "<td>".$svc_params{"td"}."</td>";
		}
        print $out "</tr>\n";
        }
}
print $out "</table><br>\n";
close $info;

open $info, $file or die "Could not open $file: $!";
print $out "<h3>Virtual Server Bindings</h3>\n";
print "Bindings for Virtual Server - Services:\n";
#first pass to detect services bound to virtual servers 
while( my $line = <$info>)  {   
   
	if($line =~ /bind lb vserver/ && $line !~ /\-policyName/){ #This will ignore Policy binds
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
print $out "<h3>Virtual Server Configuration</h3>\n";
print $out "<table border=1pt><tr><td>Virtual Server Name</td><td>Category</td><td>Value</td></tr>\n";
#first pass to detect virtual servers
while( my $line = <$info>)  {   
   
    if($line =~ /add lb vserver/){
    	print "START ".$line."\n";
        my @values = split(' ',$line);
        my %params = extract_params($line);
    	$vserver{ $values[3] } = $line;
    	my @services = (); 
    	my $count_services = 0;
    	if(exists $bindings{$values[3]}){   	
    		$count_services = scalar @{$bindings{$values[3]}}."\n";
    	}
    	print "VS: ".$values[3]." # Services: ".$count_services."\n";
    	if($count_services>0){
    	   	@services =  @{$bindings{$values[3]}};
    	}
    	else{
    		print "VS: ".$values[3]." No Services!\n";
    	}
    	#print "Dump arr".Dumper(@services)."\n";

    	#print "==============\n".Dumper(@services)."\n+++++++\n";
        print $values[3]."\n";
        ##### determine how many lines will be printed#######
        my $rowspan = 6;
        if(exists $params{"timeout"})
    	{ $rowspan++;}
    	if(exists $params{"lbmethod"})
    	{ $rowspan++}
    	if(exists $params{"td"})
    	{ $rowspan++}
        #####################################################
        $rowspan += scalar @services;
        print $out "<tr><td rowspan=".$rowspan.">".$values[3]."</td><td>Type</td><td>".$values[4]."</td></tr>\n";
        print $out "<tr><td>IP</td><td>".$values[5]."</td></tr>\n";
        print $out "<tr><td>Port</td><td>".$values[6]."</td></tr>\n";
    	############## Add aditional lines if you need more rows with information, 
    	############## params is a hash that uses the key as the -param i.e. -persistenceType without the '-' 
    	print $out "<tr><td>persistenceType</td><td>".$params{"persistenceType"}."</td></tr>\n";
		#print $out "<tr><td>certKeyName</td><td>".$params{"certKeyName"}."</td></tr>\n";
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
    	if(exists $params{"td"})
    	{   		
    		print $out "<tr><td>Traffic Domain</td><td>".$params{"td"}."</td></tr>\n";
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
    	print "END\n";
    }
}
print $out "</table><br><br>\n";

#diffrent format for word paste
open $info, $file or die "Could not open $file: $!";

print "Virtual Server List:\n";
print $out "Easy copy paste version of VS list:<br><table border=1pt><tr><td>Virtual Server Name</td><td>Category</td><td>Value</td></tr>\n";
#first pass to detect virtual servers
while( my $line = <$info>)  {   
   
    if($line =~ /add lb vserver/){
        my @values = split(' ',$line);
        my %params = extract_params($line);
    	$vserver{ $values[3] } = $line;
    	my @services = (); 
    	my $count_services = 0;
    	if(exists $bindings{$values[3]}){   	
    		$count_services = scalar @{$bindings{$values[3]}}."\n";
    	}
    	print "VS: ".$values[3]." # Services: ".$count_services."\n";
    	if($count_services>0){
    	   	@services =  @{$bindings{$values[3]}};
    	}
    	else{
    		print "VS: ".$values[3]." No Services!\n";
    	}
    	#print "Dump arr".Dumper(@services)."\n";

    	#print "==============\n".Dumper(@services)."\n+++++++\n";
        print $values[3]."\n";
        my $rowspan = 6;
        if(exists $params{"td"}){$rowspan++;}
        $rowspan +=scalar @services;
        print $out "<tr><td>".$values[3]."</td><td>Type</td><td>".$values[4]."</td></tr>\n";
        print $out "<tr><td></td><td>IP</td><td>".$values[5]."</td></tr>\n";
        print $out "<tr><td></td><td>Port</td><td>".$values[6]."</td></tr>\n";
    	############## Add additional lines if you need more rows with information, 
    	############## params is a hash that uses the key as the -param i.e. -persistenceType without the '-' 
    	print $out "<tr><<td></td><td>persistenceType</td><td>".$params{"persistenceType"}."</td></tr>\n";
    	if(exists $params{"timeout"})
    	{ 
    	 	print $out "<tr><td></td><td>Persistence Timeout</td><td>".$params{"timeout"}."</td></tr>\n";
    	 }else{
    	 	print $out "<tr><td></td><td>Persistence Timeout</td><td>Default</td></tr>\n";
    	 }
    	if(exists $params{"lbmethod"})
    	{ 
    		print $out "<tr><td></td><td>Loadbalance Method</td><td>".$params{"lbmethod"}."</td></tr>\n";
    	}else{
    		print $out "<tr><td></td><td>Loadbalance Method</td><td>ROUNDROBIN</td></tr>\n";
    	}
    	if(exists $params{"td"})
    	{   		
    		print $out "<tr><td></td><td>Traffic Domain</td><td>".$params{"td"}."</td></tr>\n";
    	}
    	
    	#print "\n++++++++++\n".Dumper(@services)."\n==========\n";
    	for my $i (0 .. @services-1){
    		#print "iteracion: ".$i." VS: ".$values[3]." Services: ".@services[$i]."\n";
    		if ($i==0){ 
    			print $out "<tr><<td></td><td>Services</td><td>".$services[$i]."</td></tr>\n";
    		}else{
    			print $out "<tr><td></td><td></td><td>".$services[$i]."</td></tr>\n";	
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
