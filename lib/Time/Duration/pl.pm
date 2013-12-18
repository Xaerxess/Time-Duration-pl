package Time::Duration::pl;

use 5.8.0;
use utf8;
use strict;
use warnings;

our $VERSION = '0.001';

use base qw(Exporter);

our @EXPORT = qw(
    later     later_exact
    earlier   earlier_exact
    ago       ago_exact
    from_now  from_now_exact
    duration  duration_exact
    concise
);
our @EXPORT_OK = ( 'interval', @EXPORT );

use Time::Duration qw();

my %en2pl = (
    #           singular   plural     plural in genitive
    second => [ 'sekunda', 'sekundy', 'sekund' ],
    minute => [ 'minuta',  'minuty',  'minut'  ],
    hour   => [ 'godzina', 'godziny', 'godzin' ],
    day    => [ 'dzień',   'dni',     'dni'    ],
    year   => [ 'rok',     'lata',    'lat'    ],
);

my %short   = map { $_ => substr($_, 0, 1) } map { @{$_} } values %en2pl;
my $comp_re = join '|', map { @{$_} } values %en2pl;

sub concise ($) {
    my ( $string ) = @_;

    for ($string) {
        tr/,//d;
        s/\bi\b//;
        s/\b($comp_re)\b/$short{$1}/g;
        s/\s*(\d+)\s*/$1/g;

        # restore prefixed intervals
        s/za/za /;
    }

    return $string;
}

sub later {
    interval(      $_[0], $_[1], '%s wcześniej', '%s później', 'teraz');
}

sub later_exact {
    interval_exact($_[0], $_[1], '%s wcześniej', '%s później', 'teraz');
}

sub earlier {
    interval(      $_[0], $_[1], '%s później', '%s wcześniej', 'teraz');
}

sub earlier_exact {
    interval_exact($_[0], $_[1], '%s później', '%s wcześniej', 'teraz');
}

sub ago {
    interval(      $_[0], $_[1], 'za %s', '%s temu', 'teraz');
}

sub ago_exact {
    interval_exact($_[0], $_[1], 'za %s', '%s temu', 'teraz');
}

sub from_now {
    interval(      $_[0], $_[1], '%s temu', 'za %s', 'teraz');
}

sub from_now_exact {
    interval_exact($_[0], $_[1], '%s temu', 'za %s', 'teraz');
}

sub duration_exact {
    my ( $span ) = @_;   # interval in seconds
    return '0 sekund' unless $span;
    _render(
        '%s',
        Time::Duration::_separate(abs $span));
}

sub duration {
    my ( $span, $precision ) = @_;          # interval in seconds
    return '0 sekund' unless $span;
    _render(
        '%s',
        Time::Duration::_approximate(
            int($precision || 0) || 2,      # precision (default: 2)
            Time::Duration::_separate(abs $span)));
}

sub interval_exact {
    my ( $span ) = @_;                      # interval in seconds
    my $direction = ($span <= -1) ? $_[2]   # what a neg number gets
                  : ($span >=  1) ? $_[3]   # what a pos number gets
                  : return          $_[4];  # what zero gets
    _render($direction, Time::Duration::_separate($span));
}

sub interval {
    my ( $span, $precision ) = @_;          # interval in seconds
    my $direction = ($span <= -1) ? $_[2]   # what a neg number gets
                  : ($span >=  1) ? $_[3]   # what a pos number gets
                  : return          $_[4];  # what zero gets
    _render(
        $direction,
        Time::Duration::_approximate(
            int($precision || 0) || 2,      # precision (default: 2)
            Time::Duration::_separate($span)));
}

BEGIN {
    # generally numbers' units in Polish use plural form in genitive case,
    # but for some values like 2, 3, 4, 22, 23, 24, 32, 33, 34, etc. nominative
    # is used
    my %case_index = (
        0 => 2,
        1 => 2,
        2 => 1,
        3 => 1,
        4 => 1,
        5 => 2,
        6 => 2,
        7 => 2,
        8 => 2,
        9 => 2,
        10 => 2,
        11 => 2,
        12 => 2,
        13 => 2,
        14 => 2,
    );

    sub _determine_case {
        my ( $amount ) = @_;
        return 0 if $amount == 1;         # use singular for 1
        return $case_index{$amount}       # choose case explicitely for 2..14
            || $case_index{$amount % 10}; # or use last digit for greater values
    }
}

sub _render {
    # Make it into Polish
    my $direction = shift;
    my @wheel = map {
        my ( $unit, $amount ) = @{$_};
        ( $amount == 0 )
            ? ()
            : $amount . ' ' . $en2pl{$unit}[_determine_case($amount)]
        } @_;

    return 'teraz' unless @wheel; # sanity

    my $result;
    if (@wheel == 1) {
        $result = $wheel[0];
    }
    elsif (@wheel == 2) {
        $result = $wheel[0] . ' i ' . $wheel[1];
    }
    else {
        my $last = pop @wheel;
        $result = join(', ', @wheel) . ' i ' . $last;
    }

    return sprintf($direction, $result);
}

1;

__END__

=encoding UTF-8

=head1 NAME

Time::Duration::pl - describe time duration in Polish


=head1 VERSION

Version 0.01


=head1 SYNOPSIS

    use Time::Duration::pl;

    my $duration = duration(time() - $start_time);


=head1 DESCRIPTION

C<Time::Duration::pl> is a localized version of C<Time::Duration>.


=head1 FUNCTIONS

=over

=item duration($seconds)

=item duration($seconds, $precision)

Returns English text expressing the approximate time duration
of C<abs($seconds)>, with at most S<C<$precision || 2>> expressed units.

Examples:

    duration(130)       => '2 minuty i 10 sekund'

    duration(243550)    => '2 dni i 20 godzin'
    duration(243550, 1) => '3 dni'
    duration(243550, 3) => '2 dni, 19 godzin i 39 minut'
    duration(243550, 4) => '2 dni, 19 godzin, 39 minut i 10 sekund'


=item duration_exact($seconds)

Same as C<duration($seconds)>, except that the returned value is an exact
(unrounded) expression of C<$seconds>.

Example:

    duration_exact(31629659) => '1 rok, 1 dzień, 2 godziny i 59 sekund'


=item ago($seconds)

=item ago($seconds, $precision)

=item ago_exact($seconds)

Negative values are passed to C<from_now()> / C< from_now_exact()>.

Examples:

    ago(243550)         => '2 dni i 20 godzin temu'
    ago(243550, 1)      => '3 dni temu'
    ago_exact(243550)   => '2 dni, 19 godzin, 39 minut i 10 sekund temu'

    ago(0)              => 'teraz'

    ago(-243550)        => 'za 2 dni i 20 godzin'
    ago(-243550, 1)     => 'za 3 dni'


=item from_now($seconds)

=item from_now($seconds, $precision)

=item from_now_exact($seconds)

Negative values are passed to C<ago()> / C< ago_exact()>.

Examples:

    from_now(243550)    => 'za 2 dni i 20 godzin'
    from_now(243550, 1) => 'za 3 dni'

    from_now(0)         => 'teraz'

    from_now(-243550)   => '2 dni i 20 godzin temu'
    from_now(-243550, 1)=> '3 dni temu'


=item later($seconds)

=item later($seconds, $precision)

=item later_exact($seconds)

Negative values are passed to C<ago()> / C< ago_exact()>.

Examples:

    later(243550)       => '2 dni i 20 godzin później'
    later(243550, 1)    => '3 dni później'

    later(0)            => 'teraz'

    later(-243550)      => '2 dni i 20 godzin wcześniej'
    later(-243550, 1)   => '3 dni wcześniej'


=item earlier($seconds)

=item earlier($seconds, $precision)

=item earlier_exact($seconds)

Negative values are passed to C<ago()> / C< ago_exact()>.

Examples:

    earlier(243550)     => '2 dni i 20 godzin wcześniej'
    earlier(243550, 1)  => '3 dni wcześniej'

    earlier(0)          => 'teraz'

    earlier(-243550)    => '2 dni i 20 godzin później'
    earlier(-243550, 1) => '3 dni później'


=item concise( I<function(> ... ) )

C<concise()> takes the string output of one of the above functions
and makes it more concise.

Examples:

    ago(4567)           => '1 godzina i 16 minut temu'
    concise(ago(4567))  => '1g16m temu'

    earlier(31629659)           => '1 rok i 1 dzień wcześniej'
    concise(earlier(31629659))  => '1r1d wcześniej'


=back


=head1 CREDITS

The code was first copied from L<Time::Duration::fr> by Sébastien
Aperghis-Tramoni.


=head1 SEE ALSO

L<Time::Duration>, L<Time::Duration::Locale>


=head1 AUTHOR

Grzegorz Rożniecki


=head1 BUGS

Please report any bugs or feature requests to
C<bug-time-duration-pl at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/Public/Dist/Display.html?Dist=Time-Duration-pl>.
I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Time::Duration::pl


=head1 COPYRIGHT & LICENSE

Copyright 2013 Grzegorz Rożniecki, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
