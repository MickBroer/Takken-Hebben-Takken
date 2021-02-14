~images = Array.new;
~path = PathName(thisProcess.nowExecutingPath).parentPath;
PathName(~path ++ "images/").entries.collect{ |file|
	~images = ~images.add(Image.new(file.fullPath))};

(
var window = Window.new("test", Window.screenBounds);
var userView = UserView(window, window.bounds)
.animate_(true)
.background_(Color.white)
.clearOnRefresh_(false)
.frameRate_(60)
.drawFunc_({
	10.do{var pick = ~images.choose;
		pick.drawAtPoint(rrand(0,window.bounds.width)@rrand(0,window.bounds.height),
		Rect(rrand(0.001,window.bounds.width), rrand(0.001,window.bounds.height),
			500, 500))};
});
window.fullScreen;
window.front;
)