package dragonbones.objects;
import dragonbones.Interfaces.IDisposable;
import dragonbones.Interfaces.INameable;
import dragonbones.utils.DisposeUtil;
import dragonbones.flash.Point;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
@:final class DisplayData implements INameable implements IDisposable {
	public static inline var ARMATURE = "armature";
	public static inline var IMAGE = "image";
	
	public function new() {
		transform = new DBTransform();
	}
	
	public var name(default, default):String;
	public var type:String;
	public var transform:DBTransform;
	public var pivot:Point;
	
	public function dispose() {
		transform = DisposeUtil.dispose(transform);
		pivot = DisposeUtil.dispose(pivot);
	}	
}
