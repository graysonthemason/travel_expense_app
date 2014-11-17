$(document).on('page:change', function(){
    $("#ownerTitle").click(function(e){
        e.preventDefault();
        hideAll();
        $('.eventsOwned').css({display: ''});
        resetAllLinks();
        $("#ownerTitle").css({color: '#3D3D3D'});
    });
    $("#organizerTitle").click(function(e){
        e.preventDefault();
        hideAll();
        $('.eventsOrganized').css({display: ''});
        resetAllLinks();
        $("#organizerTitle").css({color: '#3D3D3D'});
    });
    $("#invitedTitle").click(function(e){
      e.preventDefault();
      hideAll();
      $('.eventsInvited').css({display: ''});
      resetAllLinks();
      $("#invitedTitle").css({color: '#3D3D3D'});
    });
    $("#allTitle").click(function(e){
      e.preventDefault();
      showAll();
      resetAllLinks();
      $("#allTitle").css({color: '#3D3D3D'});
    });
    $("#ownerTitle").hover(
      function() {
        $( this ).addClass( "hover" );
      }, function() {
        $( this ).removeClass( "hover" );
      }
    );
     $("#organizerTitle").hover(
      function() {
        $( this ).addClass( "hover" );
      }, function() {
        $( this ).removeClass( "hover" );
      }
    );
    $("#invitedTitle").hover(
      function() {
        $( this ).addClass( "hover" );
      }, function() {
        $( this ).removeClass( "hover" );
      }
    );
    $("#allTitle").hover(
      function() {
        $( this ).addClass( "hover" );
      }, function() {
        $( this ).removeClass( "hover" );
      }
    );
    $('tr').hover(
      function() {
        $( this ).addClass( "highlight" );
      }, function() {
        $( this ).removeClass( "highlight" );
      }
    );
});

function hideAll() {
    $('.eventsOwned').css({display: 'none'});
    $('.eventsOrganized').css({display: 'none'});
    $('.eventsInvited').css({display: 'none'});
}

function showAll() {
    $('.eventsOwned').css({display: ''});
    $('.eventsOrganized').css({display: ''});
    $('.eventsInvited').css({display: ''});
}

function resetAllLinks() {
  $("#ownerTitle").css({color: 'gray'})
  $("#organizerTitle").css({color: 'gray'})
  $("#invitedTitle").css({color: 'gray'})
  $("#allTitle").css({color: 'gray'})
}
