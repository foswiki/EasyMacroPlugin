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

# **BOOLEAN**
# Persistent macros. When there are only global easy-macros defined via SitePreferenes then you can enable this flag
# for a bit of extra performance on persistent-perl environments (e.g. mod_perl, fastcgi). Once an easy-macro is 
# registered it will remain in memory for the lifetime of the perl backend. Leave it disabled if unsure.
$Foswiki::cfg{EasyMacroPlugin}{PersistentMacros} = 0;

1;

