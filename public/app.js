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

function reloadView() {
  changeToView(currentView(), viewData());
}

function applyValues(obj, elem) {
  _.each(obj, function(v, k) {  
    elem.find('.' + k).text(v);
  });
}

function formatDate(timestamp) {
  date = new Date(+timestamp); // FIXME server should ensure this is a number
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
  elem.find('.gm_profile_pic').attr('src', game.gm_pic)
  elem.find('.when').text(formatDate(game.datetime));
  elem.find('.seats-available').text(6 - game.seats.length);
  var playerList = elem.find('.player-list');
  updatePlayerList(playerList);
  var joinButton = elem.find('.join-button');
  updateJoinButton(joinButton);
}

function uploadButton(gameId) {
  function uploadFile(file) {
    var data = new FormData();
    data.append('file', file);

    $.ajax({
      url: '/user/uploadPdf?gameId=' + gameId,
      type: 'POST',
      data: data,
      cache: false,
      processData: false, // Don't process the files
      contentType: false, // Set content type to false as jQuery will tell the server its a query string request
      success: reloadView,
      error: reloadView
    });
  }

  var button = $('#templates .upload-button').clone();
  button.find('.pdf-upload-input').change(function(e) {  
    button.prop('disabled', true);
    uploadFile(e.target.files[0]);
  });
  return button;
}


function profileView() {
  function gameItem(game, viewName) {
    var item = $('#templates .well-item-sm').clone();
    item.find('a').attr('href', '#' + viewName + '-' + game.gameId).text(game.title);
    return item;
  }

  function playerItem(game) {
    return gameItem(game, 'gameDetail');
  }

  function gmItem(game) {
    return gameItem(game, 'gmDetail');
  }

  var view = $('#templates .profile-view').clone();
  $.getJSON('/user/games', function(games) {  
    view.find('.games-playing').append(_.map(games.playing, playerItem));
    view.find('.games-running').append(_.map(games.running, gmItem));
  });

  return view;
}

function staticView() {
  return $('#templates .' + currentView() + "-view").clone();
}

function gmDetailView(gameId) {
  var view = $('#templates .game-detail-view').clone();
  function toGoogleIds(seat) {
    // body...
  }

  function showGame(game) {
    populateGameTemplate(game, view);
    view.find('.game-buttons').append(uploadButton(gameId));
    //view.find('.game-buttons').append($("<div id='hangout-placeholder'>"));
    //var ids = _.map(game.seats, toGoogleIds);
    //gapi.hangout.render('hangout-placeholder', { 
    //  render: 'createhangout',
    //  invites: ids
    //});
  }
  $.getJSON('/games/detail?gameId=' + gameId, showGame);
  view.find('.gm-option').show();
  view.find('.player-option').hide();
  return view;
}

function gameDetailView(gameId) {
  var view = $('#templates .game-detail-view').clone();
  function showGame(game) {
    populateGameTemplate(game, view);
  }
  $.getJSON('/games/detail?gameId=' + gameId, showGame);
  return view;
}

function messageView(msg) {
  var view = $('#templates .message-view').clone();
  view.find('.message').text(msg);
  return view;
}

function homeView() {
  function addGames(games) {
    var list = view.find('.game-list').empty();
    _.each(games, function(game) {  
      var gameItem = $('#templates .game-item').clone();
      populateGameTemplate(game, gameItem);
      gameItem.find('.detail-button').attr('href', '/#gameDetail-' + game.gameId);
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
