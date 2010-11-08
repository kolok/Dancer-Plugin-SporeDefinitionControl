package WebService;
use Dancer;
use Dancer::Plugin::SporeDefinitionControl;

check_spore_definition();

get 'object/:id.:format' => sub {
  return "get object OK";
};

1;
