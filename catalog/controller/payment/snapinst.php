<?php
/*
status code
1 pending
2 processing
3 shipped
5 complete
7 canceled
8 denied
9 canceled reversal
10 failed
11 refunded
12 reversed
13 chargeback
14 expired
15 processed
16 voided
*/

require_once(dirname(__FILE__) . '/snap_midtrans_version.php');
require_once(DIR_SYSTEM . 'library/veritrans-php/Veritrans.php');

class ControllerPaymentSnapinst extends Controller {

  public function index() {

    if ($this->request->server['HTTPS']) {
      $data['base'] = $this->config->get('config_ssl');
    } else {
      $data['base'] = $this->config->get('config_url');
    }

    $data['errors'] = array();
    $data['button_confirm'] = $this->language->get('button_confirm');

    $env = $this->config->get('snapinst_environment') == 'production' ? true : false;
    $data['mixpanel_key'] = $env == true ? "17253088ed3a39b1e2bd2cbcfeca939a" : "9dcba9b440c831d517e8ff1beff40bd9";


    $data['pay_type'] = 'snapinst';
    $data['environment'] = $this->config->get('snapinst_environment');
    $data['client_key'] = $this->config->get('snapinst_client_key');
    $data['merchant_id'] = $this->config->get('snapinst_merchant_id');
    $data['min_txn'] = $this->config->get('snapinst_min_txn');
    $data['text_loading'] = $this->language->get('text_loading');

    $data['process_order'] = $this->url->link('payment/snapinst/process_order');

    $data['opencart_version'] = VERSION;
    $data['mtplugin_version'] = OC2_MIDTRANS_PLUGIN_VERSION;

    $data['disable_mixpanel'] = $this->config->get('snapinst_mixpanel');

    if (file_exists(DIR_TEMPLATE . $this->config->get('config_template') . '/template/payment/snapinst.tpl')) {
        return $this->load->view($this->config->get('config_template') . '/template/payment/snapinst.tpl',$data);
    } else {
     if (VERSION > 2.1 ) {
        return $this->load->view('payment/snapinst', $data);
      } else {
        return $this->load->view('default/template/payment/snapinst.tpl', $data);
      }
    }

  }

  /**
   * Called when a customer checkouts.
   * If it runs successfully, it will redirect to VT-Web payment page.
   */
  public function process_order() {
    $this->load->model('payment/snapinst');
    $this->load->model('checkout/order');
    $this->load->model('total/shipping');
    $this->load->language('payment/snapinst');

    $data['errors'] = array();

    $data['button_confirm'] = $this->language->get('button_confirm');

    $order_info = $this->model_checkout_order->getOrder(
      $this->session->data['order_id']);
    //error_log(print_r($order_info,TRUE));

    $this->model_checkout_order->addOrderHistory($this->session->data['order_id'],1);
    /*$this->model_checkout_order->addOrderHistory($this->session->data['order_id'],
        $this->config->get('veritrans_vtweb_challenge_mapping'));*/
    

    $transaction_details                 = array();
    $transaction_details['order_id']     = $this->session->data['order_id'];
    $transaction_details['gross_amount'] = $order_info['total'];

    $billing_address                 = array();
    $billing_address['first_name']   = $order_info['payment_firstname'];
    $billing_address['last_name']    = $order_info['payment_lastname'];
    $billing_address['address']      = $order_info['payment_address_1'];
    $billing_address['city']         = $order_info['payment_city'];
    $billing_address['postal_code']  = $order_info['payment_postcode'];
    $billing_address['phone']        = $order_info['telephone'];
    $billing_address['country_code'] = strlen($order_info['payment_iso_code_3'] != 3) ? 'IDN' : $order_info['payment_iso_code_3'];

    if ($this->cart->hasShipping()) {
      $shipping_address = array();
      $shipping_address['first_name']   = $order_info['shipping_firstname'];
      $shipping_address['last_name']    = $order_info['shipping_lastname'];
      $shipping_address['address']      = $order_info['shipping_address_1'];
      $shipping_address['city']         = $order_info['shipping_city'];
      $shipping_address['postal_code']  = $order_info['shipping_postcode'];
      $shipping_address['phone']        = $order_info['telephone'];
      $shipping_address['country_code'] = strlen($order_info['payment_iso_code_3'] != 3) ? 'IDN' : $order_info['payment_iso_code_3'];
    } else {
      $shipping_address = $billing_address;
    }

    $customer_details                     = array();
    $customer_details['billing_address']  = $billing_address;
    $customer_details['shipping_address'] = $shipping_address;
    $customer_details['first_name']       = $order_info['payment_firstname'];
    $customer_details['last_name']        = $order_info['payment_lastname'];
    $customer_details['email']            = $order_info['email'];
    $customer_details['phone']            = $order_info['telephone'];

    $products = $this->cart->getProducts();
    
    $item_details = array();

    foreach ($products as $product) {
      if (($this->config->get('config_customer_price')
            && $this->customer->isLogged())
          || !$this->config->get('config_customer_price')) {
        $product['price'] = $this->tax->calculate(
            $product['price'],
            $product['tax_class_id'],
            $this->config->get('config_tax'));
      }

      $item = array(
          'id'       => $product['product_id'],
          'price'    => $product['price'],
          'quantity' => $product['quantity'],
          'name'     => $product['name']
        );
      $item_details[] = $item;
    }

    unset($product);

    $num_products = count($item_details);

    if ($this->cart->hasShipping()) {
      $shipping_info = $this->session->data['shipping_method'];
      if (($this->config->get('config_customer_price')
            && $this->customer->isLogged())
          || !$this->config->get('config_customer_price')) {
        $shipping_info['cost'] = $this->tax->calculate(
            $shipping_info['cost'],
            $shipping_info['tax_class_id'],
            $this->config->get('config_tax'));
      }

      $shipping_item = array(
          'id'       => 'SHIPPING',
          'price'    => $shipping_info['cost'],
          'quantity' => 1,
          'name'     => 'SHIPPING'
        );
      $item_details[] = $shipping_item;
    }

    // convert all item prices to IDR
    if ($this->config->get('config_currency') != 'IDR') {
      if ($this->currency->has('IDR')) {
        foreach ($item_details as &$item) {
          $item['price'] = intval($this->currency->convert(
              $item['price'],
              $this->config->get('config_currency'),
              'IDR'
            ));
        }
        unset($item);

        $transaction_details['gross_amount'] = intval($this->currency->convert(
            $transaction_details['gross_amount'],
            $this->config->get('config_currency'),
            'IDR'
          ));
      }
      else if ($this->config->get('snapinst_currency_conversion') > 0) {
        foreach ($item_details as &$item) {
          $item['price'] = intval($item['price']
              * $this->config->get('snapinst_currency_conversion'));
        }
        unset($item);

        $transaction_details['gross_amount'] = intval(
            $transaction_details['gross_amount']
            * $this->config->get('snapinst_currency_conversion'));
      }
      else {
        $data['errors'][] = "Either the IDR currency is not installed or "
            . "the snap currency conversion rate is valid. "
            . "Please review your currency setting.";
      }
    }

    $total_price = 0;
    foreach ($item_details as $item) {
      $total_price += $item['price'] * $item['quantity'];
    }

    if ($total_price != $transaction_details['gross_amount']) {
      $coupon_item = array(
          'id'       => 'COUPON',
          'price'    => $transaction_details['gross_amount'] - $total_price,
          'quantity' => 1,
          'name'     => 'COUPON'
        );
      $item_details[] = $coupon_item;
    }

    Veritrans_Config::$serverKey = $this->config->get('snapinst_server_key');

    Veritrans_Config::$isProduction =
        $this->config->get('snapinst_environment') == 'production'
        ? true : false;

    Veritrans_Config::$isSanitized = true;

    // $min_txn = $this->config->get('snapinst_min_txn');
    // $credit_card['save_card'] = true;
    $installment = array();
    $installment_term = array();
    
    $installment_term['bni'] = array(3,6,9,12,15,18,21,24,27,30,33,36);
    $installment_term['mandiri'] = array(3,6,9,12,15,18,21,24,27,30,33,36);
    $installment_term['cimb'] = array(3,6,9,12,15,18,21,24,27,30,33,36);
    $installment_term['bri'] = array(3,6,9,12,15,18,21,24,27,30,33,36);
    $installment_term['maybank'] = array(3,6,9,12,15,18,21,24,27,30,33,36);
    $installment_term['bca'] = array(3,6,9,12,15,18,21,24,27,30,33,36);
    $installment_term['mega'] = array(3,6,9,12,15,18,21,24,27,30,33,36);

    $installment['required'] = TRUE;
    $installment['terms'] = $installment_term;

    $credit_card['installment'] = $installment;
    
    $payloads = array();
    $payloads['transaction_details'] = $transaction_details;
    $payloads['item_details']        = $item_details;
    $payloads['customer_details']    = $customer_details;
    $payloads['enabled_payments']    = array('credit_card');
    $payloads['credit_card']['secure'] = true;

    if ($transaction_details['gross_amount'] >= $this->config->get('snapinst_min_txn')){
      $payloads['credit_card'] = $credit_card;
    }

    if(!empty($this->config->get('snapinst_custom_field1'))){$payloads['custom_field1'] = $this->config->get('snapinst_custom_field1');}
    if(!empty($this->config->get('snapinst_custom_field2'))){$payloads['custom_field2'] = $this->config->get('snapinst_custom_field2');}
    if(!empty($this->config->get('snapinst_custom_field3'))){$payloads['custom_field3'] = $this->config->get('snapinst_custom_field3');}

    try {
      // error_log(print_r($payloads,TRUE));
      $snapToken = Veritrans_Snap::getSnapToken($payloads);
      $this->response->setOutput($snapToken);
    }
    catch (Exception $e) {
      $data['errors'][] = $e->getMessage();
      error_log($e->getMessage());
      echo $e->getMessage();
    }
  }
}
