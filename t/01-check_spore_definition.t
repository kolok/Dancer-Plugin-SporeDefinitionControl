#!perl

use Test::More tests => 20, import => ["!pass"];

use Dancer;
use Dancer::Test;

BEGIN {
  set plugins => {
    SporeDefinitionControl => {
      spore_spec_path => "sample_route.yaml",
    },
  };
}

use t::lib::WebService;

my $params1  = { params => {name_object => 'test_result'} };
my $params2  = { params => {name_object => 'test_result', created_at => '2010-10-10'} };
my $params3  = { params => {name_object => 'test_result', created_at => '2010-10-10', test => 'test_result'} };

response_status_is ['GET' => '/object/12'], 400, "GET required param is missing";
response_status_is ['GET' => '/object/12', $params1], 200, "GET only required params";
response_status_is ['GET' => '/object/12', $params2], 200, "GET required and optional params";
response_status_is ['GET' => '/object/12', $params3], 400, "GET unknown params";
response_status_is ['GET' => '/nimportequoi/12', $params1], 400, "GET route pattern is not defined";

response_status_is ['POST' => '/object'], 400, "POST required param is missing";
response_status_is ['POST' => '/object', $params1 ], 200, "POST required param is set";
response_status_is ['POST' => '/object', $params2 ], 200, "POST required and optional params";
response_status_is ['POST' => '/object', $params3], 400, "POST unknown params";
response_status_is ['POST' => '/nimportequoi', $params1], 400, "POST route pattern is not defined";

response_status_is ['PUT' => '/object/12'], 400, "PUT required param is missing";
response_status_is ['PUT' => '/object/12', $params1], 200, "PUT only required params";
response_status_is ['PUT' => '/object/12', $params2], 200, "PUT required and optional params";
response_status_is ['PUT' => '/object/12', $params3], 400, "PUT unknown params";
response_status_is ['PUT' => '/nimportequoi/12', $params1], 400, "PUT route pattern is not defined";

response_status_is ['DELETE' => '/object/12'], 400, "DELETE required param is missing";
response_status_is ['DELETE' => '/object/12', $params1], 200, "DELETE only required params";
response_status_is ['DELETE' => '/object/12', $params2], 200, "DELETE required and optional params";
response_status_is ['DELETE' => '/object/12', $params3], 400, "DELETE unknown params";
response_status_is ['DELETE' => '/nimportequoi/12', $params1], 400, "DELETE route pattern is not defined";
