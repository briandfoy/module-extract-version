# $Id$
package Module::Extract::VERSION;
use strict;

use warnings;
no warnings;

use subs qw();
use vars qw($VERSION);

use Carp qw(carp);

$VERSION = '0.11';

=head1 NAME

Module::Extract::VERSION - Extract a module version without running code

=head1 SYNOPSIS

	use Module::Extract::VERSION;

=head1 DESCRIPTION

=cut

=head2 Class methods

=over 4

=item $class->parse_version_safely( FILE );

Given a module file, return the module version. This works just like
C<mldistwatch> in PAUSE. It looks for the single line that has the
C<$VERSION> statement, extracts it, evals it, and returns the result.

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
	my $version;
	while( <$fh> ) 
		{
		chomp;
		$in_pod = /^=(?!cut)/ ? 1 : /^=cut/ ? 0 : $in_pod;
		next if $in_pod || /^\s*#/;

		next unless /([\$*])(([\w\:\']*)\bVERSION)\b.*\=/;
		my( $sigil, $var ) = ( $1, $2 );
		
		$version = $class->_eval_version( $_, $sigil, $var );

		last;
		}
	close $fh;

	return $version;
	}

sub _eval_version
	{
	my $class = shift;
	
	my( $line, $sigil, $var ) = @_;
	
	#print STDERR "Called with @_\n";
	
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

=head1 TO DO


=head1 SEE ALSO


=head1 SOURCE AVAILABILITY

This source is part of a SourceForge project which always has the
latest sources in CVS, as well as all of the previous releases.

	http://sourceforge.net/projects/brian-d-foy/

If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

I stole the some of this code from C<mldistwatch> in the PAUSE
code by Andreas KE<ouml>nig, but I've moved most of it around.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2008, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

1;
