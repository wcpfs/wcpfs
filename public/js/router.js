/**
 * Strapper View Events and Routing
 * http://github.com/benrady/strapper
 * benrady@gmail.com
 */

function triggerEvent(name, data, elem) {
  (elem || $('#content-main>*')).trigger(name, data);
}

function changeToView(name, data) {
  var newHash = "#" + name;
  if(data) {
    newHash += "-" + data;
  }
  window.location.hash = encodeURI(newHash);
}

function showView(name) {
  triggerEvent('viewOpen', name);
  $('#content-main').
    empty().
    append(routes()[name](viewData()));
}

function viewData() {
  var hash = decodeURI(window.location.hash.split('#')[1]);
  if(hash) {
    var data = hash.split('-');
    data.shift();
    return data.join('-');
  }
}

function currentView() {
  var hash = window.location.hash.split('#')[1];
  if(hash) {
    return hash.split('-')[0];
  }
  return 'home';
}

function routerOnReady() {
  window.onhashchange = function() {
    showView(currentView());
    return true;
  };
  showView(currentView());
}
