package Net::OpenVPN::ProxyManager::Config;
use Moose;
use 5.10.0;

our $VERSION = '0.01';

has client 			=> (is => 'rw', isa => 'Str', default => '');
has dev 			=> (is => 'rw', isa => 'Str', default => 'tun');
has 'resolv-retry' 	=> (is => 'rw', isa => 'Str', default => 'infinite');
has nobind			=> (is => 'rw', isa => 'Str', default => '');
has 'persist-key'	=> (is => 'rw', isa => 'Str', default => '');
has 'persist-tun'	=> (is => 'rw', isa => 'Str', default => '');
has 'auth-user-pass'=> (is => 'rw', isa => 'Str', default => '');
has 'tun-mtu'		=> (is => 'rw', isa => 'Str', default => '1500');
has 'tun-mtu-extra'	=> (is => 'rw', isa => 'Str', default => '32');
has 'mssfix'		=> (is => 'rw', isa => 'Str', default => '1450');
has 'ns-cert-type'	=> (is => 'rw', isa => 'Str', default => 'server');
has 'verb'			=> (is => 'rw', isa => 'Str', default => '2');
has 'ca'			=> (is => 'rw', isa => 'Str', default => 'skip');
has 'cert'			=> (is => 'rw', isa => 'Str', default => 'skip');
has 'key'			=> (is => 'rw', isa => 'Str', default => 'skip');
has 'remote'		=> (is => 'rw', isa => 'Str', default => 'skip');
has 'proto'			=> (is => 'rw', isa => 'Str', default => 'skip');

sub _print_config {
	my ($self, $fh, $config_string) = @_;
	if (ref $fh ne 'GLOB') {
		print 'Error: print_config method call missing a filehandle parameter'."\n";
		return 0;
	}
	if (not defined $config_string) { # if no config_string arg was supplied
		for my $attribute ($self->meta->get_all_attributes) {
			my $attribute_value = $attribute->get_value($self);
			for ($attribute_value) {	
				when (qr/^skip$/) { next }
				when (qr/\n/) { 
					$config_string.= 
						"<".$attribute->name.">\n".
						$attribute->get_value($self)."\n".
						"</".$attribute->name.">\n"}
				default { $config_string.= $attribute->name.' '.$attribute->get_value($self)."\n" }
			}
		}
	}
	print $fh $config_string;
}

no Moose;
1;


__END__

=pod

=head1 NAME
Net::OpenVPN::ProxyManager-Config - config object for L<Net::OpenVPN::ProxyManager>.

=head1 SYNOPSIS
See L<Net::OpenVPN::ProxyManager> for further documentation. 
	
=head1 DESCRIPTION
See L<Net::OpenVPN::ProxyManager> for further documentation. 

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
