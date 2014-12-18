package dragonbones;
import dragonbones.animation.AnimationState;
import dragonbones.animation.TimelineState;
import dragonbones.Armature;
import dragonbones.core.DBObject;
import dragonbones.events.SoundEventManager;
import dragonbones.objects.Frame;
import dragonbones.Slot;
import dragonbones.display.NativeDisplayBridge;
import dragonbones.flash.DisplayObject;
import dragonbones.utils.DisposeUtil;
import dragonbones.flash.Point;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class Bone extends DBObject {

	static var _soundManager = SoundEventManager.instance;
	
	public function new() {
		super();
		children = [];
		_scaleType = 2;
		tweenPivot = new Point();
		scaleMode = 1;
	}
	
	public var scaleMode:Int;
	public var children(default, null):Array<DBObject>;
	public var slot(default, null):Slot;
	public var childArmature(get, null):Armature;
	public var display(get, set):DisplayObject;
	public var displayController:String;
	
	var _displayBridge:NativeDisplayBridge;
	
	function get_childArmature():Armature return slot != null ? slot.childArmature : null;
	
	function get_display():DisplayObject return slot != null ? slot.display : null;
	
	function set_display(value:DisplayObject):DisplayObject {
		if(slot != null) {
			slot.display = value;
		}
		return null;
	}
	
	override function set_visible(value:Bool):Bool {
		if(value == _visible) {
			_visible = value;
			var i = children.length;
			while(i --> 0) {
				var child = children[i];
				if(Std.is(child, Slot)) {
					cast(child, Slot).updateVisible(_visible);
				}
			}
		}
		return _visible;
	}
	
	public override function dispose() {
		if(children == null) {
			return;
		}
		super.dispose();
		for(i in children) DisposeUtil.dispose(i);
		children = DisposeUtil.dispose(children);
		slot = null;
		tweenPivot = null;
	}
	
	public function contains(child:DBObject):Bool {
		if(child == null) {
			throw "error";//new ArgumentError("the child argument must not be null");
		} else if(child == this) {
			return false;
		}
		while(child != this && child != null) {
			child = child.parent;
		}
		return child == this;
	}
	
	public function addChild(child:DBObject) {
		if(child == null) {
			throw "error";//new ArgumentError("the child argument must not be null");
		} else if(child == this || (Std.is(child, Bone) && cast(child, Bone).contains(this))) {
			throw "error";//new ArgumentError("An Bone cannot be added as a child to itself or one of its children (or children's children, etc.)");
		}
		if(child.parent != null) {
			child.parent.removeChild(child);
		}
		children[children.length] = child;
		child.setParent(this);
		child.setArmature(armature);
		if(slot == null && Std.is(child, Slot)) {
			slot = cast(child, Slot);
		}
	}
	
	public function removeChild(child:DBObject) {
		if(child == null) {
			throw "error";//new ArgumentError("the child argument must not be null");
		} else if(Lambda.has(children, child)) {
			//new ArgumentError();
		}
		children.remove(child);
		child.setParent(null);
		child.setArmature(null);
		if(child == slot) {
			slot = null;
		}
	}
	
	public function getSlots():Array<Slot> {
		var result:Array<Slot> = [];
		var i = children.length;
		while(i --> 0) {
			var child = children[i];
			if(Std.is(child, Slot)) {
				result.unshift(cast(child, Slot));
			}
		}
		return result;
	}
	
	//{ region dragonBones_internal
	public var tweenPivot:Point;
	
	override function setArmature(value:Armature) {
		super.setArmature(value);
		var i = children.length;
		while(i --> 0) {
			children[i].setArmature(armature);
		}
	}
	
	public function arriveAtFrame(frame:Frame, timelineState:TimelineState, animationState:AnimationState, isCross:Bool) {
		if(frame != null) {
			var mixingType = animationState.getMixingTransform(name);
			if(animationState.displayControl && (mixingType == 2 || mixingType == -1)) {
				if(displayController == null || displayController == animationState.name) {
					if(slot != null) {
						var tansformFrame:TransformFrame = cast(frame, TransformFrame);
						var displayIndex = tansformFrame.displayIndex;
						if(displayIndex >= 0) {
							if(tansformFrame.zOrder == tansformFrame.zOrder && tansformFrame.zOrder != slot.tweenZOrder) {
								slot.tweenZOrder = tansformFrame.zOrder;
								armature.slotsZOrderChanged = true;
							}
						}
						slot.changeDisplay(displayIndex);
						slot.updateVisible(tansformFrame.visible);
					}
				}
			}
			
			//if(frame.event != null && armature.hasEventListener(FrameEvent.BONE_FRAME_EVENT))
			//{
			//	var frameEvent:FrameEvent = new FrameEvent(FrameEvent.BONE_FRAME_EVENT);
			//	frameEvent.bone = this;
			//	frameEvent.animationState = animationState;
			//	frameEvent.frameLabel = frame.event;
			//	this._armature._eventList.push(frameEvent);
			//}
			//
			//if(frame.sound != null && _soundManager.hasEventListener(SoundEvent.SOUND))
			//{
			//	var soundEvent:SoundEvent = new SoundEvent(SoundEvent.SOUND);
			//	soundEvent.armature = this._armature;
			//	soundEvent.animationState = animationState;
			//	soundEvent.sound = frame.sound;
			//	_soundManager.dispatchEvent(soundEvent);
			//}
			
			if(frame.action != null) {
				for(it in children) {
					if(!Std.is(it, Slot)) {
						continue;
					}
					var childArmature = cast(it, Slot).childArmature;
					if(childArmature != null) {
						childArmature.animation.gotoAndPlay(frame.action);
					}
				}
			}
		} else if(slot != null) {
			slot.changeDisplay(-1);
		}
	}
	
	public function updateColor(aOffset:Float, rOffset:Float, gOffset:Float, bOffset:Float, aMultiplier:Float, rMultiplier:Float, gMultiplier:Float, bMultiplier:Float, isColorChanged:Bool) {
		if(this.isColorChanged || isColorChanged) {
			slot.displayBridge.updateColor(aOffset, rOffset, gOffset, bOffset, aMultiplier, rMultiplier, gMultiplier, bMultiplier);
		}
		this.isColorChanged = isColorChanged;
	}
	//} endregion
}
