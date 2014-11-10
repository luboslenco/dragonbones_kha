package dragonbones.objects;
import dragonbones.Interfaces.IDisposable;
import dragonbones.utils.DisposeUtil;
import dragonbones.flash.ColorTransform;
import dragonbones.flash.Point;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class Frame implements IDisposable {

	public function new() {
		position = 0;
		duration = 0;
	}
	
	public var position:Float;
	public var duration:Float;
	public var action:String;
	public var event:String;
	public var sound:String;
	
	public function dispose() { 
	}
}

@:final class TransformFrame extends Frame {
	
	public function new() {
		super();
		tweenEasing = 0;
		tweenRotate = 0;
		displayIndex = 0;
		visible = true;
		zOrder = Math.NaN;
		global = new DBTransform();
		transform = new DBTransform();
		pivot = new Point();
	}
	
	public var tweenEasing:Float;
	public var tweenRotate:Int;
	public var displayIndex:Int;
	public var visible:Bool;
	public var zOrder:Float;
	public var global:DBTransform;
	public var transform:DBTransform;
	public var pivot:Point;
	public var color:ColorTransform;
	
	public override function dispose() {
		super.dispose();
		global = DisposeUtil.dispose(global);
		transform = DisposeUtil.dispose(transform);
		pivot = null;
		color = null;
	}
}
