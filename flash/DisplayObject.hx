package dragonbones.flash;

import kha.Image;

class DisplayObject {

	public var children:Array<DisplayObject> = [];
	public var numChildren(get, null):Int;
	public var parent:DisplayObject = null;

	public var visible:Bool = true;
	public var blendMode:String = "";
	public var texture:kha.Image;
	public var transform:Transform;

	public var x:Float = 0;
	public var y:Float = 0;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var rotation:Float = 0;
	public var pivotX:Float = 0;
	public var pivotY:Float = 0;
	public var w:Float = 0;
	public var h:Float = 0;
	public var a:Float = 1;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public var sourceX:Float = 0;
	public var sourceY:Float = 0;
	public var sourceW:Float;
	public var sourceH:Float;
	
	public function new (texture:Image) {
		this.texture = texture;

		transform = new Transform(this);

		if (texture != null) {
			sourceW = texture.width;
			sourceH = texture.height;

			w = texture.width;
			h = texture.height;
		}
	}

	function get_numChildren():Int {
		return children.length;
	}

	public function addChild(item:DisplayObject) {
		item.offsetX = offsetX;
		item.offsetY = offsetY;

		if (item.parent != null) item.parent.removeChild(item);

		item.parent = this;
		children.push(item);
	}
	
	public function addChildAt(c:DisplayObject, pos:Int) {
	}

	public function removeChild(item:DisplayObject) {
		children.remove(item);
	}

	public function getChildIndex(c:DisplayObject):Int {
		return 0;
	}

	public function render(g:kha.graphics2.Graphics) {
		var posX = x - (pivotX * scaleX) + offsetX;
		var posY = y - (pivotY * scaleY) + offsetY;

		g.color = kha.Color.White;
		g.opacity = a;

		var ox = posX + w / 2;
		var oy = posY + h / 2;
		var angle = Math.PI / 180 * rotation;

		if (angle != 0) g.pushRotation(angle, ox, oy);

		g.drawScaledSubImage(texture, sourceX, sourceY, sourceW, sourceH,
						     posX, posY, w * scaleX, h * scaleY);
		
		if (angle != 0) g.popTransformation();
	}
}
