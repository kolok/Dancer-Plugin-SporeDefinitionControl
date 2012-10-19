#!perl

use FindBin;
BEGIN { $ENV{DANCER_APPDIR} = $FindBin::Bin }

use Test::More tests => 6, import => ["!pass"];

use Dancer;
use Dancer::Test;

BEGIN {
  set environment => 'test';
  set plugins => {
    SporeDefinitionControl => {
      spore_spec_path => "sample_route.yaml",
    },
  };
}
use Dancer::Plugin::SporeDefinitionControl;
check_spore_definition();

my $method = get_method_path_method_name();
ok exists $method->{GET}, "Method with get is set in the hash";
ok exists $method->{POST}, "Method with post is set in the hash";
ok exists $method->{POST}->{'/object'}, "Method with post object is set in the hash";
is $method->{POST}->{'/object'},"create_object" , "Method with post object return create_object";
ok exists $method->{PUT}, "Method with put is set in the hash";
ok exists $method->{DELETE}, "Method with delete is set in the hash";
