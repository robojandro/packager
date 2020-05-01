package PackageHandler::Package;

use warnings;
use strict;

use Cwd;
use File::Path 'make_path';
use File::Spec;
use IO::All;
use JSON;
use Method::Signatures::Simple;
use Mouse;
use Try::Tiny;

has name => (
  is => 'ro',
  isa => 'Str',
  required => 1,
  default => ''
);

has store_path => (
  is => 'ro',
  isa => 'Str',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $pkg_files = File::Spec->catdir( cwd(), 'package_data' );
    make_path($pkg_files);
    return $pkg_files;
  }
);

has dependencies_path => (
  is => 'ro',
  isa => 'Str',
  lazy => 1,
  default => sub {
    my $self = shift;
    return File::Spec->catfile( $self->store_path, $self->name );
  }
);

has dependencies => (
  is => 'ro',
  isa => 'ArrayRef',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $deps = [];
    if (-e $self->dependencies_path) {
      my $contents;
      try {
        $contents < io $self->dependencies_path;
        $deps = from_json($contents);
      } catch {
        printf "Error reading dependancy file for package: %s\n", $self->name;
        exit 1;
      }
    }
    return $deps;
  }
);

# we should allow for unsetting dependencies as well
# so we'll accept empty array refs to clear out previous lists
method set_dependencies($dependencies) {
  my $content = to_json($dependencies);
  $content > io $self->dependencies_path;
}

1;
