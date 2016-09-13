<?php if (count($errors) > 0): ?>
  <?php foreach ($errors as $error): ?>
    <div class="error"><?php echo $error ?></div>
  <?php endforeach ?>
<?php else: ?>
  <?php
  if ($pay_type == 'snapio'): 

  if($environment == 'production'){?>
    <script src="https://app.veritrans.co.id/snap/snap.js"></script>
  <?php
  }
  else{
    ?>
    <script src="https://app.sandbox.veritrans.co.id/snap/snap.js"></script>
  <?php
  }
  ?>

  <div class="pull-left">
    <h4>Transaction below <?php echo $min_txn?> will be treated as full payment</h4>
  </div>
  
  <form id="payment-form" method="post" action="index.php?route=payment/snap/landing_redir">
    <input type="hidden" name="result_type" id="result-type" value=""></div>
    <input type="hidden" name="result_data" id="result-data" value=""></div>
  <div class="buttons">

		<div class="pull-right"> 
    <input type="submit" value="<?php echo $button_confirm ?>" id="button-confirm" class="btn btn-primary " data-loading-text="<?php echo $text_loading; ?>"  />
    </form>
		</div>
	</div>

  <script> 
  
    $('#button-confirm').click(function (event) {
      event.preventDefault();
      $(this).attr("disabled", "disabled");
    
    $.ajax({
      url: 'index.php?route=payment/snapio/process_order',
      cache: false,
      beforeSend: function() {
        $('#button-confirm').button('loading');
      },
      complete: function() {
        $('#button-confirm').button('reset');
      },
      success: function(data) {
        //location = data;

        console.log('token = '+data);
        
        var resultType = document.getElementById('result-type');
        var resultData = document.getElementById('result-data');

        function changeResult(type,data){
          $("#result-type").val(type);
          $("#result-data").val(JSON.stringify(data));
          //resultType.innerHTML = type;
          //resultData.innerHTML = JSON.stringify(data);
        }

        snap.pay(data, {
          
          onSuccess: function(result){
            changeResult('success', result);
            console.log(result.status_message);
            $("#payment-form").submit();
          },
          onPending: function(result){
            changeResult('pending', result);
            console.log(result.status_message);
            $("#payment-form").submit();
          },
          onError: function(result){
            changeResult('error', result);
            console.log(result.status_message);
            $("#payment-form").submit();
          }
        });
      }
    });
  });
  </script>
    <!-- v2 VT-Web form -->

  <?php endif ?>
<?php endif ?>
