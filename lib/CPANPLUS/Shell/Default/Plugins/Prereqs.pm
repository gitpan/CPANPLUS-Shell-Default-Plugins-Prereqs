package CPANPLUS::Shell::Default::Plugins::Prereqs;

###########################################################################
# CPANPLUS::Shell::Default::Plugin::Prereqs
# Mark V. Grimes
#
# This is a CPANPLUS::Shell::Default plugin that will parse the Build.PL or Makefile.PL file in the current directory or in a distribution and install all the prerequisites.
# Copyright (c) 2007 Mark Grimes (mgrimes@cpan.org).
# All rights reserved. This program is free software; you can redistribute
# it and/or modify it under the same terms as Perl itself.
#
# Formatted with tabstops at 4
#
###########################################################################

use strict;
use warnings;
use Params::Check qw(check);

use Carp;
use Data::Dumper;

our $VERSION = '0.03_01';

sub plugins { (
            prereqs => 'install_prereqs',
        ) };

sub install_prereqs {
    my $class   = shift;    # CPANPLUS::Shell::Default::Plugins::Prereqs
    my $shell   = shift;    # CPANPLUS::Shell::Default object
    my $cb      = shift;    # CPANPLUS::Backend object
    my $cmd     = shift;    # 'prereqs'
    my $input   = shift;    # 
    my $opts    = shift;    # { foo => 0, bar => 2 }

    # print "[install_prereqs] $input\n";
    my %hash = ref $opts ? %$opts : {};
    my $conf = $cb->configure_object;
    
    my $args;
    my( $force, $verbose, $buildflags, $skiptest, $prereq_target,
            $perl, $prereq_format, $prereq_build);
    {   local $Params::Check::ALLOW_UNKNOWN = 1;
        my $tmpl = {
            force           => {    default => $conf->get_conf('force'),
                                    store   => \$force },
            verbose         => {    default => $conf->get_conf('verbose'),
                                    store   => \$verbose },
            perl            => {    default => $^X, store => \$perl },
            buildflags      => {    default => $conf->get_conf('buildflags'),
                                    store   => \$buildflags },
            skiptest        => {    default => $conf->get_conf('skiptest'),
                                    store   => \$skiptest },
            prereq_target   => {    default => '', store => \$prereq_target },
            prereq_format   => {    default => '', store   => \$prereq_format },
            prereq_build    => {    default => 0, store => \$prereq_build },    

        };

        $args = check( $tmpl, \%hash ) or return;
    }

    if( -d $input ){
        chdir( $input ) or die "Couldn't cd to $input\n";
    }

    my $mod = CPANPLUS::Module::Fake->new(
                module  => 'Foo',
                path    => '',
                author  => CPANPLUS::Module::Author::Fake->new,
                package => 'fake-1.1.tgz',
                # _id     => $cpan->_id,
            );
    $mod->status->fetch( 1 );
    $mod->status->extract( '.' );
    my $dist    = $mod->dist( target => 'prepare' );
    my $prereqs = $mod->status->prereqs;

    my $ok = $dist->_resolve_prereqs(
            force           => $force,
            format          => $prereq_format,
            verbose         => $verbose,
            prereqs         => $mod->status->prereqs,
            target          => $prereq_target,
            prereq_build    => $prereq_build,
            );

    # print Dumper $dist, $mod;

    return;
}

sub install_prereqs_help {
    return "    /prereqs [DIR]        # Install any missing prerequisites\n".
           "                          # listed in the Build.PL or Makefile.PL\n".
           "        DIR               # Assumes . if no DIR specified\n";

}

1;

__END__

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CPANPLUS::Shell::Default::Plugin::Prereqs - Plugin for CPANPLUS to automate
the installation of prerequisites without installing the module

=head1 SYNOPSIS

  use CPANPLUS::Shell::Default::Plugin::Prereqs;
  
  cpanp /prereqs [dir]

=head1 DESCRIPTION

A plugin for CPANPLUS's default shell which will install any missing
prerequisites for an unpacked module. Assumes the current directory
if no directory is specified.

=head1 SEE ALSO

C<CPANPLUS>, C<CPANPLUS::Shell::Default::Plugins::HOWTO>

=head1 AUTHOR

Mark Grimes, E<lt>mgrimes@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by mgrimes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
