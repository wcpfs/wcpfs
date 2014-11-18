var game = {
    "gameId":"95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa",
    "notes":"Tier 4-5. Playing online using Skype and MapTools.",
    "gm_name":"Ben Rady",
    "gm_pic":"http://i.imgur.com/Ic08P8Vs.jpg",
    "datetime":1415221200000,
    "title":"City of Golden Death (Online)",
    "seats": [{name: 'adisney'}, {name: 'renedq'}],
    chronicle: "/game/95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa/chroncile.png"
  };

var gameList = [
  game, 
  _.extend({}, game, {
    "seats": [{name: 'adisney'}, {name: 'renedq'}, {name: 'renedq'}, {name: 'foo'}, {name: 'xyz'}, {name: 'abc'}]
  })
];

var fakeRoutes = {
  "/games": [gameList],
  "/games/detail?gameId=95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa": gameList,
  "/user/games": [{playing: [game], running: gameList}]
}

describe('WCPFS', function() {
  beforeEach(function() {
    spyOn($, 'getJSON').and.callFake(function(url, callback) {  
      callback.apply(this, fakeRoutes[url])
    })
  });

  it('can serve static views', function() {
    spyOn(window, 'currentView').and.returnValue('about');
    var view = staticView();
    expect(view.find('h2').text()).toEqual("About Windy City Pathfinder");
  });

  describe('Home View', function() {
    var view;
    beforeEach(function() {
      view = homeView();
    });

    it('Lists the available games', function() {
      expect(view.find('.game-list > li').length).toEqual(2);
    });

    describe('game items', function() {
      var item, fullGameItem;
      beforeEach(function() {
        item = view.find('.game-list > li:first');
        fullGameItem = view.find('.game-list > li:last');
      });

      it('includes the title', function() {
        expect(item.find('.title').text()).toEqual("City of Golden Death (Online)");
      });

      it('includes the date', function() {
        expect(item.find('.when').text()).toEqual("Wednesday, November 5th");
      });

      it('includes the button to join the game', function() {
        expect(item.find('.join-button').attr('href')).toEqual("/user/joinGame?gameId=95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa");
      });

      it('includes the game detail button', function() {
        expect(item.find('.detail-button').attr('href')).toEqual("/#gameDetail-95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa");
      });

      it('marks the game as full when there are 6 players', function() {
        var btn = fullGameItem.find('.join-button');
        expect(btn.attr('href')).toBeUndefined();
        expect(btn.hasClass('btn-danger')).toBeTruthy();
        expect(btn.prop('disabled')).toBeTruthy();
      });

      it('include the GM', function() {
        expect(item.find('.gm_name').text()).toEqual("Ben Rady");
        expect(item.find('.gm_profile_pic').attr('src')).toEqual('http://i.imgur.com/Ic08P8Vs.jpg');
      });

      it('adds the list of players', function() {
        expect(item.find('.player-list li').length).toEqual(2);
        expect(item.find('.player-list li:first').text()).toEqual('adisney');
      });

      it('includes the number of available seats', function() {
        expect(item.find('.seats-available').text()).toEqual('4');
      });
    });
  });

  describe("New Game View", function() {
    var view;
    beforeEach(function() {
      view = newGame();
    });

    it('disables the submit button until the fields are filled in', function() {
      expect(view.find('button.new-game-submit').prop('disabled')).toBeTruthy();
    });

    it('Enables the submit button when all fields are entered', function() {
      view.find('input.game-title').val('My Title').change();
      view.find('input.datetime').val('5pm February 13th, 2009').change();
      expect(view.find('button.new-game-submit').prop('disabled')).toBeFalsy();
    });

    it('parses the date and places the timestamp in a hidden field', function() {
      view.find('input.datetime').val('5pm February 13th, 2009').change();
      expect(view.find('input.datetime-hidden').val()).toEqual('1234566000000');
    });
  });

  describe('Message View', function() {
    it('shows a message', function() {
      var view = messageView("Hello World");
      expect(view.find('.message').text()).toEqual("Hello World");
    });
  });

  describe('GM Detail View', function() {
    var view;
    beforeEach(function() {
      view = gmDetailView(game.gameId);
    });

    it('Adds chronicle sheet to assets', function() {
      var item = view.find('.asset-list li:first a');
      expect(item.text()).toEqual("Chronicle Sheet");
      expect(item.attr('href')).toEqual(game.chronicle);
    });
  });

  describe('Game Detail View', function() {
    var view;
    beforeEach(function() {
      view = gameDetailView(game.gameId);
    });

    it('Adds the date for the game', function() {
      expect(view.find('.when').text()).toEqual('Wednesday, November 5th');
    });

    it('Adds the notes and other fields', function() {
      expect(view.find('.notes').text()).toEqual(game.notes);
    });

    it('Adds the join button', function() {
      expect(view.find('.join-button').text()).toEqual('Join Now!');
    });
    
  });

  describe('profile view', function() {
    var view;
    beforeEach(function() {
      view = profileView();
    });

    it('fetches the list of games playing', function() {
      expect(view.find('.games-playing li').length).toEqual(1);
      expect(view.find('.games-playing li:first a').text()).toEqual('City of Golden Death (Online)');
    });

    it('fetches the list of games running', function() {
      expect(view.find('.games-running li').length).toEqual(2);
      expect(view.find('.games-running li:first a').text()).toEqual('City of Golden Death (Online)');
    });

    it('Links to the GM view for games youre running', function() {
      expect(view.find('.games-running li:first a').attr('href')).toEqual('#gmDetail-' + game.gameId);
    });
  });
});
