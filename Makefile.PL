use ExtUtils::MakeMaker;

require 5.006;

eval "use Test::Manifest 1.21";

WriteMakefile(
	'NAME'	       => 'Module::Extract::VERSION',
	'ABSTRACT'     => 'Extract $VERSION from module source code',
	'VERSION_FROM' => 'lib/Module/Extract/VERSION.pm',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',
	
	'PREREQ_PM'    => { 
		'Test::More' => '0',
		},

	'META_MERGE'   => {
		no_index => {
			directory => [ qw(t inc corpus) ],
			}
		},

	clean  => { FILES    => q|Module-Extract-VERSION-*| },
	);
