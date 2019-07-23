<?php //echo $header; ?><?php //echo $column_left; ?><?php //echo $column_right; ?>
<!-- <div id="content">
    <?php //echo $content_top; ?>
 	<h1>Warning</h1>
 	<div class="content">
 		<?php //echo $breadcrumb['message']; ?>
 	</div>
 	<div class="buttons">
    	<div class="right"><a href="<?php //echo $breadcrumb['href']; ?>" class="button">Continue with full payment</a></div>
  	</div>    
</div> -->
<?php //echo $footer; ?>

<?php echo $header; ?>
<div class="container">
  <div class="row"><?php echo $column_left; ?>
    <?php if ($column_left && $column_right) { ?>
    <?php $class = 'col-sm-6'; ?>
    <?php } elseif ($column_left || $column_right) { ?>
    <?php $class = 'col-sm-9'; ?>
    <?php } else { ?>
    <?php $class = 'col-sm-12'; ?>
    <?php } ?>

    <div id="content" class="<?php echo $class; ?>"><?php echo $content_top; ?>
      
      <?php
      switch ($data["payment_type"]) {
        case "bank_transfer":
          ?>
            <h1>Payment has not complete yet!</h1>
            your order has been received but has not been paid yet</br>
            you place order with <b><?=$data['payment_method']?></b></br>
            your va number : <b><?=$data['payment_code']?></b></br>
            For payment instruction click <a href="<?=$data['instruction']?>" target="blank">here<a></br>
          <?php
          break;
        case "echannel"
          ?>
            <h1>Payment has not complete yet!</h1>
            your order has been received but has not been paid yet</br>
            you place order with <b><?=$data['payment_method']?></b></br>
            your payment code and company code : <b><?=$data['payment_code']?></b> and <b><?=$data['company_code']?></b></br>
            For payment instruction click <a href="<?=$data['instruction']?>" target="blank">here<a></br>

          <?php
          break;
        case "cstore"
          ?>
            <h1>Payment has not complete yet!</h1>
            your order has been received but has not been paid yet</br>
            you place order with <b><?=$data['payment_method']?></b></br>
            your payment code : <b><?=$data['payment_code']?></b></br>
            For payment instruction click <a href="<?=$data['instruction']?>" target="blank">here<a></br>
          <?php
          break;
        case "bca_klikbca"
          ?>
            <h1>Payment has not complete yet!</h1>
            your order has been received but has not been paid yet</br>
            you place order with <b><?=$data['payment_method']?></b></br>
            Please complete your payment at <a href="http://www.klikbca.com">Klik Bca</a>
          <?php
          break;
        case "bca_klikpay"
          ?>
            <div class="container"><?php echo $content_top; ?>
              <h2 class="text-center">Payment Succeed!</h2>
              <p class="text-center">We've received your payment. Your order will be processed immediately</p>
              <?php echo $content_bottom; ?>
            </div>
          <?php echo $footer; ?>
          <?php
          break;
        default
          ?>
            <h1>Thank you. Your order has been received.</h1>
            you place order with <b><?=$data['payment_method']?></b></br>
          <?php
          break;
      }
      ?>
      
		      
	  </div>
      <?php echo $content_bottom; ?></div>
    <?php echo $column_right; ?></div>
</div>
<?php echo $footer; ?>