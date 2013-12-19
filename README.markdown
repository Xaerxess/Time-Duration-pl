# NAME

Time::Duration::pl - Describe time duration in Polish

# VERSION

version 0.001

# SYNOPSIS

    use Time::Duration::pl;

    my $duration = duration(time() - $start_time);

# DESCRIPTION

`Time::Duration::pl` is a localized version of `Time::Duration`.

# FUNCTIONS

- duration($seconds)
- duration($seconds, $precision)

    Returns English text expressing the approximate time duration
    of `abs($seconds)`, with at most `$precision&nbsp;||&nbsp;2` expressed units.

    Examples:

        duration(130)       => '2 minuty i 10 sekund'

        duration(243550)    => '2 dni i 20 godzin'
        duration(243550, 1) => '3 dni'
        duration(243550, 3) => '2 dni, 19 godzin i 39 minut'
        duration(243550, 4) => '2 dni, 19 godzin, 39 minut i 10 sekund'

- duration\_exact($seconds)

    Same as `duration($seconds)`, except that the returned value is an exact
    (unrounded) expression of `$seconds`.

    Example:

        duration_exact(31629659) => '1 rok, 1 dzień, 2 godziny i 59 sekund'

- ago($seconds)
- ago($seconds, $precision)
- ago\_exact($seconds)

    Negative values are passed to `from_now()` / ` from_now_exact()`.

    Examples:

        ago(243550)         => '2 dni i 20 godzin temu'
        ago(243550, 1)      => '3 dni temu'
        ago_exact(243550)   => '2 dni, 19 godzin, 39 minut i 10 sekund temu'

        ago(0)              => 'teraz'

        ago(-243550)        => 'za 2 dni i 20 godzin'
        ago(-243550, 1)     => 'za 3 dni'

- from\_now($seconds)
- from\_now($seconds, $precision)
- from\_now\_exact($seconds)

    Negative values are passed to `ago()` / ` ago_exact()`.

    Examples:

        from_now(243550)    => 'za 2 dni i 20 godzin'
        from_now(243550, 1) => 'za 3 dni'

        from_now(0)         => 'teraz'

        from_now(-243550)   => '2 dni i 20 godzin temu'
        from_now(-243550, 1)=> '3 dni temu'

- later($seconds)
- later($seconds, $precision)
- later\_exact($seconds)

    Negative values are passed to `ago()` / ` ago_exact()`.

    Examples:

        later(243550)       => '2 dni i 20 godzin później'
        later(243550, 1)    => '3 dni później'

        later(0)            => 'teraz'

        later(-243550)      => '2 dni i 20 godzin wcześniej'
        later(-243550, 1)   => '3 dni wcześniej'

- earlier($seconds)
- earlier($seconds, $precision)
- earlier\_exact($seconds)

    Negative values are passed to `ago()` / ` ago_exact()`.

    Examples:

        earlier(243550)     => '2 dni i 20 godzin wcześniej'
        earlier(243550, 1)  => '3 dni wcześniej'

        earlier(0)          => 'teraz'

        earlier(-243550)    => '2 dni i 20 godzin później'
        earlier(-243550, 1) => '3 dni później'

- concise( _function(_ ... ) )

    `concise()` takes the string output of one of the above functions
    and makes it more concise.

    Examples:

        ago(4567)           => '1 godzina i 16 minut temu'
        concise(ago(4567))  => '1g16m temu'

        earlier(31629659)           => '1 rok i 1 dzień wcześniej'
        concise(earlier(31629659))  => '1r1d wcześniej'

# CREDITS

The code was first copied from [Time::Duration::fr](https://metacpan.org/pod/Time::Duration::fr) by Sébastien
Aperghis-Tramoni.

# SEE ALSO

[Time::Duration](https://metacpan.org/pod/Time::Duration), [Time::Duration::Locale](https://metacpan.org/pod/Time::Duration::Locale)

# BUGS

Please report any bugs or feature requests through the web interface at
[https://github.com/Xaerxess/Time-Duration-pl](https://github.com/Xaerxess/Time-Duration-pl).

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Time::Duration::pl

# AUTHOR

Grzegorz Rożniecki <xaerxess@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Grzegorz Rożniecki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
