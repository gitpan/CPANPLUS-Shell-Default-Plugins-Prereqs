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
use File::Basename qw[basename];
use CPANPLUS::Internals::Constants;

use Carp;
use Data::Dumper;

our $VERSION = '0.04_01';

sub plugins { (
            prereqs => 'install_prereqs',
        ) };

sub install_prereqs {
    my $class   = shift;        # CPANPLUS::Shell::Default::Plugins::Prereqs
    my $shell   = shift;        # CPANPLUS::Shell::Default object
    my $cb      = shift;        # CPANPLUS::Backend object
    my $cmd     = shift;        # 'prereqs'
    my $input   = shift;        # show|list|install [dirname]
    my $opts    = shift || {};  # { foo => 0, bar => 2 }

    ### get the operation and possble target dir.
    my( $op, $dir ) = split /\s+/, $input, 2;

    ### you want us to install, or just list?
    my $install     = {
        list    => 0,
        show    => 0,
        install => 1,
    }->{ lc $op };
    
    ### you passed an unknown operation
    unless( defined $install ) {
        print __PACKAGE__->install_prereqs_help;
        return;
    }        

    ### get the absolute path to the directory
    $dir    = File::Spec->rel2abs( defined $dir ? $dir : '.' );
    
    my $mod = CPANPLUS::Module::Fake->new(
                module  => basename( $dir ),
                path    => $dir,
                author  => CPANPLUS::Module::Author::Fake->new,
                package => basename( $dir ),
            );

    ### set the fetch & extract targets, so we know where to look
    $mod->status->fetch(   $dir );
    $mod->status->extract( $dir );

    ### figure out whether this module uses EU::MM or Module::Build
    ### do this manually, as we're setting the extract location ourselves.
    $mod->get_installer_type or return;

    ### run 'perl Makefile.PL' or 'M::B->new_from_context' to find the prereqs.
    $mod->prepare( %$opts ) or return;

    ### prepare will list/show any missing prereqs, so exit if we are done
    return unless $install;

    ### get the list of prereqs
    my $href = $mod->status->prereqs or return;
 
    ### list and/or install the prereqs
    while( my($name, $version) = each %$href ) {
    
        ### no such module
        my $obj = $cb->module_tree( $name ) or 
            print "Prerequisite '$name' was not found on CPAN\n" and
            next;
    
        ### we already have this version or better installed
        next if $obj->is_uptodate( version => $version );
     
        ### install it
        $obj->install( %$opts );
    }

    return;
}

sub install_prereqs_help {
    return "    /prereqs <cmd> [DIR]  # Install missing prereqs from Build.PL\n" .
           "                          # of Makefile.PL in the DIR directory\n" .
           "        <cmd>  =>  show|list|install\n".
           "        [DIR]      Defaults to .\n";

}

1;

__END__

=head1 NAME

CPANPLUS::Shell::Default::Plugin::Prereqs - Plugin for CPANPLUS to automate
the installation of prerequisites without installing the module

=head1 SYNOPSIS

  use CPANPLUS::Shell::Default::Plugin::Prereqs;
  
  cpanp /prereqs <show|list|install> [dir]

=head1 DESCRIPTION

A plugin for CPANPLUS's default shell which will display and/or install any
missing prerequisites for an unpacked module. Assumes the current directory if
no directory is specified.

=head1 SEE ALSO

C<CPANPLUS>, C<CPANPLUS::Shell::Default::Plugins::HOWTO>

=head1 AUTHOR

Mark Grimes, E<lt>mgrimes@cpan.orgE<gt>

=head1 THANKS

Thanks to Jos Boumans for his excellent suggestions to improve both the plugin
functionality and the quality of the code.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by mgrimes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
