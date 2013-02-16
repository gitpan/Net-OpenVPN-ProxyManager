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

sub print_config {
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