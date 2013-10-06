package DDG::Goodie::Shortcut;
# ABSTRACT: Display keyboard shortcut for an action.

use DDG::Goodie;

triggers any => 'shortcut','keyboard shortcut', 'key combination';

zci is_cached => 1;
zci answer_type => 'shortcut';

primary_example_queries 'windows show desktop shortcut';
secondary_example_queries 'ubuntu shortcut new folder', 'paste keyboard shortcut';
description 'keyboard shortcuts';
name 'Shortcut';
topics 'computing';
category 'computing_info';
attribution github => ['https://github.com/dariog88a','dariog88a'],
            email => [ 'mailto:dariog88@gmail.com', 'dariog88' ],
            twitter => ['http://twitter.com/dariog88','dariog88'];

#removes leading and trailing whitespace, and leaves just one blank between words
sub trim($) {
    my $s = shift;
    $s =~ s/ +/ /gs;
    $s =~ s/^\s+|\s+$//g; 
    return $s;
}

my @shortcuts = share('shortcuts.csv')->slurp;

handle remainder_lc => sub {
    #replace all OS words with starting char
    s/windows|win|xp|vista|seven/W/gi;
    s/mac|osx/M/gi;
    s/linux|ubuntu|debian|fedora|kde|gnome/L/gi;

    #get OS char (if any)
    my $search = $_;
    $search =~ /(W|M|L)/;
    my $os = $1; #save OS char
    $search =~ tr/[WML]//d; #remove all OS chars from search
    $search = trim($search);

    my $line;
    foreach (@shortcuts) {
        if($_ =~ /^$search/i) { #matches only the start
            $line = $_;
            last;
        }
    }

    #return if no row was found
    if (!defined $line) { return; }
    my @columns = split('\|',$line);

    my %systems = (W=>'Windows',M=>'Mac OS',L=>'KDE/GNOME');
    my $answer = 'The shortcut for ' . $columns[0];
    my $keys;

if(!$os) {$os='';} #line added to avoid error, remove when UA detection added.

    #get the column content for the searched OS
    if ($os eq 'W') {
        $keys = $columns[1];
    } elsif ($os eq 'M') {
        $keys = $columns[2];
    } elsif ($os eq 'L') {
        $keys = $columns[3];
        $keys =~ s/\R//g; #remove line break
    }

    #return if the column is empty
    if (!$keys) { return; }

    if ($os) { $answer .= ' in ' . $systems{$os} . ' is ' . $keys; }

    my $source = "\n" . '<a href="https://en.wikipedia.org/wiki/Table_of_keyboard_shortcuts">More at Wikipedia</a>';
    return $answer, html => "$answer $source";
};

1;
