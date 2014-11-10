package dragonbones;
import dragonbones.Armature;
import dragonbones.core.DBObject;
import dragonbones.TypeDefs.DisplayObject;
import dragonbones.Interfaces.IDisplayBridge;
import dragonbones.objects.DisplayData;
import dragonbones.utils.DisposeUtil;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class Slot extends DBObject {

	public function new(displayBridge:IDisplayBridge) {
		super();
		
		this.displayBridge = displayBridge;
		_displayList = [];
		_displayIndex = -1;
		_scaleType = 1;
		originZOrder = 0;
		tweenZOrder = 0;
		_offsetZOrder = 0;
		isDisplayOnStage = false;
		_isHideDisplay = false;
		_blendMode = "normal";
		if(displayBridge.display != null) {
			displayBridge.updateBlendMode(_blendMode);
		}
	}
	
	//{ region dragonBones_internal
	public var displayDataList:Array<DisplayData>;
	public var displayBridge:IDisplayBridge;
	public var originZOrder:Float;
	public var tweenZOrder:Float;
	public var isDisplayOnStage:Bool;
	//} endregion
	
	public var zOrder(get, set):Float;
	public var blendMode(get, set):String;
	public var display(get, set):DisplayObject;
	public var childArmature(get, set):Armature;
	public var displayList(get, set):Array<Dynamic>;
	
	var _isHideDisplay:Bool;
	var _offsetZOrder:Float;
	var _displayList:Array<Dynamic>;
	var _displayIndex:Int;
    var _blendMode:String;
	
	function get_zOrder():Float return originZOrder + tweenZOrder + _offsetZOrder;
	
	function set_zOrder(value:Float):Float {
		if(zOrder != value) {
			_offsetZOrder = value - originZOrder - tweenZOrder;
			if(armature != null) {
				armature.slotsZOrderChanged = true;
			}
		}
		return value;
	}
	
	function get_blendMode():String return _blendMode;
	
	function set_blendMode(value:String):String {
		if(_blendMode != value) {
			_blendMode = value;
			if (displayBridge.display != null) {
				displayBridge.updateBlendMode(_blendMode);
			}
		}
		return value;
	}
	
	function get_display():Dynamic {
		var display = _displayList[_displayIndex];
		if(Std.is(display, Armature)) {
			return display.display;
		}
		return display;
	}
	
	function set_display(value:Dynamic):Dynamic {
		_displayList[_displayIndex] = value;
		setDisplay(value);
		return value;
	}
	
	function get_childArmature():Armature {
		var result = _displayList[_displayIndex];
		if(Std.is(result, Armature)) {
			return cast(result, Armature);
		}
		return null;
	}
	
	function set_childArmature(value:Armature):Armature {
		_displayList[_displayIndex] = value;
		if(value != null) {
			setDisplay(value.display);
		}
		return value;
	}
	
	function get_displayList():Array<Dynamic> return _displayList;
	
	function set_displayList(value:Array<Dynamic>):Array<Dynamic> {
		if(value == null) {
			throw "error";//new ArgumentError("the value argument must not be null");
		}
		_displayList = value.copy();
		if(_displayIndex >= 0) {
			var displayIndexBackup = _displayIndex;
			_displayIndex = -1;
			changeDisplay(displayIndexBackup);
		}
		return _displayList;
	}
	
	override function set_visible(value:Bool):Bool {
		if(value != _visible) {
			_visible = value;
			updateVisible(_visible);
		}
		return _visible;
	}
	
	public override function dispose() {
		if(displayBridge == null) {
			return;
		}
		super.dispose();
		displayBridge = DisposeUtil.dispose(displayBridge);
		_displayList = DisposeUtil.dispose(_displayList);
		displayDataList = DisposeUtil.dispose(displayDataList);
	}
	
	public function changeDisplayList(displayList:Array<Dynamic>) this.displayList = displayList;
	
	function setDisplay(display:Dynamic) {
		if(displayBridge.display != null) {
			displayBridge.display = display;
		} else {
			displayBridge.display = display;
			if(armature != null) {
				displayBridge.addDisplay(armature.display);
				armature.slotsZOrderChanged = true;
			}
		}
		updateChildArmatureAnimation();
		if(!_isHideDisplay && displayBridge.display != null) {
			isDisplayOnStage = true;
			displayBridge.updateBlendMode(_blendMode);
		} else {
			isDisplayOnStage = false;
		}
	}
	
	function updateChildArmatureAnimation() {
		if(childArmature == null) {
			return;
		}
		if(_isHideDisplay) {
			childArmature.animation.stop();
		} else {
			if(armature != null && armature.animation.lastAnimationState != null && childArmature.animation.hasAnimation(armature.animation.lastAnimationState.name)) {
				childArmature.animation.gotoAndPlay(armature.animation.lastAnimationState.name);
			} else {
				childArmature.animation.play();
			}
		}
	}
	
	//{ region dragonBones_internal
	public function changeDisplay(displayIndex:Int) {
		if(displayIndex < 0) {
			if(!_isHideDisplay) {
				_isHideDisplay = true;
				displayBridge.removeDisplay();
				updateChildArmatureAnimation();
			}
		} else {
			var changeShowState = false;
			if(_isHideDisplay) {
				_isHideDisplay = false;
				changeShowState = true;
				
				if(armature != null) {
					displayBridge.addDisplay(armature.display);
					armature.slotsZOrderChanged = true;
				}
			}
			var length = _displayList.length;
			if(displayIndex >= length && length > 0) {
				displayIndex = length - 1;
			}
			if(_displayIndex != displayIndex) {
				_displayIndex = displayIndex;
				
				var content = _displayList[_displayIndex];
				if(Std.is(content, Armature)) {
					setDisplay(cast(content, Armature).display);
				} else {
					setDisplay(content);
				}
				
				if(displayDataList != null && _displayIndex <= displayDataList.length) {
					origin.copy(displayDataList[_displayIndex].transform);
				}
			} else if(changeShowState) {
				updateChildArmatureAnimation();
			}
		}
		isDisplayOnStage = !_isHideDisplay && displayBridge.display != null;
	}
	
	public override function setArmature(value:Armature) {
		super.setArmature(value);
		if(armature != null) {
			armature.slotsZOrderChanged = true;
			displayBridge.addDisplay(armature.display);
		} else {
			displayBridge.removeDisplay();
		}
	}
	
	public override function update() {
		super.update();
		if(isDisplayOnStage) {
			var pivotX = parent.tweenPivot.x;
			var pivotY = parent.tweenPivot.y;
			if(pivotX != 0 || pivotY != 0) {
				var matrix = parent.globalTransformMatrix;
				globalTransformMatrix.tx += matrix.a * pivotX + matrix.c * pivotY;
				globalTransformMatrix.ty += matrix.b * pivotX + matrix.d * pivotY;
			}
			displayBridge.updateTransform(globalTransformMatrix, global);
		}
	}
	
	public function updateVisible(value:Bool) displayBridge.visible = parent.visible && visible && value;
	//} endregion
}
