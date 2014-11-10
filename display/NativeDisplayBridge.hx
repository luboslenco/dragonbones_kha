package dragonbones.display;
import dragonbones.Interfaces.IDisplayBridge;
import dragonbones.objects.DBTransform;
import dragonbones.TypeDefs.DisplayObject;
import dragonbones.TypeDefs.DisplayObjectContainer;
import dragonbones.flash.ColorTransform;
import dragonbones.flash.Matrix;
import dragonbones.flash.Transform;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class NativeDisplayBridge implements IDisplayBridge {

	public function new() {
	}
	
	public var display(default, set):DisplayObject;
	public var visible(get, set):Bool;
	var _displayTransform:Transform;
	var _colorTransform:ColorTransform;
	
	function set_display(value:DisplayObject):DisplayObject {
		if (value == display) {
			return value;
		}
		var index:Int = 0;
		var parent:DisplayObjectContainer = null;
		if (display != null) {
			parent = cast display.parent;
			if (parent != null) {
				index = parent.getChildIndex(display);
			}
			removeDisplay();
		}
		display = value;
		if(display != null)  {
			_displayTransform = display.flashTransform;
		} else {
			_displayTransform = null;
		}
		addDisplay(parent, index);
		return value;
	}
	
	function get_visible():Bool return display != null ? display.visible : false;
	
	function set_visible(value:Bool) {
		if(display != null) {
			display.visible = value;
			return value;
		}
		return false;
	}
	
	public function dispose() {
		display = null;
		_colorTransform = null;
		_displayTransform = null;
	}
	
	public function updateTransform(matrix:Matrix, transform:DBTransform) {
		_displayTransform.matrix = matrix;
	}
	
	public function updateColor(aOffset:Float, rOffset:Float, gOffset:Float, bOffset:Float, aMultiplier:Float, rMultiplier:Float, gMultiplier:Float, bMultiplier:Float) {
		if(_colorTransform != null) {
			_colorTransform = _displayTransform.colorTransform;
		}
		_colorTransform.alphaOffset = aOffset;
		_colorTransform.redOffset = rOffset;
		_colorTransform.greenOffset = gOffset;
		_colorTransform.blueOffset = bOffset;
		_colorTransform.alphaMultiplier = aMultiplier;
		_colorTransform.redMultiplier = rMultiplier;
		_colorTransform.greenMultiplier = gMultiplier;
		_colorTransform.blueMultiplier = bMultiplier;
		_displayTransform.colorTransform = _colorTransform;
	}
	
	public function updateBlendMode(blendMode:String) display.blendMode = blendMode;
	
	public function addDisplay(container:DisplayObjectContainer, index:Int = -1) {
		if (container != null && display != null) {
			if(index < 0) {
				container.addChild(display);
			} else {
				container.addChildAt(display, index >= container.numChildren ? container.numChildren : index);
			}
		}
	}
	
	public function removeDisplay() {
		if(display != null && display.parent != null) {
			display.parent.removeChild(display);
		}
	}
}
