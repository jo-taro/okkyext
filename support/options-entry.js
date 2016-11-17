var Options = require('../src/Options/Options.purs');
var debug = process.env.NODE_ENV === 'development'
var initialState = debug ? Options.initDebug : Options.init;

if (module.hot) {
	var app = Options[debug ? 'debug' : 'main'](window.puxLastState || initialState)();
	app.state.subscribe(function (state) {
	 window.puxLastState = state;
	});
	module.hot.accept();
} else {
	Options[debug ? 'debug' : 'main'](initialState)();
}
