function newGame() {
  function isInputFilled(elem) {
    return $(elem).val().length > 0; 
  }

  function validate() {
    var isValid = _.every(view.find('input.required'), isInputFilled);
    view.find('button.new-game-submit').prop('disabled', !isValid);
  }

  function parseDate() {
    var input = view.find('input.datetime-hidden');
    var date = Date.create($(this).val());
    if (date.clone().beginningOfDay().is(date)) {
      date.advance('12 hours');
    } 
    input.val(date.getTime());
  }

  var view = $('#templates .new-game-view').clone();
  view.find('input').change(validate);
  view.find('input.datetime').change(parseDate);
  return view;
}
