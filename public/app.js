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

function imageEditor(game) {
  var editor = $('#templates .image-editor').clone();
  var canvasElem = editor.find('canvas').get(0);
  var canvas;

  function addImage(url, positions) {
    fabric.Image.fromURL(url, function(oImg) {
      _.each(positions, function(pos) {  
        img = fabric.util.object.clone(oImg);
        img.set({
          top: pos.top,
          hasControls: false,
          hasRotatingPoint: false,
          left: pos.left
        });
        canvas.add(img);
      });
    });
  }

  function addEntry(name, value, left, top) {
    if (value === undefined) { value = ''; }
    var text = new fabric.Text(value.toString(), {
      fontFamily: "Permanent Marker",
      hasControls: false,
      hasRotatingPoint: false,
      fontSize: 14,
      fontWeight: 'normal',
      left: left,
      top: top
    });
    canvas.add(text);
    var item = $('#templates .chronicle-item').clone();
    item.find('.field-name').text(name);
    item.find('.field-value').val(value).change(function() {  
      text.set({text: $(this).val()});
      canvas.renderAll();
    });
    editor.find('.chronicle-form').append(item);
  }

  fabric.Image.fromURL(game.chronicle.sheetUrl, function(oImg) {
    canvas = new fabric.Canvas(canvasElem, {
      backgroundImage: oImg,
      width: oImg.width,
      height: oImg.height
    });
    addEntry('Date', new Date(game.datetime).format('{d} {Mon} {yyyy}'), 235, 748);
    addEntry('Gold Gained', game.chronicle.goldGained, 510, 580);
    addEntry('Prestige Gained', game.chronicle.prestigeGained, 510, 428);
    addEntry('XP Gained', game.chronicle.xpGained, 510, 315);

    userInfoPromise().done(function(userInfo) {  
      addEntry('Event Code', game.chronicle.eventCode, 172, 748);
      addEntry('Event Name', game.chronicle.eventName, 68, 748);
      addEntry('GM PFS #', userInfo.pfsNumber, 500, 748);
      addImage(userInfo.signatureUrl, [{top: 745, left: 332}]);
      addImage(userInfo.initialsUrl, [ 
        {top: 315, left: 560},
        {top: 427, left: 560},
        {top: 580, left: 560}
      ]);
    })

    editor.find('.save-btn').click(function() {  
      $(this).attr({href: canvas.toDataURL(), download: game.title + '.png'});
    });

    canvas.renderAll();
  });
  return editor;
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

  function profileInfo() {
    return {
      pfsNumber: view.find('.pfsNumber').val(),
      signatureUrl: view.find('.signatureUrl').val(),
      initialsUrl: view.find('.initialsUrl').val()
    }
  }

  var view = $('#templates .profile-view').clone();
  $.getJSON('/user/games', function(games) {  
    view.find('.games-playing').append(_.map(games.playing, playerItem));
    view.find('.games-running').append(_.map(games.running, gmItem));
  });

  userInfoPromise().done(function(data) { 
    applyValues(data, view.find('.profile-info'));
    updateImages();
  });

  function updateImages() {
    view.find('.signature-img').attr('src', profileInfo().signatureUrl);
    view.find('.initials-img').attr('src', profileInfo().initialsUrl);
  }

  view.find('.signatureUrl').change(updateImages);
  view.find('.initialsUrl').change(updateImages);

  view.find('.save-btn').click(function() {  
    $.ajax({
      method: 'post',
      url: '/user/info', 
      data: JSON.stringify(profileInfo()),
      contentType: 'application/json'
    });
    return false;
  });

  return view;
}

function staticView() {
  return $('#templates .' + currentView() + "-view").clone();
}

function gmDetailView(gameId) {
  var view = $('#templates .game-detail-view').clone();

  function assetItem(link, text) {
    var item = $('#templates .well-item-sm').clone();
    item.find('a').attr('href', link).text(text);
    return item;
  }

  function showGame(game) {
    populateGameTemplate(game, view);
    var chronicleSheetElem = $('#templates .chronicle-sheet').clone();
    if (game.chronicle.sheetUrl) {
      chronicleSheetElem.append(imageEditor(game));
    }
    view.append(chronicleSheetElem);
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
