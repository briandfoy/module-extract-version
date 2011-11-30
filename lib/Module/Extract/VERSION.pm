require v5.10;

package Module::Extract::VERSION;
use strict;

use warnings;
no warnings;

use subs qw();
use vars qw($VERSION);

use Carp qw(carp);

$VERSION = '1.10_01';

=head1 NAME

Module::Extract::VERSION - Extract a module version safely

=head1 SYNOPSIS

	use Module::Extract::VERSION;

	my $version   # just the version
		= Module::Extract::VERSION->parse_version_safely( $file );

	my @version_info # extra info
		= Module::Extract::VERSION->parse_version_safely( $file );

=head1 DESCRIPTION

This module lets you pull out of module source code the version number
for the module. It assumes that there is only one C<$VERSION>
in the file and the entire C<$VERSION> statement is on the same line.

=cut

=head2 Class methods

=over 4

=item $class->parse_version_safely( FILE );

Given a module file, return the module version. This works just like
C<mldistwatch> in PAUSE. It looks for the single line that has the
C<$VERSION> statement, extracts it, evals it in a Safe compartment,
and returns the result.

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
	my( $sigil, $var, $version, $line_number, $rhs );
	while( <$fh> ) 
		{
		$line_number++;
		#print STDERR "Read: $_";
		chomp;
		$in_pod = /^=(?!cut)/ ? 1 : /^=cut/ ? 0 : $in_pod;
		next if $in_pod || /^\s*#/;

		next unless /
			(?<sigil>
				[\$*]
			)
			(?<identifier>
				(?<package>
					[\w\:\']*
				)
				\b
				VERSION
			)
			\b
			.*?
			\=
			(?<rhs>
				.*
			)
			/x;
		( $sigil, $var, $rhs ) = @+{ qw(sigil var rhs) };
		
		$version = $class->_eval_version( $_, @+{ qw(sigil var rhs) } );

		last;
		}
	$line_number = undef if eof($fh) && ! defined( $version );
	close $fh;
	
	return wantarray ? ( $sigil, $var, $version, $file, $line_number ) : $version;
	}

sub _eval_version
	{
	my( $class, $line, $sigil, $var, $rhs ) = @_;

	require Safe;
	require version;
	local $^W = 0;

	my $s = Safe->new;
	$s->share_from('main', ['*version::']);
	$s->share_from('version', ['&qv']);
	$s->reval('$VERSION = ' . $rhs);
	my $version = $s->reval('$VERSION');

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
