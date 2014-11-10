package dragonbones.flash;


class DisplayObjectContainer extends DisplayObject {
	
	public var numChildren:Int;
	
	public function new () {
		
		super();
	}

	//public function addChild(c:DisplayObject) {

	//}
	
	public function addChildAt(c:DisplayObject, pos:Int) {
		
	}

	//public function removeChild(c:DisplayObject) {

	//}

	public function getChildIndex(c:DisplayObject):Int {
		return 0;
	}
}
