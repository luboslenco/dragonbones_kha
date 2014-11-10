package dragonbones.objects;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class DBTransform {

	public function new() {
		x = 0;
		y = 0;
		skewX = 0;
		skewY = 0;
		scaleX = 1;
		scaleY = 1;
	}
	
	public var rotation(get, set):Float;
	public var x:Float;
	public var y:Float;
	public var skewX:Float;
	public var skewY:Float;
	public var scaleX:Float;
	public var scaleY:Float;
	
	function get_rotation():Float return skewX;
	
	function set_rotation(value:Float):Float {
		skewX = value;
		skewY = value;
		return value;
	}
	
	public function copy(transform:DBTransform) {
		x = transform.x;
		y = transform.y;
		skewX = transform.skewX;
		skewY = transform.skewY;
		scaleX = transform.scaleX;
		scaleY = transform.scaleY;
	}
}
