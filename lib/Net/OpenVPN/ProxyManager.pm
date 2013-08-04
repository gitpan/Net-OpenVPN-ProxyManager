package Net::OpenVPN::ProxyManager;
use Moo;
use strict;
use Carp qw/croak/;

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

=head1 NAME

Net::OpenVPN::ProxyManager - connect to proxy servers using OpenVPN.

=head1 SYNOPSIS

    use Net::OpenVPN::ProxyManager;
	
    my $pm = Net::OpenVPN::ProxyManager->new;

    $pm->connect($filepath_to_config_file);

    # do some stuff
	
    # now disconnect from first OpenVPN server and connect to another one
    $pm->connect($filepath_to_config_file_alt);

    # do some stuff

    # Disconnect from the proxy server
    $pm->disconnect;

=head1 DESCRIPTION

L<Net::OpenVPN::ProxyManager> is an object oriented module that provides methods to simplify the management of OpenVPN client connections. It's useful because it runs OpenVPN processes as a non-blocking sub-process. This allows you to initiate and disconnect several OpenVPN connections within the same Perl program. 

NB. By default OpenVPN requires root privileges to run unless locally configured otherwise. ProxyManager connect and disconnect methods will check for root privileges and exit if they are not found.

=head1 SYSTEM REQUIREMENTS

=over

=item *

OpenVPN needs to be installed and in $PATH (or in bin, in $PATH). 

=item *

This module has been tested on OpenVPN version 2.2.1 - it may not work on other versions.  

=item *

L<Net::OpenVPN::ProxyManager> only works with Linux-like operating systems.

=back

=head1 METHODS

=head2 connect

Initialises OpenVPN and connects to the OpenVPN server. Requires a filepath to an OpenVPN config file. See the OpenVPN L<documentation|http://openvpn.net/index.php/open-source/documentation/manuals/427-openvpn-22.html> for example config files and options.

	$pm->connect('openvpn.conf');

=cut

has openvpn_pid => (
    is  => 'rw',
    isa => sub {
        die "$_[0] is not a number" unless $_[0] =~ /[0-9]+/;
    },
);

sub connect {
    my ( $self, $config_filepath ) = @_;

    # check for root privileges
    if ( $> != 0 ) {
        croak 'Error: non-root user. Please run as root.';
    }

    # check that config filepath exists
    open( my $config, '<', $config_filepath );
    croak "config filepath $config_filepath not readable"
      unless -e $config_filepath;

    # disconnect from an existing connection
    $self->disconnect if $self->openvpn_pid;

    # run openvpn in child process
    my $pid = open my $fhOut, "| openvpn $config_filepath & ", or croak $!;
    $pid++;
    $self->openvpn_pid($pid);
    return 1;
}

=head2 disconnect

Disconnects from the proxy server by killing the OpenVPN process.

	$pm->disconnect;

=cut

sub disconnect {
    my $self = shift;
    if ( $self->openvpn_pid ) {

        # check if UID has permission to kill the openvpn process
        kill 0, $self->openvpn_pid
          ? kill 9, $self->openvpn_pid
          : croak 'Error: unable to kill the openvpn PID: '
          . $self->openvpn_pid;
    }
    else {
        croak 'Error: no PID found for openvpn connection';
    }
    return 1;
}

=head2 DEMOLISH

This method is called on object destruction and it will call the disconnect method if any active connections are found. This means it is not necessary to call the disconnect method when exiting the program.

=cut

sub DEMOLISH {
    my $self = shift;
    $self->disconnect if $self->openvpn_pid;
}

1;

=head1 TO DO

=over

=item *

Update L<Net::OpenVPN::ProxyManager> to be Windows compatible.

=back

=head1 AUTHOR

David Farrell, C<< <davidnmfarrell at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-openvpn-proxymanager at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-OpenVPN-ProxyManager>.  I will be notified, and then you'll automatically be notified of 
progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::OpenVPN::ProxyManager


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-OpenVPN-ProxyManager>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-OpenVPN-ProxyManager>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-OpenVPN-ProxyManager>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-OpenVPN-ProxyManager/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2013 David Farrell.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

