Official Midtrans SNAP OpenCart Extension
===================================

Midtrans :heart: OpenCart!

This is the official Midtrans extension for the OpenCart E-commerce platform.

## Compatibility
1. PHP v5.4 and higher
2. Opencart v2.0, 2.1, 2.2

## Installation

1. Download and extract the zip file.

2. Locate the root _OpenCart_ directory of your shop via FTP connection.

3. Copy the `admin`, `catalog`, and `system` folders into your _OpenCart's_ root folder, and merge it.

4. In your _OpenCart_ admin area, go to `Extensions` - `Payments`.

5. Scroll down untill you find `Midtrans`.

6. Click the `Install` green button and edit the plugin.

7. Insert your merchant details (server key and client key).

8. Login into your Midtrans account and change the following options:

  * **Payment Notification URL** in Settings to `http://[your shop's homepage]/index.php?route=payment/snap/payment_notification`

  * **Finish Redirect URL** in Settings to `http://[your shop’s homepage]/index.php?route=payment/snap/landing_redir&`

  * **Error Redirect URL** in Settings to `http://[your shop’s homepage]/index.php?route=payment/snap/landing_redir&`

  * **Unfinish Redirect URL** in Settings to `http://[your shop’s homepage]/index.php?route=payment/snap/landing_redir&`

### Get Help

* [SNAP-Opencart Wiki](https://github.com/veritrans/SNAP-Opencart/wiki)
* [Midtrans registration](https://account.midtrans.com/register)
* [SNAP documentation](https://snap-docs.midtrans.com/)
* Can't find answer you looking for? email to [support@midtrans.com](mailto:support@midtrans.com)
