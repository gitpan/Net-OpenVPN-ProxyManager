use Test::More tests => 4;

# Add the lib to @INC
use Cwd;
my $cwd = cwd;
unshift @INC, $cwd .= '/lib';

use_ok ('Net::OpenVPN::ProxyManager');
ok( my $pm = Net::OpenVPN::ProxyManager->new, 'Instantiate ProxyManager object');
ok( $pm->create_config, 'Config object initialisation via create_config method with no params' );
ok($pm->test_openvpn, 'Check that the test_openvpn method is working' );
