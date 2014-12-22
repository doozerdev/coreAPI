$(document).ready(function() {

  $("#login-submit").click(function() {

    $.get("/api/login/" + $('textarea#token').val(), function(data, textStatus) {
      $("#login_response_status").html(textStatus)
      $("#login_response_session_id").html(data.session_id)
      $('textarea#current_session_id').val(data.session_id)
      $('#login_response_json').text(JSON.stringify(data, null, '\t'))
      $("#login_response").removeClass("hidden");
      $.cookie('session_id', data.session_id);
    }, "json");
  });

    $("#logout_submit").click(function() {
    $.ajax({
        url: '/api/logout',
        type: 'DELETE',
        data: {
          session_id: $('textarea#logout_session_id').val()
        }
      })
      .done(function(data, textStatus) {
        $("#logout_response_status").html(textStatus)
        $("#logout_response").removeClass("hidden");
      });
  });
    
});
