package dragonbones.objects;
import dragonbones.Interfaces.IDisposable;
import dragonbones.Interfaces.INameable;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
@:final class BoneData implements INameable implements IDisposable {

	public function new() {
		length = 0;
		global = new DBTransform();
		transform = new DBTransform();
		scaleMode = 1;
		fixedRotation = false;
	}
	
	public var name(default, default):String;
	public var parent:String;//TODO: parent name
	public var length:Float;
	public var global:DBTransform;
	public var transform:DBTransform;
	public var scaleMode:Int;
	public var fixedRotation:Bool;
	
	public function dispose() {
		name = null;
		parent = null;
		length = 0;
		global = null;
		transform = null;
		scaleMode = 0;
		fixedRotation = false;
	}
}
