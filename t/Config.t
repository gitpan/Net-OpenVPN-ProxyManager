# Add the lib to @INC
use Cwd;
my $cwd = cwd;
unshift @INC, $cwd .= '/lib';

use Test::More tests => 5;

# Add a realistic multi-line value for OpenVPN config
my $cert = 
'-----BEGIN CERTIFICATE-----
MIID5jCCA0+gAwIBAgIBAjANBgkqhkiG9w0BAQUFADCBlzELMAkGA1UEBhMCVUsx
CzAJBgNVBAgTAk5SMRUwEwYDVQQHEwxBdHRsZWJvcm91Z2gxGTAXBgNVBAoUEEhp
ZGUgTXkgQXNzISBQcm8xDDAKBgNVBAsTA1ZQTjEaMBgGA1UEAxMRdnBuLmhpZGVt
eWFzcy5jb20xHzAdBgkqhkiG9w0BCQEWEGNhQGhpZGVteWFzcy5jb20wHhcNMDkw
NjA2MDk0MzI2WhcNMTkwNjA0MDk0MzI2WjCBhzELMAkGA1UEBhMCVVMxCzAJBgNV
BAgTAkNBMRUwEwYDVQQHEwxTYW5GcmFuY2lzY28xEDAOBgNVBAoTB1ZQTlVzZXIx
DTALBgNVBAsTBFVzZXIxEDAOBgNVBAMTB2htYXVzZXIxITAfBgkqhkiG9w0BCQEW
EnVzZXJAaGlkZW15YXNzLmNvbTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA
rgyqqg4KIJpehg4+tDRXmwr+/AHAjYmjGVilgXpP4VL2HUakABdg/i5DJ6ZUbouf
1AwvkzPRgSjB1FqBgTi3W8fyl7UL5l+wudZTFxQuXAVtkWf5MHniPGSZanEeGsvD
698ykq+TaHaJECXjNFFIKs/Xb3AqaOuZu53/GfoFSUMCAwEAAaOCAU4wggFKMAkG
A1UdEwQCMAAwLQYJYIZIAYb4QgENBCAWHkVhc3ktUlNBIEdlbmVyYXRlZCBDZXJ0
aWZpY2F0ZTAdBgNVHQ4EFgQUfpgYeC73KSJVNsnzSR1VVo1fTFEwgcwGA1UdIwSB
xDCBwYAUzli9ONAdxV7S73RTOpfaXP99HDKhgZ2kgZowgZcxCzAJBgNVBAYTAlVL
MQswCQYDVQQIEwJOUjEVMBMGA1UEBxMMQXR0bGVib3JvdWdoMRkwFwYDVQQKFBBI
aWRlIE15IEFzcyEgUHJvMQwwCgYDVQQLEwNWUE4xGjAYBgNVBAMTEXZwbi5oaWRl
bXlhc3MuY29tMR8wHQYJKoZIhvcNAQkBFhBjYUBoaWRlbXlhc3MuY29tggkAjPJM
DBldWigwEwYDVR0lBAwwCgYIKwYBBQUHAwIwCwYDVR0PBAQDAgeAMA0GCSqGSIb3
DQEBBQUAA4GBAGwi9eLvW+3B623DIlznKFCH5BTB88/mOZHRbENdRWRNa2VdSiGh
LZs3I7en+zAmoP1sfeAxFXlyIdw6/oNxuTT63eF4G7kAiPZ2eeplvFWRTZNCc08V
+tdcVSGRtgwc1v8GVMlBBGqyTmL96TveK7mCDGaGv+HwEBo9r2HJJvVD
-----END CERTIFICATE-----';

# Create filehandle
open (my $fh, '>', '/tmp/proxymanager-config.cfg');

use_ok ('Net::OpenVPN::ProxyManager::Config');
ok (my $config = Net::OpenVPN::ProxyManager::Config->new, 'Config object initialisation');
ok ($config->key($cert), 'Set multiline key value');
ok ($config->print_config($cert) == 0, 'Check print_config failure with non filehandle argument');
ok ($config->print_config($fh), 'Check config prints correctly');
