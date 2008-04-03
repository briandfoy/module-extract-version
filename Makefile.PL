# $Id: Makefile.PL,v 1.4 2004/07/04 17:04:17 comdog Exp $
use ExtUtils::MakeMaker;

require 5.006;

eval "use Test::Manifest 1.14";

WriteMakefile(
	'NAME'	       => 'Module::Extract::VERSION',
	'ABSTRACT'     => 'This is what the module does',
	'VERSION_FROM' => 'lib/VERSION.pm',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',
	
	'PREREQ_PM'    => { 
		'Test::More' => '0',
		},

	'PM'           => {
		'lib/VERSION.pm'         => '$(INST_LIBDIR)/VERSION.pm',
		},

	'MAN3PODS'     => {
		'lib/VERSION.pm' => '$(INST_MAN3DIR)/Module::Extract::VERSION.3',
		},

	clean  => { FILES    => q|Module-Extract-VERSION-*| },

	);
