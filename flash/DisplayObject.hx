package dragonbones.flash;

class DisplayObject extends fox.core.Object {

	//public var parent:DisplayObjectContainer;

	public var visible:Bool = true;
	public var blendMode:String = "";

	public var texture:kha.Image;

	public var flashTransform:Transform;

	public var x:Float = 0;
	public var y:Float = 0;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var rotation:Float = 0;
	public var pivotX:Float = 0;
	public var pivotY:Float = 0;
	
	public function new () {
		super();

		flashTransform = new Transform(this);

		// TODO: remove
		addTrait(new DisplayUpdater());
	}
}

class DisplayUpdater extends fox.core.Trait implements fox.core.IUpdateable {

	@inject
	var transform:fox.trait.Transform;

	@inject
	var renderer:fox.trait2d.ImageRenderer;

	public function new() {
		super();
	}

	public function update() {
		var p = cast(parent, DisplayObject);

		//if (!p.visible) return;

		transform.x = p.x - (p.pivotX * p.scaleX);
		transform.y = p.y - (p.pivotY * p.scaleY);
		transform.scale.x = p.scaleX;
		transform.scale.y = p.scaleY;

		//if (renderer != null) {
		//	renderer.ox = transform.absx + transform.w / 2;
		//	renderer.oy = transform.absy + transform.h / 2;
		//	renderer.angle = fox.math.Math.degToRad(p.rotation);
		//}
	}
}
