use Test::More;

use_ok ('Net::OpenVPN::ProxyManager');
ok(my $pm = Net::OpenVPN::ProxyManager->new, 'Instantiate ProxyManager object');

done_testing;
