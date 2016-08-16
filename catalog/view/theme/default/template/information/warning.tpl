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
       <h2><?php echo 'Warning' ?></h2> 
        <?php echo $breadcrumb['message']; ?>
      <div class="buttons">
		<div class="right"><a href="<?php echo $breadcrumb['href']; ?>" class="button">Continue with full payment</a></div>      
	  </div>
      <?php echo $content_bottom; ?></div>
    <?php echo $column_right; ?></div>
</div>
<?php echo $footer; ?>