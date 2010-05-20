use strict;
use warnings;

use File::Spec;

use Test::More 'no_plan';

use_ok( 'Module::Extract::VERSION' );
can_ok( 'Module::Extract::VERSION', qw(parse_version_safely) );

my %Corpus = (
	'Easy.pm'       => 3.01,   
	'RCS.pm'        => 1.23,   
	'Underscore.pm' => "0.10_01",
	'ToTk.pm'       => undef,
	);
	
foreach my $file ( sort keys %Corpus )
	{
	my $path = File::Spec->catfile( 'corpus', $file );
	ok( -e $path, "Corpus file [ $path ] exists" );
	
	my $version = 
		eval{ Module::Extract::VERSION->parse_version_safely( $path ) };
		
	is( $version, $Corpus{$file}, "Works for $file" );
	
	}
