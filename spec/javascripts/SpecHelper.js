//= require_tree 

function fakeGame() {
  return {
    gameId: "95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa",
    notes: "Tier 4-5. Playing online using Skype and MapTools.",
    gm_name: "Ben Rady",
    gm_pic: "/img/preloader.gif",
    datetime: 1415221200000,
    title: "City of Golden Death (Online)",
    seats: [{name: 'adisney'}, {name: 'renedq'}],
  }
}

var game = fakeGame();
game.chronicle = {
      sheetUrl: "/game/95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa/chronicle.png",
      goldGained: 1847,
      prestigeGained: 2,
      xpGained: 1,
      eventCode: 35556,
      gmPfsNumber: 38803
    }

var gameList = [
  game, 
  _.extend({}, game, {
    "seats": [{name: 'adisney'}, {name: 'renedq'}, {name: 'renedq'}, {name: 'foo'}, {name: 'xyz'}, {name: 'abc'}]
  })
];

var userInfo = {
  pfsNumber: 38803, 
  name: 'Ben Rady', 
  pic: '/img/preloader.gif',
  signatureUrl: '/img/preloader.gif',
  initialsUrl: '/img/preloader.gif#init'
}

var fakeRoutes = {
  "/games": [gameList],
  "/user/info": [userInfo],
  "/games/detail?gameId=95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa": gameList,
  "/user/games": [{playing: [game], running: gameList}]
}

var body;

function loadFixture(path) {  
  var html;
  jQuery.ajax({
    url: '/index.html',
    success: function(result) {
      html = result;
    },
    async: false
  });          
  return $.parseHTML(html);
}

function resetBody() {
  if (!body) {
    fixture = $('<div>').append(loadFixture('/index.html'));
    body = $('<div class="fixtureBody" style="display: none">').append(fixture.find('div#markup'));
    $('body').append(body.clone());
  } else {
    $('.fixtureBody').replaceWith(body.clone());
  }
}

beforeEach(function () {
  resetBody();
  spyOn($, 'getJSON').and.callFake(function(url, callback) {  
    if (callback) {
      callback.apply(this, fakeRoutes[url]);
    } else {
      return jQuery.Deferred().resolve(fakeRoutes[url][0]);
    }
  })
});
