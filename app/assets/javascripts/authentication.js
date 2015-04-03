$(document).ready(function() {

  $("#login-submit").click(function() {

    $.get("/api/login/" + $('textarea#token').val(), function(data, textStatus) {
      $("#login_response_status").html(textStatus)
      $("#login_response_sessionId").html(data.sessionId)
      $('textarea#current_sessionId').val(data.sessionId)
      $('#login_response_json').text(JSON.stringify(data, null, '\t'))
      $("#login_response").removeClass("hidden");
      $.cookie('sessionId', data.sessionId);
    }, "json");
  });

    $("#logout_submit").click(function() {
    $.ajax({
        url: '/api/logout',
        type: 'DELETE',
        headers: {
          sessionId: $('textarea#logout_sessionId').val()
        }
      })
      .done(function(data, textStatus) {
        $("#logout_response_status").html(textStatus)
        $("#logout_response").removeClass("hidden");
      });
  });
    
});
