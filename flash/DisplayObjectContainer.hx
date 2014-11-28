package dragonbones.flash;

class DisplayObjectContainer extends DisplayObject {
	
	public var numChildren:Int;
	
	public function new () {
		
		super();
	}

	public override function addChild(item:composure.core.ComposeItem) {
		var obj = cast(item, DisplayObject);
		//obj.visible = true;

		if (item.parentItem != null) item.parentItem.removeChild(item);

		super.addChild(cast item);
		
		obj.transform.modified = true;
		obj.transform.update();
	}
	
	public function addChildAt(c:DisplayObject, pos:Int) {
	}

	public override function removeChild(item:composure.core.ComposeItem) {
		super.removeChild(cast item);
		//cast(item, DisplayObject).visible = false;
	}

	public function getChildIndex(c:DisplayObject):Int {
		return 0;
	}
}
