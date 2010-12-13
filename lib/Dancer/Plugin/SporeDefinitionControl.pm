package Dancer::Plugin::SporeDefinitionControl;

use warnings;
use strict;

use Dancer ':syntax';
use Dancer::Plugin;
use YAML qw/LoadFile DumpFile/;
use File::Spec;

=head1 NAME

Dancer::Plugin::SporeDefinitionControl

Dancer Plugin to control validity of route from a Spore configuration file

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

to use it, you need to install this version of Dancer :
  - https://github.com/kolok/Dancer

or apply this patch on a git version :
  - https://github.com/kolok/Dancer/commit/b6c45ea908f8784a9d3e0764c5d4112a8e80bfac
  - https://github.com/kolok/Dancer/commit/cb7ed40802630e0fb2d73e3482292398f8a6854c
  - https://github.com/kolok/Dancer/commit/941630a890d35312f36ada60b42d2a53d5fcbe75
  - https://github.com/kolok/Dancer/commit/9d9949101f624d0d506bd183f0070133d4bb74ee

in your Dancer project use this plugin and register  :

    package MyDancer::Server;

    use Dancer::Plugin::SporeDefinitionControl;

    check_spore_definition();

=head1 INITIALISATION

=cut

#Load definition spore file from plugin config
my $path_to_spore_def = plugin_setting->{'spore_spec_path'};
$path_to_spore_def = File::Spec->catfile( setting('appdir') , $path_to_spore_def) unless (File::Spec->file_name_is_absolute($path_to_spore_def));
my $rh_file = LoadFile($path_to_spore_def);

#load validation hash
my $rh_path_validation = {};
foreach my $method_name (keys(%{$rh_file->{'methods'}}))
{
  $rh_path_validation->{$rh_file->{'methods'}->{$method_name}->{'method'}}->{$rh_file->{'methods'}->{$method_name}->{'path'}} = 
  {
    required_params => $rh_file->{'methods'}->{$method_name}->{'required_params'},
    optional_params => $rh_file->{'methods'}->{$method_name}->{'optional_params'},
  };
}

=head1 SUBROUTINES/METHODS

=head2 check_spore_definition

define spore validation to do on entered request

=cut

register 'check_spore_definition' => sub {
    before sub {
        my $req = request;
        my %req_params = params;
        return unless (defined( $req->method() ) );
        return unless (defined( $req->route_pattern() ) );
        return unless (defined( $rh_path_validation->{$req->method()} ) );
        return unless (defined( $rh_path_validation->{$req->method()}->{$req->route_pattern()} ) );
        my $ra_required_params = $rh_path_validation->{$req->method()}->{$req->route_pattern()}->{'required_params'};
        my $ra_optional_params = $rh_path_validation->{$req->method()}->{$req->route_pattern()}->{'optional_params'};
        # check if required params are present
        foreach my $required_param (@{$ra_required_params})
        {
          return halt(send_error("required params `$required_param' is not defined",
              400)) if (!defined params->{$required_param});
        }
        my @list_total = ('format');
        @list_total = (@list_total, @{$ra_required_params}) if defined($ra_required_params);
        @list_total = (@list_total, @{$ra_optional_params}) if defined($ra_optional_params);
        # check for each params if they are specified in spore spec
        foreach my $param (keys %req_params)
        {
          return halt(send_error("parameter `$param' is unknow",
              400)) if (!(grep {/^$param$/} @list_total));
        }
      };
};



=head1 AUTHOR

Nicolas Oudard, C<< <nicolas at oudard.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dancer-plugin-sporedefinitioncontrol at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dancer-Plugin-SporeDefinitionControl>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Plugin::SporeDefinitionControl


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dancer-Plugin-SporeDefinitionControl>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dancer-Plugin-SporeDefinitionControl>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dancer-Plugin-SporeDefinitionControl>

=item * Search CPAN

L<http://search.cpan.org/dist/Dancer-Plugin-SporeDefinitionControl/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Nicolas Oudard.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

register_plugin;
1; # End of Dancer::Plugin::SporeDefinitionControl
