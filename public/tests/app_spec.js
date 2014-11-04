var gameList = [
  {
    "gameId":"95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa",
    "notes":"Tier 4-5. Playing online using Skype and MapTools.",
    "GM":"benrady",
    "datetime":"0.14152212E13",
    "title":"City of Golden Death (Online)",
    "seats": ['adisney']
  }
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
    expect(view.find('.game-list li').length).toEqual(1);
  });

    describe('game items', function() {
      var item;
      beforeEach(function() {
        item = view.find('.game-list li:first');
      });

      it('includes the title', function() {
        expect(item.find('.title').text()).toEqual("City of Golden Death (Online)");
      });

      it('includes the date', function() {
        expect(item.find('.when').text()).toEqual("Wednesday 5 November, 2014 @ 3:00pm");
      });

      it('include the GM', function() {
        expect(item.find('.GM').text()).toEqual("benrady");
      });

      it('includes the number of available seats', function() {
        expect(item.find('.seats-available').text()).toEqual('5');
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
