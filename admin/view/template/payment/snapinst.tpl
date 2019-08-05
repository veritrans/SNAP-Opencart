<?php echo $header; ?><?php echo $column_left; ?>
<div id="content">

<!--header, breadcrumb & button-->
<div class="page-header">
  <div class="container-fluid">
   <div class="pull-right">
    <button type="submit" form="form-ppexpress" onclick="$('#form').submit();" data-toggle="tooltip" title="<?php echo $button_save; ?>" class="btn btn-primary"><i class="fa fa-save"></i></button>
    <a href="<?php echo $cancel; ?>" data-toggle="tooltip" title="<?php echo $button_cancel; ?>" class="btn btn-default"><i class="fa fa-reply"></i></a>
   </div>
   <h1><?php echo $heading_title; ?></h1>
   <ul class="breadcrumb">
    <?php foreach ($breadcrumbs as $breadcrumb) { ?>
     <li><a href="<?php echo $breadcrumb['href']; ?>"><?php echo $breadcrumb['text']; ?></a></li>
    <?php } ?>
   </ul>
  </div>
</div>
<!--header, breadcrumb & button-->

 <div class="container-fluid">
   <!--error-->
   <?php if ($error_warning) { ?>
    <div class="alert alert-danger"><i class="fa fa-exclamation-circle"></i> <?php echo error_warning; ?>
     <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
   <?php } ?>
   <!--error-->

    <div class="panel panel-default">
      <div class="panel-heading">
        <h3 class="panel-title"><i class="fa fa-pencil"></i> <?php echo $text_edit; ?></h3>
      </div>

	<div class="panel-body">
	 <form action="<?php echo $action; ?>" method="post" enctype="multipart/form-data" id="form" class="form-horizontal">
	 <div class="form-group">
      <label class="col-sm-2 control-label" for="input-status"><?php echo $entry_status; ?></label>
		<div class="col-sm-10">
		 <select name="snapinst_status" id="input-status" class="form-control">
		  <?php $options = array('1' => $text_enabled, '0' => $text_disabled) ?>
		   <?php foreach ($options as $key => $value): ?>
		    <option value="<?php echo $key ?>" <?php if ($key == $snapinst_status) echo 'selected' ?> ><?php echo $value ?></option>
		   <?php endforeach ?>
		  </select>
		</div>
	 </div>
	<!-- Status -->

	<div class="form-group required">
	  <label class="col-sm-2 control-label" for="input-display-name"><?php echo $entry_display_name; ?></label>
	   <div class="col-sm-10">
		 <input type="text" name="snapinst_display_name" value="<?php echo $snapinst_display_name; ?>" id="input-display-name" class="form-control" />
            <?php if ($error_display_name) { ?>
            <div class="text-danger"><?php echo $error_display_name; ?></div>
            <?php } ?>
	   </div>
	</div>
	<!-- Display name -->

	<div class="form-group sensitive">
	  <label class="col-sm-2 control-label" for="input-mode"><?php echo $entry_environment; ?></label>
	    <div class="col-sm-10">
		  <select name="snapinst_environment" id="input-mode" class="form-control">
		    <?php $options = array('development' => 'Sandbox', 'production' => 'Production') ?>
			<?php foreach ($options as $key => $value): ?>
			  <option value="<?php echo $key ?>" <?php if ($key == $snapinst_environment) echo 'selected' ?> ><?php echo $value ?></option>
			<?php endforeach ?>
		  </select>
		</div>
	</div>
	<!-- Environment (v2-specific) -->

	<div class="form-group required sensitive">
	  <label class="col-sm-2 control-label" for="input-merchant-id"><?php echo $entry_merchant_id; ?></label>
		<div class="col-sm-10">
		  <input type="text" name="snapinst_merchant_id" value="<?php echo $snapinst_merchant_id; ?>" id="input-merchant-id" class="form-control" />
            <?php if ($error_merchant) { ?>
            <div class="text-danger"><?php echo $error_merchant; ?></div>
            <?php } ?>
		</div>
	</div>
	<!-- Merchant Id (v2-specific) -->


	<div class="form-group required sensitive">
	  <label class="col-sm-2 control-label" for="input-server-key"><?php echo $entry_server_key; ?></label>
		<div class="col-sm-10">
		  <input type="text" name="snapinst_server_key" value="<?php echo $snapinst_server_key; ?>" id="input-server-key" class="form-control" />
            <?php if ($error_server_key) { ?>
            <div class="text-danger"><?php echo $error_server_key; ?></div>
            <?php } ?>
		</div>
	</div>
	<!-- Server Key (v2-specific) -->

	<div class="form-group required sensitive">
	  <label class="col-sm-2 control-label" for="input-client-key"><?php echo $entry_client_key; ?></label>
		<div class="col-sm-10">
		  <input type="text" name="snapinst_client_key" value="<?php echo $snapinst_client_key; ?>" id="input-client-key" class="form-control" />
            <?php if ($error_client_key) { ?>
            <div class="text-danger"><?php echo $error_client_key; ?></div>
            <?php } ?>
		</div>
	</div>
	<!-- Client Key (v2-specific) -->

	<div class="form-group required sensitive">
	  <label class="col-sm-2 control-label" for="input-min-txn"><span data-toggle="tooltip" title="<?php echo $help_min; ?>"><?php echo $entry_min_txn; ?></span></label>
		<div class="col-sm-10">
		  <input type="text" name="snapinst_min_txn" value="<?php echo $snapinst_min_txn; ?>" id="input-min-txn" class="form-control" />
            <?php if ($error_min_txn) { ?>
            <div class="text-danger"><?php echo $error_min_txn; ?></div>
            <?php } ?>
		</div>
	</div>
	<!-- Minimum Txn -->

	<div class="form-group">
	 <label class="col-sm-2 control-label" for="input-custom-field"><span data-toggle="tooltip" title="<?php echo $help_custom_field; ?>"><?php echo $entry_custom_field; ?></span></label>
	  <div class="col-sm-3">
	   <input type="text" name="snapinst_custom_field1" value="<?php echo $snapinst_custom_field1; ?>" class="form-control" />
	  </div>
	  <div class="col-sm-3">
	   <input type="text" name="snapinst_custom_field2" value="<?php echo $snapinst_custom_field2; ?>" class="form-control" />
	  </div>
	  <div class="col-sm-3">
	   <input type="text" name="snapinst_custom_field3" value="<?php echo $snapinst_custom_field3; ?>" class="form-control" />
	  </div>
	  <div class="col-sm-2"></div><div class="col-sm-10"><span>Leave it blank if you are not sure!</span></div>
	</div>
	<!-- Custom Field  -->

	<div class="form-group">
      <label class="col-sm-2 control-label" for="input-mixpanel"><?php echo $entry_mixpanel; ?></label>
		<div class="col-sm-10">
		 <select name="snapinst_mixpanel" id="input-mixpanel" class="form-control">
		  <?php $options = array('1' => $text_disabled, '0' => $text_enabled) ?>
		   <?php foreach ($options as $key => $value): ?>
		    <option value="<?php echo $key ?>" <?php if ($key == $snapinst_mixpanel) echo 'selected' ?> ><?php echo $value ?></option>
		   <?php endforeach ?>
		  </select>
		</div>
	 </div>
	 <!-- mixpanel -->

	<div class="form-group required">
	 <label class="col-sm-2 control-label" for="input-currency"><?php echo $entry_currency_conversion; ?></label>
	  <div class="col-sm-10">
	   <input type="text" name="snapinst_currency_conversion" value="<?php echo $snapinst_currency_conversion; ?>" class="form-control" />
		<span>Set to 1 if your default currency is IDR</span>
	  </div>
	</div>
	<!-- Currency -->

	<div class="form-group v2_vtweb_settings">
	 <label class="col-sm-2 control-label" for="input-geo-zone"><?php echo $entry_geo_zone; ?></label>
	  <div class="col-sm-10">
	   <select name="snapinst_geo_zone_id"  class="form-control">
		<option value="0"><?php echo $text_all_zones; ?></option>
		<?php foreach ($geo_zones as $geo_zone) { ?>
		  <?php if ($geo_zone['geo_zone_id'] == $snapinst_geo_zone_id) { ?>
		   <option value="<?php echo $geo_zone['geo_zone_id']; ?>" selected="selected"><?php echo $geo_zone['name']; ?></option>
		 <?php } else { ?>
		   <option value="<?php echo $geo_zone['geo_zone_id']; ?>"><?php echo $geo_zone['name']; ?></option>
		 <?php } ?>
		<?php } ?>
	   </select>
	  </div>
	</div>
	<!-- Geo Zone -->

	<div class="form-group">
	  <label class="col-sm-2 control-label" for="input-sort-order"><?php echo $entry_sort_order; ?></label>
		<div class="col-sm-2">
		 <input size="1" type="text" name="snapinst_sort_order" value="<?php echo $snapinst_sort_order; ?>" class="form-control" />
		</div>
	</div>
	<!-- Sort Order -->

   </form>
  </div>
 </div>
</div>		<!-- content -->
</div>

<?php echo $footer; ?>
