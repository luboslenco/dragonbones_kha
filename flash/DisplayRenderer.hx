package dragonbones.flash;

import kha.Image;

import fox.math.Rect;
import fox.core.Trait;
import fox.core.IRenderable2D;
import fox.trait.Transform;

class DisplayRenderer extends Trait implements IRenderable2D {

	//@inject({desc:false,sibl:true})
	public var transform:Transform;
	public var source:Rect;

	// TODO: move to transform
	public var angle:Float = 0;
	public var ox:Float = 0;
	public var oy:Float = 0;

	// TODO: get image real width and set transform size to source size
	public var image:Image;

	var obj:DisplayObject;

	public function new(image:Image, obj:DisplayObject) {
		super();

		this.obj = obj;

		this.image = image;
		source = new Rect(0, 0, image.width, image.height);
	}

	@injectAdd
    public function addTransform(trait:Transform) {
        transform = trait;

        transform.w = image.width;
		transform.h = image.height;
    }

	public function render(g:kha.graphics2.Graphics) {

		transform.x = obj.x - (obj.pivotX * obj.scaleX);
		transform.y = obj.y - (obj.pivotY * obj.scaleY);
		transform.scale.x = obj.scaleX;
		transform.scale.y = obj.scaleY;

		ox = transform.absx + transform.w / 2;
		oy = transform.absy + transform.h / 2;
		angle = fox.math.Math.degToRad(obj.rotation);

		transform.modified = true;
		transform.update();

		g.color = transform.color;
		g.opacity = transform.a;

		// TODO: count scale into w
		if (angle != 0) g.pushRotation(angle, ox, oy);
		
		g.drawScaledSubImage(image, source.x, source.y, source.w, source.h,
						     transform.absx, transform.absy,
						     transform.w * transform.scale.x,
						     transform.h * transform.scale.y);
		
		if (angle != 0) g.popTransformation();
	}
}
