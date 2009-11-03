# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# EasyMacroPlugin is Copyright (C) 2008 Foswiki Contributors. 
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
package Foswiki::Plugins::EasyMacroPlugin;

use strict;
use Foswiki ();
use Foswiki::Func ();
use Foswiki::Attrs ();

our $VERSION = '$Rev$';
our $RELEASE = '1.1';
our $SHORTDESCRIPTION = 'Write %MACROS in pure topic markup language';
our $NO_PREFS_IN_TOPIC = 1;
our $baseWeb;
our $baseTopic;
our $doneInit;

###############################################################################
sub initPlugin {
  ($baseTopic, $baseWeb) = @_;

  Foswiki::Func::registerTagHandler('REGISTERMACRO', \&registerMacroHandler);
  $doneInit = 0;
  return 1;
}

###############################################################################
sub beforeCommonTagsHandler {

  return if $doneInit;
  $doneInit = 1;

  # process EASYMACROS preference
  my $easyMacros = Foswiki::Func::getPreferencesValue('EASYMACROS') || '';
  my $tmlFormat = $Foswiki::cfg{EasyMacroPlugin}{Registration} ||
    '%INCLUDE{"$topic" section="registration" warn="off"}%';

  my $tml = '';
  foreach my $topic (split(/\s*,\s*/, $easyMacros)) {
    my $line = $tmlFormat;
    $line =~ s/\$topic/$topic/g;
    $tml .= $line;
  }

  Foswiki::Func::expandCommonVariables($tml, $baseTopic, $baseWeb)
    if $tml;
}

###############################################################################
sub registerMacroHandler {
  my ($session, $params, $topic, $web) = @_;

  my $theName = $params->{_DEFAULT};
  my $theWarn = $params->{warn} || 'on';
  return '' unless $theName;

  # check if it is already a known macro
  if (defined($Foswiki::functionTags{$theName}) || 
      defined(Foswiki::Func::getPreferencesValue($theName))) {
    return '' if $theWarn ne 'on';
    return "<span class='foswikiAlert'>ERROR: can't redefine $theName</span>";
  }

  my $theFormat = $params->{format};
  my $theDefaultParam = $params->{param};
  delete $params->{format};
  delete $params->{param};
  delete $params->{warn};

  if ($theFormat) {    # format mode
    $theFormat = Foswiki::Func::decodeFormatTokens($theFormat);

    # register markup using a closure handler
    Foswiki::Func::registerTagHandler(
      $theName,
      sub {
        shift;
        my $innerParams = shift;

        # merge
        if ($theDefaultParam && !defined($innerParams->{$theDefaultParam})) {
          $innerParams->{$theDefaultParam} = $innerParams->{_DEFAULT}
            || $params->{$theDefaultParam};
        }
        $innerParams = { %$params, %$innerParams };

        my $line = $theFormat;
        foreach my $key (keys %$innerParams) {
          next
            if $key eq $Foswiki::Attrs::ERRORKEY
              || $key eq $Foswiki::Attrs::RAWKEY
              || $key eq $Foswiki::Attrs::DEFAULTKEY;
          my $val = $$innerParams{$key} || '';
          $line =~ s/\$$key\b/$val/g;
        }

        return $line;
      }
    );

  } else {    # topic mode
    my $theTopic = $params->{topic} || $topic;
    my $theWeb = $params->{web} || $web;
    delete $params->{topic};
    delete $params->{web};

    ($theWeb, $theTopic) = Foswiki::Func::normalizeWebTopicName($theWeb, $theTopic);

    my $executeFormat = $Foswiki::cfg{EasyMacroPlugin}{Execute}
      || '%INCLUDE{"$topic" warn="off" $params}%';

    # register markup using a closure handler
    Foswiki::Func::registerTagHandler(
      $theName,
      sub {
        shift;
        my $innerParams = shift;

        # SMELL: Foswiki::Attrs should have a merge
        if ($theDefaultParam && !defined($innerParams->{$theDefaultParam})) {
          $innerParams->{$theDefaultParam} = $innerParams->{_DEFAULT}
            || $params->{$theDefaultParam};
        }

        $innerParams = bless({ %$params, %$innerParams }, 'Foswiki::Attrs');
        $innerParams = $innerParams->stringify;

        my $tml = $executeFormat;
        $tml =~ s/\$web/$theWeb/g;
        $tml =~ s/\$topic/$theTopic/g;
        $tml =~ s/\$params/$innerParams/g;
        return $tml;
      }
    );
  }

  return '';
}

1;
