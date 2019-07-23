<?php if (count($errors) > 0): ?>
  <?php foreach ($errors as $error): ?>
    <div class="error"><?php echo $error ?></div>
  <?php endforeach ?>
<?php else: ?>
  <?php
  if ($pay_type == 'snapbin'): 

  if($environment == 'production'){?>
    <script src="https://app.midtrans.com/snap/snap.js" data-client-key="<?php echo $client_key;?>"></script>
  <?php
  }
  else{
    ?>
  <script src="https://app.sandbox.midtrans.com/snap/snap.js" data-client-key="<?php echo $client_key;?>"></script>
  <?php
  }
  ?>

  <form id="payment-form" method="post" action="index.php?route=payment/snap/landing_redir">
    <input type="hidden" name="result_type" id="result-type" value=""></div>
    <input type="hidden" name="result_data" id="result-data" value=""></div>
    <input type="hidden" name="result_origin" id="result-origin" value=""></div>
  <div class="buttons">

		<div class="pull-right"> 
    <input type="submit" value="<?php echo $button_confirm ?>" id="button-confirm" class="btn btn-primary " data-loading-text="<?php echo $text_loading; ?>"  />
    </form>
		</div>
	</div>

  <!-- start Mixpanel -->
  <script type="text/javascript">(function(c,a){if(!a.__SV){var b=window;try{var d,m,j,k=b.location,f=k.hash;d=function(a,b){return(m=a.match(RegExp(b+"=([^&]*)")))?m[1]:null};f&&d(f,"state")&&(j=JSON.parse(decodeURIComponent(d(f,"state"))),"mpeditor"===j.action&&(b.sessionStorage.setItem("_mpcehash",f),history.replaceState(j.desiredHash||"",c.title,k.pathname+k.search)))}catch(n){}var l,h;window.mixpanel=a;a._i=[];a.init=function(b,d,g){function c(b,i){var a=i.split(".");2==a.length&&(b=b[a[0]],i=a[1]);b[i]=function(){b.push([i].concat(Array.prototype.slice.call(arguments,0)))}}var e=a;"undefined"!==typeof g?e=a[g]=[]:g="mixpanel";e.people=e.people||[];e.toString=function(b){var a="mixpanel";"mixpanel"!==g&&(a+="."+g);b||(a+=" (stub)");return a};e.people.toString=function(){return e.toString(1)+".people (stub)"};l="disable time_event track track_pageview track_links track_forms track_with_groups add_group set_group remove_group register register_once alias unregister identify name_tag set_config reset opt_in_tracking opt_out_tracking has_opted_in_tracking has_opted_out_tracking clear_opt_in_out_tracking people.set people.set_once people.unset people.increment people.append people.union people.track_charge people.clear_charges people.delete_user people.remove".split(" ");for(h=0;h<l.length;h++)c(e,l[h]);var f="set set_once union unset remove delete".split(" ");e.get_group=function(){function a(c){b[c]=function(){call2_args=arguments;call2=[c].concat(Array.prototype.slice.call(call2_args,0));e.push([d,call2])}}for(var b={},d=["get_group"].concat(Array.prototype.slice.call(arguments,0)),c=0;c<f.length;c++)a(f[c]);return b};a._i.push([b,d,g])};a.__SV=1.2;b=c.createElement("script");b.type="text/javascript";b.async=!0;b.src="undefined"!==typeof MIXPANEL_CUSTOM_LIB_URL?MIXPANEL_CUSTOM_LIB_URL:"file:"===c.location.protocol&&"//cdn.mxpnl.com/libs/mixpanel-2-latest.min.js".match(/^\/\//)?"https://cdn.mxpnl.com/libs/mixpanel-2-latest.min.js":"//cdn.mxpnl.com/libs/mixpanel-2-latest.min.js";d=c.getElementsByTagName("script")[0];d.parentNode.insertBefore(b,d)}})(document,window.mixpanel||[]);mixpanel.init("<?php echo $mixpanel_key;?>");</script> 
  <!-- end Mixpanel -->

  <script> 
  
    var merch_id = "<?php echo $merchant_id;?>";
    var baseurl = "<?php echo $base;?>";

    $('#button-confirm').click(function (event) {
      event.preventDefault();
      $(this).attr("disabled", "disabled");
    
    $.ajax({
      url: 'index.php?route=payment/snapbin/process_order',
      cache: false,
      beforeSend: function() {
        $('#button-confirm').button('loading');
      },
      complete: function() {
        $('#button-confirm').button('reset');
      },
      success: function(data) {
        //location = data;

        function trackResult(token, merchant_id, plugin_name, status, result) {
          var eventNames = {
            pay: 'pg-pay',
            success: 'pg-success',
            pending: 'pg-pending',
            error: 'pg-error',
            close: 'pg-close'
          };
          mixpanel.track(
            eventNames[status], {
              merchant_id: merch_id,
              cms_name: 'Opencart',
              cms_version : '<?php echo $opencart_version; ?>',
              plugin_name: plugin_name,
              plugin_version: '<?php echo $mtplugin_version; ?>',
              snap_token: data,
              payment_type: result ? result.payment_type: null,
              order_id: result ? result.order_id: null,
              status_code: result ? result.status_code: null,
              gross_amount: result && result.gross_amount ? Number(result.gross_amount) : null,
            }
          );
        }


        console.log('token = '+data);
        
        var resultType = document.getElementById('result-type');
        var resultData = document.getElementById('result-data');

        function changeResult(type,data,origin){
          $("#result-type").val(type);
          $("#result-data").val(JSON.stringify(data));
          $("#result-origin").val(origin);
          //resultType.innerHTML = type;
          //resultData.innerHTML = JSON.stringify(data);
        }

        trackResult(data, merch_id, 'oc2_bin', 'pay', null);

        snap.pay(data, {
          
          onSuccess: function(result){
            trackResult(data, merch_id, 'oc2_cc_bin', 'success', result);
            changeResult('success', result, 'snapbin');
            console.log(result.status_message);
            $("#payment-form").submit();
          },
          onPending: function(result){
            trackResult(data, merch_id, 'oc2_cc_bin', 'pending', result);
            changeResult('pending', result, 'snapbin');
            console.log(result.status_message);
            $("#payment-form").submit();
          },
          onError: function(result){
            trackResult(data, merch_id, 'oc2_cc_bin', 'error', result);
            changeResult('error', result, 'snapbin');
            console.log(result.status_message);
            $.ajax({
                url: 'index.php?route=payment/snap/payment_cancel',
                cache: false,
                success: function(){
                  console.log('order canceled');
                  window.location.replace(baseurl+"index.php?route=payment/snap/failure");
                }
              });
            $("#payment-form").submit();
          },
          onClose: function(){
            trackResult(data, merch_id, 'oc2_cc_bin', 'close');
            var c =  confirm("close button clicked. Do you really want to cancel your transaction?");
            var baseurl = "<?php echo $base;?>";
            if (c == true){
              $.ajax({
                url: 'index.php?route=payment/snap/payment_cancel',
                cache: false,
                success: function(data){
                  console.log('order canceled');
                  window.location.replace(baseurl+"index.php?route=payment/snap/failure");
                }
              });  
            }
            else{
              document.getElementById("button-confirm").click();
            }
            
          }
        });
      }
    });
  });
  </script>
    <!-- v2 VT-Web form -->

  <?php endif ?>
<?php endif ?>
