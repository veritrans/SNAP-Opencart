Official Veritrans SNAP OpenCart Extension
===================================

Veritrans :heart: OpenCart!

This is the official Veritrans extension for the OpenCart E-commerce platform.

## Compatibility
1. PHP v5.4 and higher
2. Opencart v2.0, 2.1, 2.2

## Installation

1. Download and extract the zip file.

2. Locate the root _OpenCart_ directory of your shop via FTP connection.

3. Copy the `admin`, `catalog`, and `system` folders into your _OpenCart's_ root folder, and merge it.

4. In your _OpenCart_ admin area, enable the Veritrans plug-in and insert your merchant details (server key and client key).

5. Login into your Veritrans account and change the following options:

  * **Payment Notification URL** in Settings to `http://[your shop's homepage]/index.php?route=extension/payment/snap/payment_notification`

  * **Finish Redirect URL** in Settings to `http://[your shop’s homepage]/index.php?route=extension/payment/snap/landing_redir&`

  * **Error Redirect URL** in Settings to `http://[your shop’s homepage]/index.php?route=extension/payment/snap/landing_redir&`

  * **Unfinish Redirect URL** in Settings to `http://[your shop’s homepage]/index.php?route=extension/payment/snap/landing_redir&`

### Get Help

* [SNAP-Opencart Wiki](https://github.com/veritrans/SNAP-Opencart/wiki)
* [Veritrans registration](https://my.veritrans.co.id/register)
* [SNAP documentation](http://snap-docs.veritrans.co.id)
* Can't find answer you looking for? email to [support@veritrans.co.id](mailto:support@veritrans.co.id)
