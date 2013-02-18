package Net::OpenVPN::ProxyManager;
use Moose;
use 5.10.0;
use Net::OpenVPN::ProxyManager::Config;
use Capture::Tiny 'capture';

our $VERSION = '0.025';

has config_path 	=> ( is => 'rw', isa => 'Str', default => '/tmp/openvpn-config.conf' );
has config			=> ( is => 'rw', isa => 'Object', builder => 'create_config');
has openvpn_pid		=> ( is => 'rw', isa => 'Str');
has warning_flag	=> ( is => 'rw', isa => 'Int', default => 1);

sub connect {
	my ($self, $config_string) = @_;
	
	# check for root privileges
	if ($> != 0) {
		$self->_give_warning('Connecting as non-root user. By default OpenVPN requires root privileges and unless locally configured otherwise, will not work without them.');	
	}
	
	# check openvpn is installed
	my $openvpn_path = $self->_test_openvpn;
	
	# open FH and print config file to /tmp
	open (my $fh, '>', $self->config_path() ); 
	$self->config()->_print_config($fh, $config_string);
	$fh->close;
	system 'chmod', '644', $self->config_path;
	
	# run openvpn in child process
	defined( $self->openvpn_pid(fork()) ) or die "unable to fork new process and start OpenVPN $!\n";
	if ($self->openvpn_pid() == 0) { 
		exec $openvpn_path, '--config', $self->config_path;
	}
}

sub create_config {
	my ($self, $params) = @_;
	ref $params eq 'HASH' ? Net::OpenVPN::ProxyManager::Config->new($params) : Net::OpenVPN::ProxyManager::Config->new;
}

sub disconnect {
	my $self = shift;
	if ($self->openvpn_pid){
		kill 0, $self->openvpn_pid ? kill 2, $self->openvpn_pid() : $self->_give_warning('Error: do not have enough privileges to stop the OpenVPN process.'); 
	}
	else {
		$self->_give_warning('No PID found for an active OpenVPN connection');	
	}
}

sub _give_warning {
	my ($self, $warning_msg) = @_;
	if ($self->warning_flag() == 1) {
		warn $warning_msg;
	}
}

sub _test_openvpn {
	my ($self) = @_;
	my  ($stdout, $stderr, @result) = capture { system 'which', 'openvpn'; };
	$result[0] ? die qq!openvpn not found (is it in your PATH or a bin folder that is in PATH?)! : 1;
	chomp $stdout;
	return $stdout;
}

sub toggle_warnings{
	my $self = shift;
	$self->warning_flag() ? $self->warning_flag(0) : $self->warning_flag(1);
}


no Moose;
1;

__END__

=pod

=head1 NAME

Net::OpenVPN::ProxyManager - connect to proxy servers using OpenVPN.

=head1 SYNOPSIS

	use Net::OpenVPN::ProxyManager;
	
	my $pm = Net::OpenVPN::ProxyManager->new;
	
	# Create a config object to capture proxy server details
	my $config_object = $pm->create_config({remote => '100.120.3.34 53', proto => 'udp'});
	
	# Launch OpenVPN and connect to the proxy
	$pm->connect($config_object);
	
		# do some stuff
	
	# Disconnect from the proxy server
	$pm->disconnect();
	
=head1 DESCRIPTION

Net::OpenVPN::ProxyManager is an object oriented module that provides methods to simplify the management of proxy connections that support OpenVPN. This is a 
base generic class, see L<Net::OpenVPN::ProxyManager::HMA> for additional methods to interact with hidemyass.com proxy servers. 

NB. By default OpenVPN requires root privileges to run unless locally configured otherwise. ProxyManager connect and disconnect methods will check for root privileges 
and warn if they are not found. For further information see L</"UNSATISFACTORY STUFF">.

=head1 METHODS

=head2 NEW
The constructor accepts an anonymous hash for two optional parameters: config_path and warning_flag. 

config_path is the path that ProxyManager.pm will use to create the config file when the create_config method is called. By default config_path is set to 
'/tmp/openvpn-config.conf'. 

warning_flag is an integer (either 0 or 1) and used by ProxyManager.pm to determine whether to issue a warning or not. By default it is set to 1. The toggle_warnings
method can also turn this on or off.

	my $pm = Net::OpenVPN::ProxyManager->new( { config_path => '/tmp/my_own_directory.conf', warning_flag => 0 } );
	
	
=head2 CONNECT
Initialises OpenVPN and connects the proxy server specified in $config_object. See create_config for how to create and configure a config object.
	$pm->connect($config_object);

=head2 DISCONNECT
Disconnects from the proxy server by killing the OpenVPN process.
	$pm->disconnect();

=head2 CREATE_CONFIG
Creates a config object with sensible defaults. create_config does require ip address, port and protocol parameters.
	my $config_object = $pm->create_config({remote => '100.120.3.34 53', proto => 'udp'});

=head2 TOGGLE_WARNINGS
Will turn warnings on / off.
	$pm->toggle_warnings();

=head1 DEPENDENCIES

Non-Perl dependencies

OS - this module has been tested on Ubuntu linux 12.04. It should work on other Linux distros, perhaps OSX but probably not Windows.

OpenVPN needs to be installed and in $PATH (or in bin, in $PATH).This module has been tested on OpenVPN version 2.2.1. I do not know if it will work on other 
versions. See L<Net::OpenVPN::Manage> for a Perl module that does not require OpenVPN to be installed.

You will also need an internet connection!

=cut

=head1 UNSATISFACTORY STUFF

By default OpenVPN runs as root so that it can modify the host computer's IP settings in establishing the VPN connection. Therefore this module checks if Perl is
running with root privileges (so that it can connect and disconnect to multiple VPNs using OpenVPN). If root privileges are not detected, it will issue a warning
(but continue running). OpenVPN have L<provided instructions|https://community.openvpn.net/openvpn/wiki/UnprivilegedUser> on how to locally configure OpenVPN to 
run as an unprivileged user. If you do this, use the ProxyManager method "toggle_warnings" to switch them off.

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


=head1 ACKNOWLEDGEMENTS


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

