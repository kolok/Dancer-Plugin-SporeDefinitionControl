package Dancer::Plugin::SporeDefinitionControl;

use warnings;
use strict;

use Dancer ':syntax';
use Dancer::Plugin;
use Dancer::Plugin::REST '0.04';
use YAML qw/LoadFile DumpFile/;
use File::Spec;

=head1 NAME

Dancer::Plugin::SporeDefinitionControl

Dancer Plugin to control validity of route from a Spore configuration file

=head1 VERSION

Version 0.08

=cut

our $VERSION = '0.08';

=head1 SYNOPSIS

Dancer required version : 1.3002

in your Dancer project, use this plugin and register  :

    package MyDancer::Server;

    use Dancer::Plugin::SporeDefinitionControl;

    check_spore_definition();

In your config file :

    plugins:
      SporeDefinitionControl:
        spore_spec_path: path/to/route_config.yaml

The yaml path file can be relative (root project base) or absolute.

in your file path/to/route_config.yaml, put your SPORE config :

    base_url: http://localhost:4500
    version: 0.2
    format:
      - json
      - xml
      - yml
    methods:
      get_object:
        required_params:
          - id
          - name_object
        optional_params:
          - created_at
        path: /object/:id
        method: GET
      create_object:
        required_params:
          - name_object
        optional_params:
          - created_at
        path: /object/create
        method: POST
      update_object:
        required_params:
          - id
          - name_object
        optional_params:
          - created_at
        path: /object/:id
        method: PUT
      delete_object:
        required_params:
          - id
          - name_object
        optional_params:
          - created_at
        path: /object/:id
        method: DELETE

=head1 INITIALISATION

Load yaml config file

=cut


#Load definition spore file from plugin config
my $path_to_spore_def = plugin_setting->{'spore_spec_path'};
my $rh_file = {};
if ($path_to_spore_def)
{
$path_to_spore_def = File::Spec->catfile( setting('appdir') , $path_to_spore_def) unless (File::Spec->file_name_is_absolute($path_to_spore_def));
$rh_file = LoadFile($path_to_spore_def);
}
#load validation hash
our $rh_path_validation = {};
foreach my $method_name (keys(%{$rh_file->{'methods'}}))
{


    my $method = $rh_file->{'methods'}->{$method_name}->{'method'};
    my $complet_path = $rh_file->{'methods'}->{$method_name}->{'path'};
    my ($path, $query_params) = split(/\?/, $complet_path);
    my @additional_params;
    if (defined $query_params)
    {
        @additional_params = map { $_ =~ s/=.*//g; $_ } split( /\&/, $query_params) ;
        push @{$rh_file->{'methods'}->{$method_name}->{'required_params'}}, @additional_params;
    }


    push @{$rh_path_validation->{$method}->{$path}},
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
        die "method request must be defined" unless (defined( $req->method() ) );
        die "route pattern request must be defined" unless (defined( $req->{_route_pattern} ) );
#        my $all_route_pattern = $req->{_route_pattern};
#my $detail_route_pattern =  split /?/, $route_pattern;
        unless (defined( $rh_path_validation->{$req->method()} ) )
        {
          my $req_method = $req->method();
          return _returned_error("no route define with method `$req_method'", 404);
        }
#TODO : return an error because path does not exist in specification
        unless (defined( $rh_path_validation->{$req->method()}->{$req->{_route_pattern}} ) )
        {
          my $req_route_pattern = $req->{_route_pattern};
          return _returned_error("route pattern `$req_route_pattern' is not defined",404);
        }


        my $is_ok = 0;
        my $error;
        foreach my $route_defined (@{$rh_path_validation->{$req->method()}->{$req->{_route_pattern}}})
        {
            my $ko;
            my $ra_required_params = $route_defined->{'required_params'};
            my $ra_optional_params = $route_defined->{'optional_params'};
            # check if required params are present
            foreach my $required_param (@{$ra_required_params})
            {
                if (!defined params->{$required_param})
                {
                    $error = "required params `$required_param' is not defined";
                    $ko = 1;
                }
            }
            next if $ko;
            my @list_total = ('format');
            @list_total = (@list_total, @{$ra_required_params}) if defined($ra_required_params);
            @list_total = (@list_total, @{$ra_optional_params}) if defined($ra_optional_params);
            # check for each params if they are specified in spore spec
            foreach my $param (keys %req_params)
            {
                if (!(grep {/^$param$/} @list_total))
                {
                    $error  = "parameter `$param' is unknow";
                    $ko = 1 ;
                }
            }
            next if $ko;
            $is_ok = 1;
        }
        return _returned_error($error,400) unless $is_ok;

      };
};

sub _returned_error
{
  my $str_error = shift;
  my $code_error = shift;
  $code_error ||= 400;
  set serializer => 'JSON';
  debug $str_error."\n";
  #return halt(send_error($str_error,400));
  if ($code_error == 400)
  {
    return halt(status_bad_request($str_error));
  }
  elsif ($code_error == 404)
  {
    return halt(status_not_found($str_error));
  }
  else
  {die "Unknown code";}
}

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
