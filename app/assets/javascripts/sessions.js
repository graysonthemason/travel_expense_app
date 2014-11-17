$(document).on('page:change', function(){
  console.log("session.js loaded")
  $('#sign_up_button').click(function(e) {
      e.stopPropagation();
      e.preventDefault();
      $('#dialog_form').dialog( {
          show : "fadeIn",
          hide : "toggle",
          width: 550,
          height: 550,
          modal: true,
          title: "Sign Up"
      });
      $('#sign_up_submit_button').click(function(e) {
        e.stopPropagation();
        $('#dialog_form').dialog( "close" );
        setTimeout(function() {
          document.location.href = '/';
        }, 1000);
      });
          return false
  });
});
