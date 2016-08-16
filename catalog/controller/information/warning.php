<?php
class ControllerInformationWarning extends Controller {
    public function index() {        
        $this->document->setTitle('warning'); //Optional. Set the title of your web page.
        $message = "Sorry, we are unable to proceed your transaction with installment.<br>";
        $message .= $_GET["message"]==1?"Transaction with installment is only allowed for one product type on your cart.<br><br>":"Transaction with installment is only allowed for transaction amount above Rp 500.000 <br><br>";

        $data['breadcrumb']= array(
            'message'      => $message,
            'href'      => $_GET["redirLink"],
            'separator' => false
        );       
         
        // We call this Fallback system
        if (file_exists(DIR_TEMPLATE . $this->config->get('config_template') . '/template/information/warning.tpl')) { //if  file exists in your current template folder
            $this->template = $this->config->get('config_template') . '/template/information/warning.tpl'; //get it
        } else {
            $this->template = 'default/template/information/warning.tpl'; //or get the file from the default folder
        }
 
        //Required. The children files for the page.
       /* $this->children = array(
            'common/column_left',
            'common/column_right',
            'common/content_top',
            'common/content_bottom',
            'common/footer',
            'common/header'
        );*/
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['column_right'] = $this->load->controller('common/column_right');
		$data['content_top'] = $this->load->controller('common/content_top');
		$data['content_bottom'] = $this->load->controller('common/content_bottom');
		$data['footer'] = $this->load->controller('common/footer');
		$data['header'] = $this->load->controller('common/header');
        $this->response->setOutput($this->load->view('default/template/information/warning.tpl',$data));
    }
}
?>