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


require_once(DIR_SYSTEM . 'library/veritrans-php/Veritrans.php');

class ControllerPaymentSnap extends Controller {

  public function index() {

    $data['errors'] = array();
    $data['button_confirm'] = $this->language->get('button_confirm');

  	$data['pay_type'] = 'snap';
    $data['environment'] = $this->config->get('snap_environment');
    $data['text_loading'] = $this->language->get('text_loading');

  	$data['process_order'] = $this->url->link('payment/snap/process_order');

     if (file_exists(DIR_TEMPLATE . $this->config->get('config_template') . '/template/payment/snap.tpl')) {
        return $this->load->view($this->config->get('config_template') . '/template/payment/snap.tpl',$data);
    } else {
     if (VERSION > 2.1 ) {
        return $this->load->view('payment/snap', $data);
      } else {
        return $this->load->view('default/template/payment/snap.tpl', $data);
      }
    }

  }

  /**
   * Called when a customer checkouts.
   * If it runs successfully, it will redirect to VT-Web payment page.
   */
  public function process_order() {
    $this->load->model('payment/snap');
    $this->load->model('checkout/order');
    $this->load->model('total/shipping');
    $this->load->language('payment/snap');

    $data['errors'] = array();

    $data['button_confirm'] = $this->language->get('button_confirm');

    $order_info = $this->model_checkout_order->getOrder(
      $this->session->data['order_id']);
    //error_log(print_r($order_info,TRUE));
    error_log($this->config->get('snap_snap_challenge_mapping'));

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
      else if ($this->config->get('snap_currency_conversion') > 0) {
        foreach ($item_details as &$item) {
          $item['price'] = intval($item['price']
              * $this->config->get('snap_currency_conversion'));
        }
        unset($item);

        $transaction_details['gross_amount'] = intval(
            $transaction_details['gross_amount']
            * $this->config->get('snap_currency_conversion'));
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

    Veritrans_Config::$serverKey = $this->config->
        get('snap_server_key');

    Veritrans_Config::$isProduction =
        $this->config->get('snap_environment') == 'production'
        ? true : false;

    Veritrans_Config::$is3ds = true;

    Veritrans_Config::$isSanitized =
        $this->config->get('snap_sanitization') == 'on'
        ? true : false;


    $payloads = array();
    $payloads['transaction_details'] = $transaction_details;
    $payloads['item_details']        = $item_details;
    $payloads['customer_details']    = $customer_details;

    try {
      $snapToken = Veritrans_Snap::getSnapToken($payloads);      
      error_log($snapToken);    
      //$this->response->setOutput($redirUrl);
      $this->response->setOutput($snapToken);
    }
    catch (Exception $e) {
      $data['errors'][] = $e->getMessage();
      error_log($e->getMessage());
      echo $e->getMessage();
    }
  }

  /**
   * Landing page when payment is finished or failure or customer pressed "back" button
   * The Cart is cleared here, so make sure customer reach this page to ensure the cart is emptied when payment succeed
   * payment finish/unfinish/error url :
   * http://[your shop’s homepage]/index.php?route=payment/snap/payment_notification
   */
  public function landing_redir() {

    $this->load->model('checkout/order');
    $redirUrl = $this->config->get('config_ssl');

    //$this->cart->clear();

    Veritrans_Config::$serverKey = $this->config->get('snap_server_key');
    Veritrans_Config::$isProduction = $this->config->get('snap_environment') == 'production' ? true : false;

    $redirUrl = $this->url->link('checkout/success&');
    /*$result_data = $_POST['result_data'];
    $post_response = $_POST['response'];*/    
    ///error_log("json_decode");
    //error_log(print_r(json_decode($result_data),TRUE));
    
    $response = isset($_POST['result_data']) ? json_decode($_POST['result_data']) : json_decode($_POST['response']);
    error_log(print_r($response,TRUE));
    //error_log($response->va_numbers[0]->bank);
    $base_url = $this->config->get('snap_environment') == 'production' 
    ? "https://app.veritrans.co.id" : "https://app.sandbox.veritrans.co.id";
    
    $transaction_status = $response->transaction_status;
    $payment_type = $response->payment_type;
    $channel = array("bank_transfer", "echannel", "cstore","xl_tunai");
    
    if( $transaction_status == 'capture' || $transaction_status == 'settlement') {
      //if capture or pending or challenge or settlement, redirect to order received page

      //$this->model_checkout_order->addOrderHistory($this->session->data['order_id'],2);
      $this->model_checkout_order->addOrderHistory($response->order_id,2);
      $this->cart->clear();
      $redirUrl = $this->url->link('checkout/success&');
      $this->response->redirect($redirUrl);

    }else if( $transaction_status == 'deny') {
      //if deny, redirect to order checkout page again
      
      $redirUrl = $this->url->link('payment/snap/failure','','SSL');
      $this->response->redirect($redirUrl);

    }else if( $transaction_status == 'pending' && in_array($payment_type, $channel)){

      $check = Veritrans_Transaction::status($response->order_id);

      $this->model_checkout_order->addOrderHistory($response->order_id,1);
      $this->cart->clear();
      $xl_tunai_instruction = "
      xl tunai payment instruction </br>
      XL Tunai </br>
      Instruction </br>
      1.  Dial *123*120# </br>
      2.  Reply '4' for 'Belanja Online' </br>
      3.  Input XL Tunai Merchant Code </br>
      4.  Input XL Tunai Order ID </br>
      5.  Input your XL Tunai PIN </br>
      6.  You will receive an SMS confirmation from XL";
      
      switch ($payment_type) {
        case "bank_transfer":
             
          if($check->transaction_status == "settlement"){

              $this->model_checkout_order->addOrderHistory($this->session->data['order_id'],2);
              $this->cart->clear();
              $redirUrl = $this->url->link('checkout/success&');
              $this->response->redirect($redirUrl);
              
            } 
          if(isset($response->va_numbers[0]->bank)){

            $data['data']= array(
            'payment_type' => $payment_type,  
            'payment_method' => "BCA Virtual Account",
            'instruction' => $base_url . $response->pdf_url,
            'payment_code' => $response->bca_va_number,
            );         
              
          }
          else{

            $data['data']= array(
            'payment_type' => $payment_type,
            'payment_method' => "Permata Virtual Account",
            'instruction' => $base_url . $response->pdf_url,
            'payment_code' => $response->permata_va_number,
            );         
              
          }

            break;
        case "echannel":

            if($check->transaction_status == "settlement"){

              $this->model_checkout_order->addOrderHistory($this->session->data['order_id'],2);
              $this->cart->clear();
              $redirUrl = $this->url->link('checkout/success&');
              $this->response->redirect($redirUrl);
              
            }

            $data['data']= array(
            'payment_type' => $payment_type,
            'payment_method' => "Mandiri Bill Payment",  
            'instruction'  => $base_url . $response->pdf_url,
            'company_code' => $response->biller_code,
            'payment_code' => $response->bill_key,
            );         

            break;
        case "cstore":

          if($check->transaction_status == "settlement"){

              $this->model_checkout_order->addOrderHistory($this->session->data['order_id'],2);
              $this->cart->clear();
              $redirUrl = $this->url->link('checkout/success&');
              $this->response->redirect($redirUrl);
              
            }

            $data['data']= array(
            'payment_type' => $payment_type,
            'payment_method' => "Indomaret",  
            'instruction'      => $base_url . $response->pdf_url,
            'payment_code' => $response->payment_code
            //'expire' => $response->indomaret_expire_time
            );         

            break;
        case "xl_tunai":
            
            
            if($check->transaction_status == "settlement"){

              $this->model_checkout_order->addOrderHistory($this->session->data['order_id'],2);
              $this->cart->clear();
              $redirUrl = $this->url->link('checkout/success&');
              $this->response->redirect($redirUrl);
              
            }
            else{

              $data['data']= array(
              'payment_type' => $payment_type,
              'payment_method' => "Xl Tunai",
              'instruction'      => $xl_tunai_instruction,
              'xl_tunai_order_id' => $response->xl_tunai_order_id,
              'merchant_code' => $response->xl_tunai_merchant_id,
              'expire' => $response->xl_expiration
              );         

            }
            break;
        }


      $this->document->setTitle('Payment has not complete yet!'); //Optional. Set the title of your web page.
           
   /*   // We call this Fallback system
      if (file_exists(DIR_TEMPLATE . $this->config->get('config_template') . '/template/payment/snap_exec.tpl')) { //if  file exists in your current template folder
          $this->template = $this->config->get('config_template') . '/template/payment/snap_exec.tpl'; //get it
      } else {
          $this->template = 'default/template/payment/snap_exec.tpl'; //or get the file from the default folder
      }
   */
      $data['column_left'] = $this->load->controller('common/column_left');
      $data['column_right'] = $this->load->controller('common/column_right');
      $data['content_top'] = $this->load->controller('common/content_top');
      $data['content_bottom'] = $this->load->controller('common/content_bottom');
      $data['footer'] = $this->load->controller('common/footer');
      $data['header'] = $this->load->controller('common/header');
      $this->response->setOutput($this->load->view('default/template/payment/snap_exec.tpl',$data));

    }
    else{
      $redirUrl = $this->url->link('payment/snap/failure','','SSL');
      $this->response->redirect($redirUrl); 
    }
    
  }

  /*
  * redirect to payment failure using template & language (text template)
  */
  public function failure() {
    $this->load->language('payment/snap');

    $this->document->setTitle($this->language->get('heading_title'));

    $data['heading_title'] = $this->language->get('heading_title');
    $data['text_failure'] = $this->language->get('text_failure');

    $data['column_left'] = $this->load->controller('common/column_left');
    $data['column_right'] = $this->load->controller('common/column_right');
    $data['content_top'] = $this->load->controller('common/content_top');
    $data['content_bottom'] = $this->load->controller('common/content_bottom');
    $data['footer'] = $this->load->controller('common/footer');
    $data['header'] = $this->load->controller('common/header');
    $data['checkout_url'] = $this->url->link('checkout/cart');

    if (file_exists(DIR_TEMPLATE . $this->config->get('config_template') . '/template/payment/snap_checkout_failure.tpl')) {
      $this->response->setOutput($this->load->view($this->config->get('config_template') . '/template/payment/snap_checkout_failure.tpl', $data));
    } else {
      $this->response->setOutput($this->load->view('default/template/payment/snap_checkout_failure.tpl', $data));
    }
  }

  /**
   * Called when snap server sends notification to this server.
   * It will change order status according to transaction status and fraud
   * status sent by snap server.
   */
  public function payment_notification() {

    Veritrans_Config::$serverKey = $this->config->get('snap_server_key');
    Veritrans_Config::$isProduction = $this->config->get('snap_environment') == 'production' ? true : false;

    $this->load->model('checkout/order');
    $this->load->model('payment/snap');
    $notif = new Veritrans_Notification();
    //error_log(print_r($notif,TRUE));
    $transaction = $notif->transaction_status;
    $fraud = $notif->fraud_status;
    $payment_type = $notif->payment_type;

    $logs = '';
    // error_log(print_r($notif,true)); // debugan
    if ($transaction == 'capture') {
      $logs .= 'capture ';
      if ($fraud == 'challenge') {
        $logs .= 'challenge ';
        $this->model_checkout_order->addOrderHistory(
            $notif->order_id,2,
            'Payment status challenged. Please take action on '
              . 'your Merchant Administration Portal.');
      }
      else if ($fraud == 'accept') {
        $logs .= 'accept ';
        $this->model_checkout_order->addOrderHistory(
            $notif->order_id,2,'Update from Snap Nofif capture');
      }
    }
    else if ($transaction == 'cancel') {
        $logs .= 'cancel ';
        $this->model_checkout_order->addOrderHistory(
            $notif->order_id,7,'Update cancel from snap notif.');
    }
    else if ($transaction == 'deny') {
      $logs .= 'deny ';
      $this->model_checkout_order->addOrderHistory(
          $notif->order_id,8,'Update Deny from snap notif.');
    }
	  else if ($transaction == 'pending') {
      $logs .= 'pending ';
      $this->model_checkout_order->addOrderHistory(
          $notif->order_id,1,'update pending from snap notif.');
    }
    else if ($transaction == 'expire') {
      $logs .= 'expire ';
      $this->model_checkout_order->addOrderHistory(
          $notif->order_id,7,'Update Expire from snap notif.');
    }
    else if ($transaction == 'settlement') {
          if($payment_type != 'credit_card'){
              $logs .= 'complete ';
              $this->model_checkout_order->addOrderHistory(
              $notif->order_id,2,'Update settlement from snap notif.');
          }
    }
    //error_log($logs); //debugan to be commented
  }
}
