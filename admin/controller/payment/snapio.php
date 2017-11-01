<?php
class ControllerPaymentSnapio extends Controller {

  private $error = array();

  public function index() {
    $this->load->language('payment/snapio');

    $this->document->setTitle($this->language->get('heading_title'));

    $this->load->model('setting/setting');
    $this->load->model('localisation/order_status');
	  $this->config->get('curency');


    if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validate()) {
      $this->model_setting_setting->editSetting('snapio', $this->request->post);

      $this->session->data['success'] = $this->language->get('text_success');

      $this->response->redirect($this->url->link('extension/payment', 'token=' . $this->session->data['token'], 'SSL'));
    }

    $language_entries = array(

      'heading_title',
      'text_enabled',
      'text_disabled',
      'text_yes',
      'text_live',
      'text_successful',
      'text_fail',
      'text_all_zones',
	    'text_edit',

      'entry_api_version',
      'entry_environment',
      'entry_merchant_id',
      'entry_server_key',
      'entry_client_key',
      'entry_hash',
      'entry_test',
      'entry_total',
      'entry_order_status',
      'entry_geo_zone',
      'entry_status',
      'entry_sort_order',
      'entry_3d_secure',
      'entry_payment_type',
      'entry_enable_bank_installment',
      'entry_currency_conversion',
      'entry_client_key',
      'entry_snapio_success_mapping',
      'entry_snapio_failure_mapping',
      'entry_snapio_challenge_mapping',
      'entry_display_name',
      'entry_min_txn',

      'button_save',
      'button_cancel'
      );

    foreach ($language_entries as $language_entry) {
      $data[$language_entry] = $this->language->get($language_entry);
    }

    if (isset($this->error)) {
      $data['error'] = $this->error;
    } else {
      $data['error'] = array();
    }

    $data['breadcrumbs'] = array();

    $data['breadcrumbs'][] = array(
      'text' => $this->language->get('text_home'),
      'href' => $this->url->link('common/home', 'token=' . $this->session->data['token'], 'SSL'),
      'separator' => false
    );

    $data['breadcrumbs'][] = array(
      'text' => $this->language->get('text_payment'),
      'href' => $this->url->link('extension/payment', 'token=' . $this->session->data['token'], 'SSL'),
      'separator' => ' :: '
    );

    $data['breadcrumbs'][] = array(
      'text' => $this->language->get('heading_title'),
      'href' => $this->url->link('payment/snapio', 'token=' . $this->session->data['token'], 'SSL'),
      'separator' => ' :: '
    );

    $data['action'] = $this->url->link('payment/snapio', 'token=' . $this->session->data['token'], 'SSL');

    $data['cancel'] = $this->url->link('extension/payment', 'token=' . $this->session->data['token'], 'SSL');

    $inputs = array(
      'snapio_environment',
      'snapio_merchant_id',
      'snapio_server_key',
      'snapio_client_key',
      'snapio_test',
      'snapio_total',
      'snapio_order_status_id',
      'snapio_geo_zone_id',
      'snapio_sort_order',
      'snapio_3d_secure',
      'snapio_payment_type',
      'snapio_installment_terms',
      'snapio_currency_conversion',
      'snapio_status',
      'midtrans_snapio_success_mapping',
      'midtrans_snapio_failure_mapping',
      'midtrans_snapio_challenge_mapping',
      'snapio_display_name',
      'snapio_enabled_payments',
      'snapio_sanitization',
      'snapio_min_txn'
    );

    foreach ($inputs as $input) {
      if (isset($this->request->post[$input])) {
        $data[$input] = $this->request->post[$input];
      } else {
        $data[$input] = $this->config->get($input);
      }
    }

    $this->load->model('localisation/order_status');

    $data['order_statuses'] = $this->model_localisation_order_status->getOrderStatuses();

    $this->load->model('localisation/geo_zone');

    $data['geo_zones'] = $this->model_localisation_geo_zone->getGeoZones();

    $this->template = 'payment/snapio.tpl';
	$data['column_left'] = $this->load->controller('common/column_left');
	$data['header'] = $this->load->controller('common/header');
	$data['footer'] = $this->load->controller('common/footer');
	
	
	if(!$this->currency->has('IDR'))
	{
		$data['curr'] = true;
	}
	else
	{
		$data['curr'] = false;
	}
	$this->response->setOutput($this->load->view('payment/snapio.tpl',$data));
	
  }

  protected function validate() {

    // Override version to v2
    $version = 2;

    // temporarily always set the payment type to vtweb if the api_version == 2
    if ($version == 2)
      $this->request->post['snapio_payment_type'] = 'vtweb';

    $payment_type = $this->request->post['snapio_payment_type'];
    if (!in_array($payment_type, array('vtweb', 'vtdirect')))
      $payment_type = 'vtweb';

    if (!$this->user->hasPermission('modify', 'payment/snapio')) {
      $this->error['warning'] = $this->language->get('error_permission');
    }

    // check for empty values
    if (!$this->request->post['snapio_display_name']) {
      $this->error['display_name'] = $this->language->get('error_display_name');
    }

    // version-specific validation
    if ($version == 1)
    {
      // check for empty values
      if ($payment_type == 'vtweb')
      {
        if (!$this->request->post['snapio_merchant']) {
          $this->error['merchant'] = $this->language->get('error_merchant');
        }

        if (!$this->request->post['snapio_hash']) {
          $this->error['hash'] = $this->language->get('error_hash');
        }
      } else
      {
        if (!$this->request->post['snapio_client_key']) {
          $this->error['client_key'] = $this->language->get('error_client_key');
        }

        if (!$this->request->post['snapio_server_key']) {
          $this->error['server_key'] = $this->language->get('error_server_key');
        }
      }
    } else if ($version == 2)
    {
      // default values
      if (!$this->request->post['snapio_environment'])
        $this->request->post['snapio_environment'] = 1;

      if (!$this->request->post['snapio_server_key']) {
        $this->error['server_key'] = $this->language->get('error_server_key');
      }
    }

    // currency conversion to IDR
    if (!$this->request->post['snapio_currency_conversion'] && !$this->currency->has('IDR'))
      $this->error['currency_conversion'] = $this->language->get('error_currency_conversion');

    if (!$this->error) {
      return true;
    } else {
      return false;
    }
  }
}
?>