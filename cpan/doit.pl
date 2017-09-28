$old = $ARGV[0];
$new = "$old.temp";
open( OLD, "< $old" ) or die "can't open $old: $!";
open( NEW, "> $new" ) or die "can't open $new: $!";
local $/ = undef;
while (<OLD>) {
    s/# VALUATOR:[^\n]*[\n]*//ms;
    print NEW $_ or die "can't write $new: $!";
}
close(OLD) or die "can't close $old: $!";
close(NEW) or die "can't close $new: $!";
rename( $old, "$old.orig" ) or die "can't rename $old to $old.orig: $!";
rename( $new, $old )        or die "can't rename $new to $old: $!";

