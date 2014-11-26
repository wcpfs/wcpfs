describe('WCPFS', function() {
  it('can serve static views', function() {
    spyOn(window, 'currentView').and.returnValue('about');
    var view = staticView();
    expect(view.find('h2').text()).toEqual("About Windy City Pathfinder");
  });

  it('shows a message using the message view', function() {
    var view = messageView("Hello World");
    expect(view.find('.message').text()).toEqual("Hello World");
  });
});
