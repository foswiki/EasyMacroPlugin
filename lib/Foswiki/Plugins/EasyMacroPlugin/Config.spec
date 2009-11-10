# ---+ Extensions
# ---++ EasyMacroPlugin

# **STRING**
# Template to register easy macros. This is used to parse the
# EASYMACROS preference variable. The list of topics is processed
# using this template each where the string <code>$topic</code> is replaced with
# the found topic. A sensible alternative would be to use DBCALL instead of INCLUDE in
# case you installed the Foswiki:Extensions/DBCachePlugin
$Foswiki::cfg{EasyMacroPlugin}{Registration} = '%INCLUDE{"$web.$topic" section="registration" warn="off"}%';

# **STRING**
# Template to execute an easy macros. The handler of an easy-macro is executed using this snippet of topic markup.
# The topic implementing this macro is provided via the <code>$topic</code> string; the parameters
# are inserted at the <code>$params</code> position. A sensible alternative would be to use DBCALL instead of INCLUDE in
# case you installed the Foswiki:Extensions/DBCachePlugin
$Foswiki::cfg{EasyMacroPlugin}{Execute} = '%INCLUDE{"$web.$topic" warn="off" $params}%';

1;

