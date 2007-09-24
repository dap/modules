package DateTime::Format::Natural::Lang::EN;

use strict;
use warnings;
use base qw(DateTime::Format::Natural::Lang::Base);

our $VERSION = '1.00';

our (%init, %data_weekdays, %data_months, %timespan, %main, %ago, %now, %daytime, %months,
     %number, %at, %this_in, %next, %last, %day, %setyearday);

%init = ('tokens' => sub {});

{
    my $i = 1;

    %data_weekdays = map { $_ => $i++ } qw(Monday Tuesday Wednesday Thursday
                                           Friday Saturday Sunday);
    $i = 1;

    %data_months = map { $_ => $i++ } qw(January February March April
                                         May June July August September
                                         October November December);
}

%timespan = ('literal' => 'to');

%main = ('second'         => qr/^second$/i,
         'ago'            => qr/^ago$/i,
         'now'            => qr/^now$/i,
         'daytime'        => [qr/^(?:morning|afternoon|evening)$/i],
         'months'         => [qw(in this)],
         'at_intro'       => qr/^(\d{1,2})(?!\d|st|nd|rd|th)(\:\d{2})?(am|pm)?|((?<!after)noon|midnight)$/i,
         'at_matches'     => [qw(day in month)],
         'number_intro'   => qr/^(\d{1,2})(?:st|nd|rd|th)? ?$/i,
         'number_matches' => [qw(day week month in)],
         'weekdays'       => qr/^(?:this|next|last)$/i,
         'this_in'        => qr/^(?:this|in)$/i,
         'next'           => qr/^next$/i,
         'last'           => qr/^last$/i,
         );

%ago = ('second' => qr/^second(?:s)?$/i,
        'minute' => qr/^minute(?:s)?$/i,
        'hour'   => qr/^hour(?:s)?$/i,
        'day'    => qr/^day(?:s)?$/i,
        'week'   => qr/^week(?:s)?$/i,
        'month'  => qr/^month(?:s)?$/i,
        'year'   => qr/^year(?:s)?$/i,
        );

%now = ('day'    => qr/^day(?:s)?$/i,
        'week'   => qr/^week(?:s)?$/i,
        'month'  => qr/^month(?:s)?$/i,
        'year'   => qr/^year(?:s)?$/i,
        'before' => qr/^before$/i,
        'from'   => qr/^from$/i,
        );

%daytime = ('tokens'     => [ qr/\d/, qr/^in$/i, qr/^the$/i ],
            'morning'    => qr/^morning$/i,
            'afternoon'  => qr/^afternoon$/i,
            );

%months = ('number' => qr/^(\d{1,2})(?:st|nd|rd|th)? ?$/i);

%number = ('month'  => qr/month(?:s)/i,
           'hour'   => qr/hour(?:s)/i,
           'before' => qr/before/i,
           'after'  => qr/after/i,
           );

%at = ('noon'     => qr/noon/i,
       'midnight' => qr/midnight/i,
       );

%this_in = ('second' => qr/second/i,
            'hour'   => qr/hour(?:s)/i,
            'week'   => qr/^week$/i,
            'number' => qr/^(\d{1,2})(?:st|nd|rd|th)?$/i,
            );

%next = ('week'   => qr/^week$/i,
         'day'    => qr/^day$/i,
         'month'  => qr/^month$/i,
         'year'   => qr/^year$/i,
         'number' => qr/^(\d{1,2})(?:st|nd|rd|th)$/,
         );

%last = ('week'   => qr/^week$/i,
         'day'    => qr/^day$/i,
         'month'  => qr/^month$/i,
         'year'   => qr/^year$/i,
         'number' => qr/^(\d{1,2})(?:st|nd|rd|th)$/,
         );

%day = ('init'         => qr/^(?:today|yesterday|tomorrow)$/i,
        'yesterday'    => qr/yesterday/i,
        'tomorrow'     => qr/tomorrow/i,
        'noonmidnight' => qr/^noon|midnight$/i,
        );

%setyearday = ('day' => qr/^day$/i,
               'ext' => qr/^(\d{1,3})(?:st|nd|rd|th)$/,
               );

1;
__END__

=head1 NAME

DateTime::Format::Natural::Lang::EN - English language metadata

=head1 DESCRIPTION

C<DateTime::Format::Natural::Lang::EN> provides the english specific regular expressions
and variables. This class is loaded if the user either specifies the english language or
implicitly.

=head1 EXAMPLES

Below are some examples of human readable date/time input in english (be aware
that the parser doesn't differentiate between lower/upper case):

=head2 Simple

 5am
 4pm
 thursday
 november
 friday 13:00
 mon 2:35
 6 in the morning
 sat 7 in the evening
 yesterday
 today
 tomorrow
 this tuesday
 next month
 next mai
 this morning
 this second
 yesterday at 4:00
 last january
 last friday at 20:00
 last week tuesday
 tomorrow at 6:45pm
 afternoon yesterday
 thursday last week

=head2 Complex

 25 seconds ago
 10 minutes ago
 7 hours ago
 40 days ago
 2 weeks ago
 5 months ago
 3 years ago
 7 days before now
 7 days from now
 4 weeks before now
 4 weeks from now
 13 months before now
 13 months from now
 2 years before now
 2 years from now
 in 3 hours
 1 year ago tomorrow
 3 months ago saturday at 5:00pm
 4th day last week
 3rd wednesday in november
 3rd month next year
 7 hours before tomorrow at noon

=head2 Timespans

 Monday to Friday
 1 April to 31 August

=head2 Specific Dates

 January 11
 11 January
 dec 25
 may 27th
 October 2006
 february 14, 2004
 Friday
 jan 3 2010
 3 jan 2000
 27/5/1979
 4:00
 17:00

=head1 SEE ALSO

L<DateTime::Format::Natural>, L<DateTime>, L<Date::Calc>, L<http://datetime.perl.org>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut