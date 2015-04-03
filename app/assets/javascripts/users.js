$(document).ready(function() {

$("#update_user").click(function() {
    $.ajax({
      url: '/api/users/' + 
      $('#update_user_user_id').val(),
      type: 'PUT',
      headers: {sessionId: $('textarea#current_sessionId').val()},
      data: {
        role: $('#update_user_role').val()
        },
      dataType: "json"
    })
    .done(function(data, textStatus) {
      $("#update_user_response_status").html(textStatus)
      $('#update_user_response_json').text(JSON.stringify(data, null, '\t'))
    
    }).fail(function( jqXHR, textStatus ) {
      $("#update_user_response_status").html("<strong class='text-danger'>" + 
        jqXHR.status + ": " + textStatus + "</strong>")
    })
    .always(function(){
      $("#update_user_response").removeClass("hidden")
    });
  });

});