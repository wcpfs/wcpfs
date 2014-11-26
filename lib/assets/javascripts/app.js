//= require_tree
var userInfoPromise;

function routes() { 
  return { 
    message: messageView,
    newGame: newGame,
    gameDetail: gameDetailView,
    gmDetail: gmDetailView,
    about: staticView,
    communityUse: staticView,
    profile: profileView,
    home: homeView
  };
}

var _userInfoPromise;
function userInfoPromise() {
  if (_userInfoPromise) { return _userInfoPromise; }
  _userInfoPromise = $.getJSON('/user/info');
  return _userInfoPromise;
}

function reloadView() {
  showView(currentView());
}

function applyValues(obj, elem) {
  _.each(obj, function(v, k) {  
    elem.find('.' + k).text(v).val(v);
  });
}

function formatDate(timestamp) {
  date = new Date(timestamp); 
  return date.format("{Weekday}, {Month} {ord}")
}

function populateGameTemplate(game, elem) {
  function updateJoinButton(button) {
    if (game.seats.length < 6) {
      button.attr('href', '/user/joinGame?gameId=' + game.gameId);
    } else {
      button.prop('disabled', true).removeClass('btn-success').addClass('btn-danger').text("Game Full!");
    }
  }

  function updatePlayerList(playerList) {
    _.each(game.seats, function (seat) {
      var playerItem = $('<li>').text(seat.name)
      playerList.append(playerItem);
    });
  }

  applyValues(game, elem);
  elem.find('.gm_profile_pic').attr('src', game.gm_pic);
  elem.find('.when').text(formatDate(game.datetime));
  elem.find('.seats-available').text(6 - game.seats.length);
  var playerList = elem.find('.player-list');
  updatePlayerList(playerList);
  var joinButton = elem.find('.join-button');
  updateJoinButton(joinButton);
}

function staticView() {
  return $('#templates .' + currentView() + "-view").clone();
}

function messageView(msg) {
  var view = $('#templates .message-view').clone();
  view.find('.message').text(msg);
  return view;
}
