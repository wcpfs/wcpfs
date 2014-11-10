function routes() { 
  return { 
    message: messageView,
    newGame: newGame,
    home: homeView
  };
}

function messageView(msg) {
  var view = $('#templates .message-view').clone();
  view.find('.message').text(msg);
  return view;
}

function homeView() {
  function formatDate(timestamp) {
    date = new Date(+timestamp); // FIXME server should ensure this is a number
    return date.format("{Weekday}, {Month} {ord}")
  }

  function addGames(games) {
    var list = view.find('.game-list').empty();
    _.each(games, function(game) {  
      var gameItem = $('#templates .game-item').clone();
      _.each(game, function(v, k) {  
        gameItem.find('.' + k).text(v);
      });
      gameItem.find('.gm_profile_pic').attr('src', game.gm_pic)
      gameItem.find('.when').text(formatDate(game.datetime));
      gameItem.find('.seats-available').text(6 - game.seats.length);
      var playerList = gameItem.find('.player-list');
      _.each(game.seats, function (seat) {
        var playerItem = $('<li>').text(seat.name)
        playerList.append(playerItem);
      });
      var joinButton = gameItem.find('.join-button');
      if (game.seats.length < 6) {
        joinButton.attr('href', '/user/joinGame?gameId=' + game.gameId);
      } else {
        joinButton.prop('disabled', true).removeClass('btn-success').addClass('btn-danger').text("Game Full!");
      }
      list.append(gameItem);
    })
  }

  var view = $('#templates .home-view').clone();
  $.getJSON('/games', addGames);
  return view;
}

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
    input.val(date.getTime());
  }

  var view = $('#templates .new-game-view').clone();
  view.find('input').change(validate);
  view.find('input.datetime').change(parseDate);
  return view;
}
