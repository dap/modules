package Config::Inetd;

use 5.005;
use strict;
use warnings;

use Carp ();
use Fcntl qw(O_RDWR LOCK_EX LOCK_UN);
use Tie::File ();

our ($VERSION, $INETD_CONF, $conf_tied);

$VERSION = '0.25';
$INETD_CONF = '/etc/inetd.conf';

sub new {
    my ($self, $conf_file) = @_;
    $conf_file ||= $INETD_CONF;

    my %data;    
    _tie_conf(\@{$data{CONF}}, $conf_file);    
    %{$data{ENABLED}} = %{_parse_enabled(@{$data{CONF}})}; 
    
    my $class = ref($self) || $self;    
    return bless(\%data, $class);
}

sub _tie_conf {
    my ($conf, $file) = @_;
    
    $conf_tied = tie(@$conf, 'Tie::File', $file, mode => O_RDWR, autochomp => 0)
      or Carp::croak "Couldn't tie $file: $!";
    $conf_tied->flock(LOCK_EX)
      or Carp::croak "Couldn't lock $file: $!";
}   

sub _parse_enabled {         
    _filter_conf(\@_);
    
    my %is_enabled;
    foreach my $entry (@_) {
	my ($serv, $prot) = _split_serv_prot($entry);
	$is_enabled{$serv}{$prot} = $entry !~ /^\#/ ? 1 : 0;
    }
    return \%is_enabled;
}

sub is_enabled {
    my ($self, $serv, $prot) = @_;
    Carp::croak 'usage: $inetd->is_enabled($service => $protocol)'
      unless $serv && $prot;
    
    return defined $self->{ENABLED}{$serv}{$prot}
      ? $self->{ENABLED}{$serv}{$prot} : undef;
}

sub enable {
    my ($self, $serv, $prot) = @_;
    Carp::croak 'usage: $inetd->enable($service => $protocol)'
      unless $serv && $prot;
    
    foreach my $entry (@{$self->{CONF}}) {
        if ($entry =~ /^\#.*$serv.*$prot\b/) {
	    $self->{ENABLED}{$serv}{$prot} = 1;
	    $entry = substr($entry, 1);
	    return 1;
	}
    }
    return 0;
}

sub disable {
    my ($self, $serv, $prot) = @_;
    Carp::croak 'usage: $inetd->disable($service => $protocol)'
      unless $serv && $prot;
    
    foreach my $entry (@{$self->{CONF}}) {
        if ($entry =~ /^(?!\#).*$serv.*$prot\b/) {
	    $self->{ENABLED}{$serv}{$prot} = 0;
	    $entry = '#'.$entry; 
	    return 1;
	}
    }
    return 0; 
}

sub dump_enabled {
    my ($self) = @_;
    Carp::croak 'usage: $inetd->dump_enabled' unless ref $self;
      
    my @conf = @{$self->{CONF}};
    _filter_conf(\@conf, '^[^\#]');
    
    return @conf;
}

sub dump_disabled {
    my ($self) = @_;
    Carp::croak 'usage: $inetd->dump_disabled' unless ref $self;
    
    my @conf = @{$self->{CONF}};  
    _filter_conf(\@conf, '^\#');
    
    return @conf;
}

sub _filter_conf {
    my ($conf, @regexps) = @_;
     
    unshift @regexps, '(?:stream|dgram|raw|rdm|seqpacket)';
    
    for (my $i = $#$conf; $i >= 0; $i--) {
        foreach my $regexp (@regexps) {
	    splice(@$conf, $i, 1) && last
	      unless $conf->[$i] =~ /$regexp/;
	}
    }
}

sub _split_serv_prot {
    my ($entry) = @_;
     
    my ($serv, $prot) = (split /\s+/, $entry)[0,2];
    
    $serv =~ s/.*:(.*)/$1/; 
    $serv = substr($serv, 1) if $serv =~ /^\#/;  
          
    return ($serv, $prot);
}

sub DESTROY { 
    my ($self) = @_;
    
    $conf_tied->flock(LOCK_UN);
    $conf_tied = 0;
    untie @{$self->{CONF}};
}

1;
__END__

=head1 NAME

Config::Inetd - Interface inetd's configuration file

=head1 SYNOPSIS

 use Config::Inetd;

 $inetd = Config::Inetd->new;                      

 if ($inetd->is_enabled(telnet => 'tcp')) {    
     $inetd->disable(telnet => 'tcp');
 }
 
 print $inetd->dump_enabled;
 print $inetd->dump_disabled;

 print $inetd->{CONF}[6];                                               

=head1 DESCRIPTION

Config::Inetd is an interface to inetd's configuration file F<inetd.conf>;
it simplifies checking and setting the enabled/disabled state of services 
and dumping them by their state.

=head1 CONSTRUCTOR

=head2 new

 $inetd = Config::Inetd->new('/path/to/inetd.conf');

Omitting the path to inetd.conf, will cause the default F</etc/inetd.conf> 
to be used.

=head1 METHODS

=head2 is_enabled

Checks whether a service is enlisted as enabled.

 $retval = $inetd->is_enabled($service => $protocol);

Returns 1 if the service is enlisted as enabled, 0 if enlisted as disabled, 
undef if the service does not exist. 

=head2 enable

Enables a service.

 $retval = $inetd->enable($service => $protocol);

Returns 1 if the service has been enabled, 0 if no action has been taken.

It is recommended to preceedingly run is_enabled() to determine whether a 
service is disabled.

=head2 disable

Disables a service. 

 $retval = $inetd->disable($service => $protocol);

Returns 1 if the service has been disabled, 0 if no action has been taken. 

It is recommended to preceedingly run is_enabled() to determine whether a 
service is enabled.

=head2 dump_enabled

Dumps the enabled services.

 @dump = $inetd->dump_enabled;

Returns an array that consists of inetd configuration lines which are enabled 
services.

=head2 dump_disabled

Dumps the disabled services.

 @dump = $inetd->dump_disabled;

Returns an array that consists of inetd configuration lines which are disabled 
services.

=head1 INSTANCE DATA

The inetd configuration file is tied as instance data (newlines are preserved); 
it may be accessed via @{$inetd->{CONF}}.

=head1 SEE ALSO

L<Tie::File>, inetd(8)

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>	    

=cut
