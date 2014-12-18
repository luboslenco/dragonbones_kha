package dragonbones;
import dragonbones.Interfaces.IDisposable;
import dragonbones.objects.DBTransform;
import dragonbones.flash.DisplayObject;
import dragonbones.flash.Matrix;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
interface INameable {
	public var name(default, default):String;
}

interface IDisposable {
	function dispose():Void;
}

interface IDisplayBridge extends IDisposable {
	public var visible(get, set):Bool;
	public var display(default, set):DisplayObject;
	
	function updateTransform(matrix:Matrix, transform:DBTransform):Void;
	function updateColor(aOffset:Float, rOffset:Float, gOffset:Float, bOffset:Float, aMultiplier:Float, rMultiplier:Float, gMultiplier:Float, bMultiplier:Float):Void;
	function updateBlendMode(blendMode:String):Void;
	function addDisplay(container:Dynamic, index:Int = -1):Void;
	function removeDisplay():Void;
}
