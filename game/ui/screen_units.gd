extends RefCounted
## Keep UI in readable window/CSS pixels while preserving the world's stretch.


static func factor(viewport: Viewport) -> float:
	var width := float(viewport.get_window().size.x)
	if OS.has_feature("web"):
		width = float(JavaScriptBridge.eval("window.innerWidth", true))
	return viewport.get_visible_rect().size.x / maxf(width, 1.0)
