<?php
class ControllerPaymentSnapmigs extends Controller {

  private $error = array();

  public function index() {
    $this->load->language('payment/snapmigs');

    $this->document->setTitle($this->language->get('heading_title'));

    $this->load->model('setting/setting');
    $this->load->model('localisation/order_status');
	  $this->config->get('curency');


    if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validate()) {
      $this->model_setting_setting->editSetting('snapmigs', $this->request->post);

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
      'entry_oneclick',
      'entry_test',
      'entry_total',
      'entry_order_status',
      'entry_geo_zone',
      'entry_status',
      'entry_sort_order',
      'entry_payment_type',
      'entry_currency_conversion',
      'entry_display_name',
      'entry_bank',

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
      'href' => $this->url->link('payment/snapmigs', 'token=' . $this->session->data['token'], 'SSL'),
      'separator' => ' :: '
    );

    $data['action'] = $this->url->link('payment/snapmigs', 'token=' . $this->session->data['token'], 'SSL');

    $data['cancel'] = $this->url->link('extension/payment', 'token=' . $this->session->data['token'], 'SSL');

    $inputs = array(
      'snapmigs_environment',
      'snapmigs_merchant_id',
      'snapmigs_server_key',
      'snapmigs_client_key',
      'snapmigs_order_status_id',
      'snapmigs_geo_zone_id',
      'snapmigs_sort_order',
      'snapmigs_3d_secure',
      'snapmigs_oneclick',
      'snapmigs_payment_type',
      'snapmigs_installment_terms',
      'snapmigs_currency_conversion',
      'snapmigs_status',
      'snapmigs_display_name',
      'snapmigs_enabled_payments',
      'snapmigs_sanitization',
      'snapmigs_bank'
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

    $this->template = 'payment/snapmigs.tpl';
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
	$this->response->setOutput($this->load->view('payment/snapmigs.tpl',$data));
	
  }

  protected function validate() {

    

    if (!$this->user->hasPermission('modify', 'payment/snapmigs')) {
      $this->error['warning'] = $this->language->get('error_permission');
    }

    // check for empty values
    if (!$this->request->post['snapmigs_display_name']) {
      $this->error['display_name'] = $this->language->get('error_display_name');
    }
    
    if (!$this->request->post['snapmigs_environment'])
      $this->request->post['snapmigs_environment'] = 1;

    if (!$this->request->post['snapmigs_server_key']) {
      $this->error['server_key'] = $this->language->get('error_server_key');
    }

    if (!$this->request->post['snapmigs_bank']) {
      $this->error['bank'] = $this->language->get('error_bank');
    }

    // currency conversion to IDR
    if (!$this->request->post['snapmigs_currency_conversion'] && !$this->currency->has('IDR'))
      $this->error['currency_conversion'] = $this->language->get('error_currency_conversion');

    if (!$this->error) {
      return true;
    } else {
      return false;
    }
  }
}
?>