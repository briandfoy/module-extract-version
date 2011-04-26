package Module::Extract::VERSION;
use strict;

use warnings;
no warnings;

use subs qw();
use vars qw($VERSION);

use Carp qw(carp);

$VERSION = '1.01';

=head1 NAME

Module::Extract::VERSION - Extract a module version without running code

=head1 SYNOPSIS

	use Module::Extract::VERSION;

	my $version   # just the version
		= Module::Extract::VERSION->parse_version_safely( $file );

	my @version_info # extra info
		= Module::Extract::VERSION->parse_version_safely( $file );

=head1 DESCRIPTION

This module lets you pull out of module source code the version number
for the module. It assumes that there is only one C<$VERSION>
in the file.

=cut

=head2 Class methods

=over 4

=item $class->parse_version_safely( FILE );

Given a module file, return the module version. This works just like
C<mldistwatch> in PAUSE. It looks for the single line that has the
C<$VERSION> statement, extracts it, evals it, and returns the result.

In scalar context, it returns just the version as a string. In list
context, it returns the list of:

	sigil
	fully-qualified variable name
	version value
	file name
	line number of $VERSION

=cut

sub parse_version_safely # stolen from PAUSE's mldistwatch, but refactored
	{
	my $class = shift;
	my $file = shift;
	
	local $/ = "\n";
	local $_; # don't mess with the $_ in the map calling this
	
	my $fh;
	unless( open $fh, "<", $file )
		{
		carp( "Could not open file [$file]: $!\n" );
		return;
		}
	
	my $in_pod = 0;
	my( $sigil, $var, $version, $line_number );
	while( <$fh> ) 
		{
		$line_number++;
		#print STDERR "Read: $_";
		chomp;
		$in_pod = /^=(?!cut)/ ? 1 : /^=cut/ ? 0 : $in_pod;
		next if $in_pod || /^\s*#/;

		next unless /([\$*])(([\w\:\']*)\bVERSION)\b.*\=/;
		( $sigil, $var ) = ( $1, $2 );
		
		#print STDERR "Got $1 and $2\n";
		
		$version = $class->_eval_version( $_, $sigil, $var );

		last;
		}
	$line_number = undef if eof($fh) && ! defined( $version );
	close $fh;
	
	return wantarray ? ( $sigil, $var, $version, $file, $line_number ) : $version;
	}

sub _eval_version
	{
	my $class = shift;
	
	my( $line, $sigil, $var ) = @_;
	
	#print STDERR "_eval_version called with @_\n";
	
	my $eval = qq{ 
		package ExtUtils::MakeMaker::_version;

		local $sigil$var;
		\$$var=undef; do {
			$line
			}; \$$var
		};
		
	my $version = do {
		local $^W = 0;
		no strict;
		eval( $eval );
		};

	#print STDERR "Version is $version\n";

	return $version;
	}

=back

=head1 SOURCE AVAILABILITY

This code is in Github:

	git://github.com/briandfoy/module-extract-version.git

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

I stole the some of this code from C<mldistwatch> in the PAUSE
code by Andreas KE<ouml>nig, but I've moved most of it around.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2008-2011, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

1;
