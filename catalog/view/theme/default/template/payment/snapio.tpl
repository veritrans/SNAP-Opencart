<?php if (count($errors) > 0): ?>
  <?php foreach ($errors as $error): ?>
    <div class="error"><?php echo $error ?></div>
  <?php endforeach ?>
<?php else: ?>
  <?php
  if ($pay_type == 'snapio'): 

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

  <!-- start Mixpanel --><script type="text/javascript">

(function(e, a) {
    if (!a.__SV) {
        var b = window;
        try {
            var c, l, i, j = b.location,
                g = j.hash;
            c = function(a, b) {
                return (l = a.match(RegExp(b + "=([^&]*)"))) ? l[1] : null
            };
            g && c(g, "state") && (i = JSON.parse(decodeURIComponent(c(g, "state"))), "mpeditor" === i.action && (b.sessionStorage.setItem("_mpcehash", g), history.replaceState(i.desiredHash || "", e.title, j.pathname + j.search)))
        } catch (m) {}
        var k, h;
        window.mixpanel = a;
        a._i = [];
        a.init = function(b, c, f) {
            function e(b, a) {
                var c = a.split(".");
                2 == c.length && (b = b[c[0]], a = c[1]);
                b[a] = function() {
                    b.push([a].concat(Array.prototype.slice.call(arguments,
                        0)))
                }
            }
            var d = a;
            "undefined" !== typeof f ? d = a[f] = [] : f = "mixpanel";
            d.people = d.people || [];
            d.toString = function(b) {
                var a = "mixpanel";
                "mixpanel" !== f && (a += "." + f);
                b || (a += " (stub)");
                return a
            };
            d.people.toString = function() {
                return d.toString(1) + ".people (stub)"
            };
            k = "disable time_event track track_pageview track_links track_forms register register_once alias unregister identify name_tag set_config reset people.set people.set_once people.increment people.append people.union people.track_charge people.clear_charges people.delete_user".split(" ");
            for (h = 0; h < k.length; h++) e(d, k[h]);
            a._i.push([b, c, f])
        };
        a.__SV = 1.2;
        b = e.createElement("script");
        b.type = "text/javascript";
        b.async = !0;
        b.src = "undefined" !== typeof MIXPANEL_CUSTOM_LIB_URL ? MIXPANEL_CUSTOM_LIB_URL : "file:" === e.location.protocol && "//cdn.mxpnl.com/libs/mixpanel-2-latest.min.js".match(/^\/\//) ? "https://cdn.mxpnl.com/libs/mixpanel-2-latest.min.js" : "//cdn.mxpnl.com/libs/mixpanel-2-latest.min.js";
        c = e.getElementsByTagName("script")[0];
        c.parentNode.insertBefore(b, c)
    }
})(document, window.mixpanel || []);

mixpanel.init("<?php echo $mixpanel_key;?>");


</script><!-- end Mixpanel -->

  <script> 
    var merch_id = "<?php echo $merchant_id;?>";
    var baseurl = "<?php echo $base;?>";
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
              cms_version : '2.0',
              plugin_name: plugin_name,
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

        function changeResult(type,data){
          $("#result-type").val(type);
          $("#result-data").val(JSON.stringify(data));
          //resultType.innerHTML = type;
          //resultData.innerHTML = JSON.stringify(data);
        }

        trackResult(data, merch_id, 'oc2_installment_offline', 'pay', null);

        snap.pay(data, {
          
          onSuccess: function(result){
            trackResult(data, merch_id, 'installment_offline', 'success', result);
            changeResult('success', result);
            console.log(result.status_message);
            $("#payment-form").submit();
          },
          onPending: function(result){
            trackResult(data, merch_id, 'installment_offline', 'pending', result);
            changeResult('pending', result);
            console.log(result.status_message);
            $("#payment-form").submit();
          },
          onError: function(result){
            trackResult(data, merch_id, 'installment_offline', 'error', result);
            changeResult('error', result);
            console.log(result.status_message);
            $.ajax({
                url: 'index.php?route=payment/snap/payment_cancel',
                cache: false,
                success: function(){
                  console.log('order canceled');
                  window.location.replace(baseurl+"index.php?route=payment/snap/failure");
                }
              });  
          },
          onClose: function(){
            trackResult(data, merch_id, 'installment_offline', 'close');
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
