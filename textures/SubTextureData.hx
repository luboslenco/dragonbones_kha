package dragonbones.textures;

import dragonbones.flash.Rectangle;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 * 1.4
 */
class SubTextureData extends Rectangle{

	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) {
		super(x, y, width, height);
		pivotX = 0;
		pivotY = 0;
	}
	
	public var pivotX:Int;
	public var pivotY:Int;
}
