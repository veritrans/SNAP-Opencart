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
   <div class="panel panel-default">
    <div class="panel-heading">
	 <h3 class="panel-title"><i class="fa fa-pencil"></i> <?php echo $text_edit; ?></h3>
    </div>

   <!--error-->
   <?php if (isset($error['error_warning'])) { ?>
    <div class="alert alert-danger"><i class="fa fa-exclamation-circle"></i> <?php echo $error['error_warning']; ?>
     <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
   <?php } ?>
   <!--error-->

	<div class="panel-body">
	 <form action="<?php echo $action; ?>" method="post" enctype="multipart/form-data" id="form" class="form-horizontal">
	 <div class="form-group">
      <label class="col-sm-2 control-label" for="input-mode"><?php echo $entry_status; ?></label>
		<div class="col-sm-3">
		 <select name="snap_status" id="input-mode" class="form-control">
		  <?php $options = array('1' => $text_enabled, '0' => $text_disabled) ?>
		   <?php foreach ($options as $key => $value): ?>
		    <option value="<?php echo $key ?>" <?php if ($key == $snap_status) echo 'selected' ?> ><?php echo $value ?></option>
		   <?php endforeach ?>
		  </select>
		</div>
	 </div>
	<!-- Status -->

	<div class="form-group required">
	  <label class="col-sm-2 control-label" for="input-merchant-id"><?php echo $entry_display_name; ?></label>
	   <div class="col-sm-3">
		 <input type="text" name="snap_display_name" value="<?php echo $snap_display_name; ?>" id="input-merchant-id" class="form-control" />
	   </div>
	   <div class="col-sm-3">
	     <?php if (isset($error['display_name'])) { ?>
		  <div class="col-sm-3"> <?php echo $error['display_name']; ?> </div>
		 <?php } ?>
	   </div>
	</div>
	<!-- Display name -->

	<div class="form-group v2_settings sensitive required">
	  <label class="col-sm-2 control-label" for="input-mode"><?php echo $entry_environment; ?></label>
	    <div class="col-sm-3">
		  <select name="snap_environment" id="input-mode" class="form-control">
		    <?php $options = array('development' => 'Sandbox', 'production' => 'Production') ?>
			<?php foreach ($options as $key => $value): ?>
			  <option value="<?php echo $key ?>" <?php if ($key == $snap_environment) echo 'selected' ?> ><?php echo $value ?></option>
			<?php endforeach ?>
		  </select>
		</div>
		<div class="col-sm-3">
		<?php if (isset($error['environment'])) { ?>
		  <div class="col-sm-3"> <?php echo $error['environment']; ?> </div>
		<?php } ?>
		</div>
	</div>
	<!-- Environment (v2-specific) -->
	
	<div class="form-group required v2_settings sensitive">
	  <label class="col-sm-2 control-label" for="input-merchant-id"><?php echo $entry_merchant_id; ?></label>
	    <div class="col-sm-3">
		  <input type="text" name="snap_merchant_id" value="<?php echo $snap_merchant_id; ?>" id="input-merchant-id" class="form-control" />
		</div>
		<div class="col-sm-3">
		 <?php if (isset($error['merchant_id'])) { ?>
			<div class="col-sm-3"> <?php echo $error['merchant_id']; ?> </div>
		 <?php } ?>
		</div>
	</div>

	<div class="form-group required v2_settings sensitive">
	  <label class="col-sm-2 control-label" for="input-merchant-id"><?php echo $entry_client_key; ?></label>
	    <div class="col-sm-3">
		  <input type="text" name="snap_client_key" value="<?php echo $snap_client_key; ?>" id="input-merchant-id" class="form-control" />
		</div>
		<div class="col-sm-3">
		 <?php if (isset($error['client_key'])) { ?>
			<div class="col-sm-3"> <?php echo $error['client_key']; ?> </div>
		 <?php } ?>
		</div>
	</div>
	<!-- Client Key (v2-specific) -->


	<div class="form-group required v2_settings sensitive">
	  <label class="col-sm-2 control-label" for="input-merchant-id"><?php echo $entry_server_key; ?></label>
		<div class="col-sm-3">
		  <input type="text" name="snap_server_key" value="<?php echo $snap_server_key; ?>" id="input-merchant-id" class="form-control" />
		</div>
		<div class="col-sm-3">
		 <?php if (isset($error['server_key'])) { ?>
		   <div class="col-sm-3"> <?php echo $error['server_key']; ?> </div>
		 <?php } ?>
		</div>
	</div>
	<!-- Server Key (v2-specific) -->

	 <div class="form-group required v2_settings sensitive">
      <label class="col-sm-2 control-label" for="input-mode"><?php echo $entry_oneclick; ?></label>
		<div class="col-sm-3">
		 <select name="snap_oneclick" id="input-mode" class="form-control">
		  <?php $options = array('1' => $text_enabled, '0' => $text_disabled) ?>
		   <?php foreach ($options as $key => $value): ?>
		    <option value="<?php echo $key ?>" <?php if ($key == $snap_oneclick) echo 'selected' ?> ><?php echo $value ?></option>
		   <?php endforeach ?>
		  </select>
		</div>
	 </div>
	 <!-- One Click -->

	 <div class="form-group v2_settings sensitive">
	  <label class="col-sm-2 control-label" for="input-mode"><?php echo $entry_expiry; ?></label>
	    <div class="col-sm-3">
			<input type="text" name="snap_expiry_duration" placeholder="filled with number"  value="<?php echo $snap_expiry_duration; ?>" id="input-merchant-id" class="form-control" />
		</div>
	    <div class="col-sm-3">
		  <select name="snap_expiry_unit" id="input-mode" class="form-control">
		    <?php $options = array('minutes' => 'minutes', 'hour' => 'hour','day' => 'day') ?>
			<?php foreach ($options as $key => $value): ?>
			  <option value="<?php echo $key ?>" <?php if ($key == $snap_expiry_duration) echo 'selected' ?> ><?php echo $value ?></option>
			<?php endforeach ?>
		  </select>
		</div>
		<div class="col-sm-3">
		<?php if (isset($error['environment'])) { ?>
		  <div class="col-sm-3"> <?php echo $error['environment']; ?> </div>
		<?php } ?>
		</div>
	</div>
	<!-- custom expiry -->

	<div class="form-group required">
	 <label class="col-sm-2 control-label" for="input-merchant-id"><?php echo $entry_custom_field; ?></label>
	  <div class="col-sm-3">
	   <input type="text" name="snap_custom_field1" value="<?php echo $snap_custom_field1; ?>" class="form-control" />
	   <span> 'This will allow you to set custom fields that will be displayed on Midtrans dashboard.</span>
	  </div>
	  <div class="col-sm-3">
	   <input type="text" name="snap_custom_field2" value="<?php echo $snap_custom_field2; ?>" class="form-control" />
	  </div>
	  <div class="col-sm-3">
	   <input type="text" name="snap_custom_field3" value="<?php echo $snap_custom_field3; ?>" class="form-control" />
	  </div>
	  <div class="col-sm-12">
	  </div>
	</div>
	<!-- custom field  -->

	<div class="form-group required">
	 <label class="col-sm-2 control-label" for="input-merchant-id"><?php echo $entry_currency_conversion; ?></label>
	  <div class="col-sm-3">
	   <input type="text" name="snap_currency_conversion" value="<?php echo $snap_currency_conversion; ?>" class="form-control" />
		<span>Set to 1 if your default currency is IDR</span>
	  </div>
	  <div class="col-sm-3">
		<?php if (isset($error['currency_conversion'])) { ?>
		<div class="col-sm-3"> <?php echo $error['currency_conversion']; ?> </div>
		<?php } ?>
	  </div>
	</div>
	<!-- Currency -->

	<div class="form-group v2_vtweb_settings">
	 <label class="col-sm-2 control-label" for="input-merchant-id"><?php echo $entry_geo_zone; ?></label>
	  <div class="col-sm-3">
	   <select name="snap_geo_zone_id"  class="form-control">
		<option value="0"><?php echo $text_all_zones; ?></option>
		<?php foreach ($geo_zones as $geo_zone) { ?>
		  <?php if ($geo_zone['geo_zone_id'] == $snap_geo_zone_id) { ?>
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
	  <label class="col-sm-2 control-label" for="input-merchant-id"><?php echo $entry_sort_order; ?></label>
		<div class="col-sm-1">
		 <input size="1" type="text" name="snap_sort_order" value="<?php echo $snap_sort_order; ?>" class="form-control" />
		</div>
	</div>
	
	<div>
	 <center><font size="1">version 1.1</font></center>
	</div>

   </form>
  </div>
 </div>
</div>		<!-- content -->
</div>

<?php echo $footer; ?>
