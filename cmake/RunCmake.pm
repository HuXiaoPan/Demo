# THIS PERL MODULE IS MEANT TO BE INCLUDED ONLY. It can not be run standalone!
# Usage: Place a file named 'run_cmake.pl' in your project root folder with follwing content:
# -----------------------------
# #!/usr/bin/perl
# # Usage: run_cmake.pl [cmake options]
# # cmake options: Usually not needed. Intended for debugging e.g. --trace --debug-output
# use cmake::RunCmake;
# run_cmake();
# -----------------------------

# History
# Author     | Ver  | Comment
# -----------+------+----------------------------------------
# M.Kindel   | 1.00 | module created from run_cmake.pl
#            |      | - forward all arguments to cmake call
#            |      | - choose default generator only when -G isn't given
#            |      | - detect VS10 and VS11
# M.Kindel   | 1.01 | fixed wrong x-build folder when used within symlinked folders on linux
# S.Lohse    | 1.2  | Added support for Visual Studio 2013 (VS12). To use the feature, you need a quite recent cmake. Version 2.8.12 worked fine for me.
# M.Kindel   | 1.3  | Added default setting for CMAKE_INSTALL_PREFIX
# S.Lohse    | 1.4  | complete overhaul to make compatible with cmake >3.0.0 (which changed all generator names), added VS14 support
# S.Lohse    | 1.5  | added VS15 support
# S.Lohse    | 1.6  | previously, the build folder only was named ...-build, now it contains the IDE and Debug/Release in its folder name, e.g. edna-build-vs14-release

package cmake::RunCmake;
use 5.008_000;
use strict;
use warnings;

# to make this a real perl module:
BEGIN
{
   require Exporter;

    # set the version for version checking
   our $VERSION = 1.6;

   # Inherit from Exporter to export functions and variables
   our @ISA= qw( Exporter );

   # Functions and variables which can be (optionally) exported
   our @EXPORT_OK = qw( run_cmake );

   # Functions and variables which are exported by default
   our @EXPORT = qw( run_cmake );
}

use File::Basename;
use File::Spec;
use Env;
use Cwd;

my $CMAKE_VERSION_MAJOR;
my $CMAKE_VERSION_MINOR;
my $CMAKE_VERSION_PATCH;

sub run_cmake
{
   my $CMAKE_VERSION = `cmake --version`;
   ($CMAKE_VERSION_MAJOR, $CMAKE_VERSION_MINOR, $CMAKE_VERSION_PATCH) = ( $CMAKE_VERSION =~ /cmake version ([0-9]+)\.([0-9]+)\.([0-9]+)/ );
   ($CMAKE_VERSION_MAJOR ne "") || die "cannot determine cmake major version";
   ($CMAKE_VERSION_MINOR ne "") || die "cannot determine cmake minor version";
   ($CMAKE_VERSION_PATCH ne "") || die "cannot determine cmake patch version";

   my $INPUTFOLDER = dirname(File::Spec->rel2abs( $0, getcwd_w_symlink() ));

   my ($GENERATOR_WAS_GIVEN, $GENERATOR, $GENERATOR_SHORT) = getCmakeGenerator();
   my ($BUILDTYPE_WAS_GIVEN, $CMAKE_BUILD_TYPE)            = getCMAKE_BUILD_TYPE();

   my $SUFFIX = "-" . $GENERATOR_SHORT . "-" . $CMAKE_BUILD_TYPE;
   $SUFFIX = lc $SUFFIX;

   my $BUILD_FOLDER         = $INPUTFOLDER . "-build"   . $SUFFIX; # default folder for build output => out-of-source build!
   my $INSTALL_FOLDER       = $INPUTFOLDER . "-install" . $SUFFIX; # default for CMAKE_INSTALL_PREFIX => output of cmake's INSTALL target
   my $CMAKE_INSTALL_PREFIX = getCMAKE_INSTALL_PREFIX( $INSTALL_FOLDER );

   # check if we need a toolchain file for cross-compilation
   my $TOOLCHAIN = getToolchainFile();

   # prepare the build folder
   unless(-d $BUILD_FOLDER)
   {
      mkdir($BUILD_FOLDER, 0777) || die "cannot create output folder";
   }

   chdir $BUILD_FOLDER;

   # Ensure ARGV arguments with whitespaces e.g. "Visual Studio 10" are surrounded by quotes "
   my @ARGV_QUOTED = map { /\s/ ? '"' . $_ . '"' : $_ } @ARGV;

   my $CMAKE_COMMANDLINE = "cmake";
   if(!$GENERATOR_WAS_GIVEN)
   {
      $CMAKE_COMMANDLINE = $CMAKE_COMMANDLINE . " " . "-G \"$GENERATOR\"";
   }
   if(!$BUILDTYPE_WAS_GIVEN)
   {
      $CMAKE_COMMANDLINE = $CMAKE_COMMANDLINE . " " . "-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE";
   }
   # TODO treat CMAKE_INSTALL_PREFIX here the same way as GENERATOR and CMAKE_BUILD_TYPE
   $CMAKE_COMMANDLINE    = $CMAKE_COMMANDLINE . " " . "$CMAKE_INSTALL_PREFIX $TOOLCHAIN @ARGV_QUOTED \"$INPUTFOLDER\"";
   print "$CMAKE_COMMANDLINE\n\n";
   if (system($CMAKE_COMMANDLINE) != 0)
   {
      # don't close the command window (right away) if there is an error
      # (inifinite blocking might be a problem on buildbot automated execution of this script)
      print "There is an ERROR!!! This window closes in 10 seconds.";
      $|++; # autoflush STDOUT
      sleep(300); # wait max 5 minutes (to not block automated builds) so a human can see the error
   }
}


sub getToolchainFile
{
   if (defined($ENV{OECORE_NATIVE_SYSROOT})) # Check if we are compiling for NAIP
   {
      return "-DCMAKE_TOOLCHAIN_FILE=" . $ENV{OECORE_NATIVE_SYSROOT} . "/usr/share/cmake/OEToolchainConfig.cmake"
   }
   else
   {
      return ""
   }
}

# Cwd always resolves the symlinks and returns the real path where the symlink points to.
# But we need the path as the shell knows it (with symlinks intact).
# This code is from: http://www.perlmonks.org/?node_id=886883
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


my $IS_WINDOWS = undef; # cache result of calculation
# Checks if script is run on windows OS.
sub isWindows
{
   if( defined($IS_WINDOWS) )
   {
      return $IS_WINDOWS;
   }
   else
   {
      return $IS_WINDOWS = ( defined($ENV{'OS'}) && $ENV{'OS'} eq "Windows_NT" );
   }
}


# For internal use only.
# Returns a string pair:
# - a suitable default -G cmake option if no such has been specified
# - a brief shorthand string of that, suitable for example for output directory suffixes
sub getCmakeGenerator
{
   my $GENERATOR_WAS_GIVEN = 0;
   my $GENERATOR_SHORT = undef;
   for(my $i = 0; $i <= $#ARGV; $i++)
   {
      #print "argument $i = $ARGV[$i]\n";
      if($ARGV[$i] eq "-G")
      {
         $GENERATOR_WAS_GIVEN = 1;
         $i++;
         $i<=$#ARGV || die "command line syntax error: option -G expects a parameter";
         #print "argument $i = $ARGV[$i]\n";

         if(   ($ARGV[$i] eq   "Visual Studio 15 2017"  ) ||     # cmake >= 3.7.1
               ($ARGV[$i] eq "\"Visual Studio 15 2017\"")  )     # cmake >= 3.7.1
         {
            $GENERATOR_SHORT = "vs15";
         }
         elsif(($ARGV[$i] eq   "Visual Studio 14 2015"  ) ||     # cmake >= 3.4.3
               ($ARGV[$i] eq "\"Visual Studio 14 2015\"")  )     # cmake >= 3.4.3
         {
            $GENERATOR_SHORT = "vs14";
         }
         elsif(($ARGV[$i] eq   "Visual Studio 12 2013"  ) ||     # cmake >= 3.0.0
               ($ARGV[$i] eq "\"Visual Studio 12 2013\"") ||     # cmake >= 3.0.0
               ($ARGV[$i] eq   "Visual Studio 12"       ) ||     # cmake <  3.0.0
               ($ARGV[$i] eq "\"Visual Studio 12\""     )  )     # cmake <  3.0.0
         {
            $GENERATOR_SHORT = "vs12";
         }
         elsif(($ARGV[$i] eq   "Visual Studio 11 2012"  ) ||     # cmake >= 3.0.0
               ($ARGV[$i] eq "\"Visual Studio 11 2012\"") ||     # cmake >= 3.0.0
               ($ARGV[$i] eq   "Visual Studio 11"       ) ||     # cmake <  3.0.0
               ($ARGV[$i] eq "\"Visual Studio 11\""     )  )     # cmake <  3.0.0
         {
            $GENERATOR_SHORT = "vs11";
         }
         elsif(($ARGV[$i] eq   "Visual Studio 10 2010"  ) ||     # cmake >= 3.0.0
               ($ARGV[$i] eq "\"Visual Studio 10 2010\"") ||     # cmake >= 3.0.0
               ($ARGV[$i] eq   "Visual Studio 10"       ) ||     # cmake <  3.0.0
               ($ARGV[$i] eq "\"Visual Studio 10\""     )  )     # cmake <  3.0.0
         {
            $GENERATOR_SHORT = "vs10";
         }
         elsif(($ARGV[$i] eq   "Unix Makefiles"  ) ||
               ($ARGV[$i] eq "\"Unix Makefiles\"")  )
         {
            $GENERATOR_SHORT = "make";
         }
         else
         {
            die "invalid argument for -G option";
         }
      }
   }

   if(!$GENERATOR_SHORT)
   {
      if(!isWindows())
      {
         $GENERATOR_SHORT = "make";
      }
      elsif( -d File::Spec->catfile($ENV{'ProgramFiles'},      "Microsoft Visual Studio\\2017")
          || -d File::Spec->catfile($ENV{'ProgramFiles(x86)'}, "Microsoft Visual Studio\\2017") )
      {
         $GENERATOR_SHORT = "vs15";
      }
      elsif( -d File::Spec->catfile($ENV{'ProgramFiles'},      "Microsoft Visual Studio 14.0")
          || -d File::Spec->catfile($ENV{'ProgramFiles(x86)'}, "Microsoft Visual Studio 14.0") )
      {
         $GENERATOR_SHORT = "vs14";
      }
      elsif( -d File::Spec->catfile($ENV{'ProgramFiles'},      "Microsoft Visual Studio 12.0")
          || -d File::Spec->catfile($ENV{'ProgramFiles(x86)'}, "Microsoft Visual Studio 12.0") )
      {
         $GENERATOR_SHORT = "vs12";
      }
      elsif( -d File::Spec->catfile($ENV{'ProgramFiles'},      "Microsoft Visual Studio 11.0")
          || -d File::Spec->catfile($ENV{'ProgramFiles(x86)'}, "Microsoft Visual Studio 11.0") )
      {
         $GENERATOR_SHORT = "vs11";
      }
      elsif( -d File::Spec->catfile($ENV{'ProgramFiles'},      "Microsoft Visual Studio 10.0")
          || -d File::Spec->catfile($ENV{'ProgramFiles(x86)'}, "Microsoft Visual Studio 10.0") )
      {
         $GENERATOR_SHORT = "vs10";
      }
      else
      {
         die "could not find a suitable default build process";
      }
   }

   my $GENERATOR = undef;
   if($GENERATOR_SHORT eq "vs15")
   {
      $CMAKE_VERSION_MAJOR>=3       || die "cmake 3.7.1 or higher required, please upgrade";
      if($CMAKE_VERSION_MAJOR==3)
      {
         $CMAKE_VERSION_MINOR>=7    || die "cmake 3.7.1 or higher required, please upgrade";
         if($CMAKE_VERSION_MINOR==7)
         {
            $CMAKE_VERSION_PATCH>=1 || die "cmake 3.7.1 or higher required, please upgrade";
         }
      }
      $GENERATOR = "Visual Studio 15 2017";
   }  
   elsif($GENERATOR_SHORT eq "vs14")
   {
      $CMAKE_VERSION_MAJOR>=3       || die "cmake 3.4.3 or higher required, please upgrade";
      if($CMAKE_VERSION_MAJOR==3)
      {
         $CMAKE_VERSION_MINOR>=4    || die "cmake 3.4.3 or higher required, please upgrade";
         if($CMAKE_VERSION_MINOR==4)
         {
            $CMAKE_VERSION_PATCH>=3 || die "cmake 3.4.3 or higher required, please upgrade";
         }
      }
      $GENERATOR = "Visual Studio 14 2015";
   }
   elsif($GENERATOR_SHORT eq "vs12")
   {
      if($CMAKE_VERSION_MAJOR>=3)
      {
         $GENERATOR = "Visual Studio 12 2013";
      }
      else
      {
         $GENERATOR = "Visual Studio 12";
      }
   }
   elsif($GENERATOR_SHORT eq "vs11")
   {
      if($CMAKE_VERSION_MAJOR>=3)
      {
         $GENERATOR = "Visual Studio 11 2012";
      }
      else
      {
         $GENERATOR = "Visual Studio 11";
      }
   }
   elsif($GENERATOR_SHORT eq "vs10")
   {
      if($CMAKE_VERSION_MAJOR>=3)
      {
         $GENERATOR = "Visual Studio 10 2010";
      }
      else
      {
         $GENERATOR = "Visual Studio 10";
      }
   }
   elsif($GENERATOR_SHORT eq "make")
   {
      $GENERATOR = "Unix Makefiles";
   }
   else
   {
      die "unknown generator";
   }

   return ($GENERATOR_WAS_GIVEN, $GENERATOR, $GENERATOR_SHORT);
}


# For internal use only.
# Provides default CMAKE_INSTALL_PREFIX if none has been explicitly specified.
# Returned string can directly be added to cmake command line
sub getCMAKE_INSTALL_PREFIX
{
   # first and only parameter: install folder path. Surround with quotes if path contains whitespace.
   my $INSTALL_FOLDER = join(" ", @_);
   $INSTALL_FOLDER = ($INSTALL_FOLDER =~ /\s/ ? '"' . $INSTALL_FOLDER . '"' : $INSTALL_FOLDER);

   my $CMAKE_INSTALL_PREFIX = "";

   # Has CMAKE_INSTALL_PREFIX been given as argument?
   # Note: This check is lazy, it doesn't check for -D and if CMAKE_INSTALL_PREFIX is only part of a larger word.
   # We think it is very unlikely that will become a problem as the name is unique and it is hard to imagine that will change.
   my $found = map { /CMAKE_INSTALL_PREFIX/ } @ARGV; # TODO make this more robust like it's done in getCMAKE_BUILD_TYPE() ?
   if( !$found )
   {
      $CMAKE_INSTALL_PREFIX = "-D CMAKE_INSTALL_PREFIX=$INSTALL_FOLDER" ;
   }

   return $CMAKE_INSTALL_PREFIX;
}

# possible values: Debug, Release, RelWithDebInfo, MinSizeRel
# cf. https://cmake.org/cmake/help/v3.0/variable/CMAKE_BUILD_TYPE.html
sub getCMAKE_BUILD_TYPE
{
   my $CMAKE_BUILD_TYPE = "Debug"; # fallback default
   my $BUILDTYPE_WAS_GIVEN = 0;

   for(my $i = 0; $i <= $#ARGV; $i++)
   {
      #print "argument $i = $ARGV[$i]\n";
      if($ARGV[$i] =~ m/-DCMAKE_BUILD_TYPE=(.*)/)
      {
         $CMAKE_BUILD_TYPE = $1;
         $BUILDTYPE_WAS_GIVEN = 1;
      }
      elsif($ARGV[$i] eq "-D")
      {
         $i++;
         $i<=$#ARGV || die "command line syntax error: option -D expects a parameter";
         #print "argument $i = $ARGV[$i]\n";
         if($ARGV[$i] =~ m/CMAKE_BUILD_TYPE=(.*)/)
         {
            $CMAKE_BUILD_TYPE = $1;
         }
         else
         {
            die "invalid CMAKE_BUILD_TYPE argument";
         }
         $BUILDTYPE_WAS_GIVEN = 1;
      }
   }

   return ($BUILDTYPE_WAS_GIVEN, $CMAKE_BUILD_TYPE);
}

1;  # perl modules must return a true value from the file
