package PackageHandler;

use warnings;
use strict;

use Method::Signatures::Simple;
use Mouse;

use PackageHandler::Node;
use PackageHandler::Package;

has action => (
  is => 'ro',
  isa => 'Str',
  required => 1,
  default => 'end'
);

has package => (
  is => 'ro',
  isa => 'Str',
  default => ''
);

has dependencies => (
  is => 'ro',
  isa => 'ArrayRef',
  default => sub { [] } 
);

method route {
  my $normalized = lc($self->action);
  if ($normalized eq 'depend') {
    my $package = PackageHandler::Package->new({ name => $self->package });
    $package->set_dependencies($self->dependencies);
  } elsif ($normalized eq 'requires') {
    my $package = PackageHandler::Package->new({ name => $self->package });
    foreach my $package (@{ $package->dependencies }) {
      print "$package\n";
    }
  } else {
    my $node = new PackageHandler::Node;
    if ($normalized eq 'install') {
      $node->install($self->package);
    } elsif ($normalized eq 'remove') {
      $node->remove($self->package);
    } elsif ($normalized eq 'list') {
      $node->list;
    } elsif ($normalized eq 'end') {
      exit 0;
    }
  }
}

1;
