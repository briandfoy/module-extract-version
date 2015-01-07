use strict;
use warnings;

require v5.10;

my $github    = 'https://github.com/briandfoy/';
my $main_file = 'lib/';

my %WriteMakefile = (
	'NAME'	        => 'Module::Extract::VERSION',
	'ABSTRACT_FROM' => $main_file,
	'VERSION_FROM'  => 'lib/Module/Extract/VERSION.pm',
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',
	
	'PREREQ_PM'    => { 
		'Test::More'              => '0.95',
		'Tie::Hash::NamedCapture' => '0', # for named captures
		'version'                 => '0',
		},

	clean  => { FILES    => q|Module-Extract-VERSION-*| },

	META_MERGE => {
		'meta-spec' => { version => 2 },
		resources => {
			repository => {
				type => 'git',
				url  => 'https://github.com/briandfoy/module-extract-version.git',
				web  => 'https://github.com/briandfoy/module-extract-version',
			},
		},
	},
	);

sub arguments { \%WriteMakefile }

do_it() unless caller;
sub do_it {
	require File::Spec;
	my $MM ='ExtUtils::MakeMaker';
	my $MM_version =
		eval{ "$MM " . $WriteMakefile{'CONFIGURE_REQUIRES'}{'ExtUtils::MakeMaker'} }
			//
		"$MM 6.64";
	eval "use $MM_version" || die "Could not load $MM_version: $@";
	eval "use Test::Manifest 1.21" 
		if -e File::Spec->catfile( qw(t test_manifest) );
	WriteMakefile( %WriteMakefile );
	}


no warnings;
__PACKAGE__;
