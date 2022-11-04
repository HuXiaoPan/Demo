package perl::Test;

use strict;
use warnings;
use File::Basename;
use File::Spec;
use Cwd;
use Env;

BEGIN # perl module begin function.
{
    require Exporter;
    our @ISA = qw(Exporter);
    our @EXPORT = qw(func1);

    our $PROJECT_VER = "0.0.1";
    print("package name:" . __PACKAGE__. " file name:" .__FILE__. " line number:" .__LINE__. " project version:" .$PROJECT_VER."\n");
}

my $CMAKE_VERSION_MAJOR;
my $CMAKE_VERSION_MINOR;
my $CMAKE_VERSION_PATCH;

sub func1
{
    my $CMAKE_VERSION = `cmake --version`;
    ($CMAKE_VERSION_MAJOR, $CMAKE_VERSION_MINOR, $CMAKE_VERSION_PATCH) = ( $CMAKE_VERSION =~ /cmake version ([0-9]+)\.([0-9]+)\.([0-9]+)/ );
    ($CMAKE_VERSION_MAJOR ne "") || die "cannot determine cmake major version";
    ($CMAKE_VERSION_MINOR ne "") || die "cannot determine cmake minor version";
    ($CMAKE_VERSION_PATCH ne "") || die "cannot determine cmake patch version";

    print(dirname(File::Spec->rel2abs( $0 , getcwd_w_symlink() )));
    
}

sub getcwd_w_symlink
{
   my $CWD = Cwd::getcwd();
   if (defined($ENV{PWD}) && $ENV{PWD} ne $CWD)
   {
      my $e = my ($e_dev, $e_node) = stat($ENV{PWD});
      my $c = my ($c_dev, $c_node) = stat($CWD);
      if ($e && $c && $e_dev == $c_dev && $e_node == $c_node)
      {
         $CWD = $ENV{PWD};
      }
   }

   return $CWD;
}

1; #perl module return true.