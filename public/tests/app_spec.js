var game = {
    "gameId":"95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa",
    "notes":"Tier 4-5. Playing online using Skype and MapTools.",
    "gm_name":"Ben Rady",
    "gm_pic":"http://i.imgur.com/Ic08P8Vs.jpg",
    "datetime":"0.14152212E13",
    "title":"City of Golden Death (Online)",
    "seats": [{name: 'adisney'}, {name: 'renedq'}]
  };
var gameList = [
  game, 
  _.extend({}, game, {
    "seats": [{name: 'adisney'}, {name: 'renedq'}, {name: 'renedq'}, {name: 'foo'}, {name: 'xyz'}, {name: 'abc'}]
  })
];

describe('Home View', function() {
  var view;
  beforeEach(function() {
    spyOn($, 'getJSON').and.callFake(function(url, callback) {  
      callback(gameList);
    })
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
      expect(item.find('.when').text()).toEqual("Wednesday 5 November, 2014 @ 3:00pm");
    });

    it('includes the button to join the game', function() {
      expect(item.find('.join-button').attr('href')).toEqual("/gm/joinGame?gameId=95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa");
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
