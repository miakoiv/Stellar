$(function(){

  $("#cookie_alert.secondary-alert").on('mouseenter', function(e){
    $("#cookie_alert_text").show({effect: 'fade', duration: 500});
  });

  $("#cookie_alert.secondary-alert").on('mouseleave', function(e){
    $("#cookie_alert_text").hide({effect: 'fade', duration: 250});
  });
});
