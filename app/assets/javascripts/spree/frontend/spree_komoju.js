SpreeKomoju = {
  addWebMoneyListener: function() {
    $("#checkout_form_payment input.webmoney_pin").keyup(function() {
      var length = $(this).val().length;
      if (length == 4) {
        $nextInput = $('input.webmoney_pin:eq(' + ($('input.webmoney_pin').index(this) + 1) + ')');
        $nextInput.focus();
      }
    });

    $("#checkout_form_payment").has("input.webmoney_pin").submit(function() {
      var prepaid_number = $("#ppn1").val() + $("#ppn2").val() + $("#ppn3").val() + $("#ppn4").val();
      $(this).find("input[name*=prepaid_number]").val(prepaid_number)
      $(this).find("input.webmoney_pin").prop('disabled', true)
    })
  }
}

$(document).ready(function() {
  SpreeKomoju.addWebMoneyListener();
})
