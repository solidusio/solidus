Spree.onCouponCodeApply = function(e) {
  e.preventDefault();
  var couponCodeField = $("#order_coupon_code");
  var couponCode = $.trim(couponCodeField.val());
  if (couponCode === "") {
    return;
  }
  var couponStatus = $("#coupon_status");
  var successClass = "success";
  var errorClass = "alert";
  couponStatus.removeClass([successClass, errorClass].join(" "));
  var data = {
    order_token: Spree.current_order_token,
    coupon_code: couponCode
  };
  var req = Spree.ajax({
    method: 'POST',
    url: Spree.pathFor('api/orders/' + Spree.current_order_id + '/coupon_codes'),
    data: JSON.stringify(data),
    contentType: "application/json"
  });
  req.done(function(data) {
    window.location.reload();
    couponCodeField.val("");
    couponStatus
      .addClass(successClass)
      .html("Coupon code applied successfully.");
  });
  req.fail(function(xhr) {
    var handler;
    // handler = JSON.parse(xhr.responseText)
    handler = xhr.responseJSON;
    couponStatus.addClass(errorClass).html(handler["error"]);
  });
};

Spree.ready(function($) {
  $("#coupon-code-apply-button").click(function(e) {
    Spree.onCouponCodeApply(e);
  });
});
