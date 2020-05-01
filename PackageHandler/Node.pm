package PackageHandler::Node;

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

has installed_path => (
  is => 'ro',
  isa => 'Str',
  lazy => 1,
  default => sub { return File::Spec->catfile( cwd(), 'system_data' ) }
);

method fetch_current_installed {
  my $unserialized = [];
  if (-e $self->installed_path) {
    try {
      my $contents < io $self->installed_path;
      $unserialized = from_json($contents);
    } catch {
      print "Error reading system installation file for package\n";
      exit 1;
    }
  }
  return $unserialized;
}

method scan_for_package($package, @scan_list) {
  my $found = -1;
  for (my $index = 0; $index < scalar @scan_list; $index++) {
    if ($scan_list[$index] eq $package) {
      $found = $index;
      last;
    }
  }
  return $found;
}

method list {
  my $installed = $self->fetch_current_installed;
  foreach my $package (@$installed) {
    print "$package\n";
  }
}

method install($package, $as_dep) {
  my @installed = @{ $self->fetch_current_installed };
  my $found = $self->scan_for_package($package, @installed);
  if ($found > -1) {
    printf "%s is already installed\n", $package unless $as_dep;
    return;
  }
  else {
    my $pkg = PackageHandler::Package->new({ name => $package });
    foreach my $dependency (@{$pkg->dependencies}) {
      $self->install($dependency, 1);
      @installed = @{ $self->fetch_current_installed };
    }

    push @installed, $package;
    to_json(\@installed) > io $self->installed_path;
    printf "%s successfully installed\n", $package;
  }
}

# SPEC:
#   "Before removing a package, confirm that no other packages require it.
#   Dependent packages must be removed manually before the package can be removed."
method remove($package) {
  my @installed = @{ $self->fetch_current_installed };
  my $found = $self->scan_for_package($package, @installed);
  if ($found == -1) {
    printf "%s is not installed\n", $package;
    return;
  }
  else {
    # prevent removal if package is a dependecy of another
    my $found_as_dep = -1;
    foreach my $name (@installed) {
      my $pkg = PackageHandler::Package->new({ name => $name });
      $found_as_dep = $self->scan_for_package($package, @{$pkg->dependencies});
      if ($found_as_dep != -1) {
        printf "%s is still needed\n", $package;
        return;
      }
    }

    splice @installed, $found, 1;
    to_json(\@installed) > io $self->installed_path;
    printf "%s successfully removed\n", $package;

    my $all_still_required = {};
    foreach my $name (@installed) {
      my $pkg = PackageHandler::Package->new({ name => $name });
      foreach my $dep (@{$pkg->dependencies}) {
        $all_still_required->{$dep} = 1;
      }
    }

    # remove implicit dependencies not required by other packages
    my $removing = PackageHandler::Package->new({ name => $package });
    my $deps_removed = 0;
    foreach my $dep ( @{$removing->dependencies} ) {
      unless ( $all_still_required->{$dep} ) {
        printf "%s is no longer needed\n", $dep;
        my $index = $self->scan_for_package($dep, @installed);
        splice @installed, $index, 1;
        printf "%s successfully removed\n", $dep;
        $deps_removed = 1;
      }
    }
    to_json(\@installed) > io $self->installed_path
      if $deps_removed;
  }
}

1;

