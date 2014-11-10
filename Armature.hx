package dragonbones;
import dragonbones.animation.Animation;
import dragonbones.animation.AnimationState;
import dragonbones.animation.IAnimatable;
import dragonbones.animation.TimelineState;
import dragonbones.Bone;
import dragonbones.core.DBObject;
import dragonbones.events.SoundEventManager;
import dragonbones.Interfaces.IDisposable;
import dragonbones.Interfaces.INameable;
import dragonbones.objects.Frame;
import dragonbones.Slot;
import dragonbones.TypeDefs.DisplayObject;
//import dragonbones.TypeDefs.Event;
//import dragonbones.TypeDefs.EventDispatcher;
import dragonbones.TypeDefs.Sprite;
import dragonbones.utils.DisposeUtil;
using Lambda;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class Armature /*extends EventDispatcher*/ implements INameable implements IAnimatable implements IDisposable {
	
	static var _soundManager:SoundEventManager = SoundEventManager.instance;
	
	public function new(display:Sprite) {
		//super();
		this.display = display;
		animation = new Animation(this);
		slotsZOrderChanged = false;
		slotList = [];
		boneList = [];
		//eventList = [];
		_needUpdate = false;
	}
	
	public var name(default, default):String;
	public var display(default, null):Sprite;
	public var animation(default, null):Animation;
	public var userData:Dynamic;
	
	var _needUpdate:Bool;
	
	//{ region dragonBones_internal
	public var slotsZOrderChanged:Bool;
	public var slotList:Array<Slot>;
	public var boneList:Array<Bone>;
	//public var eventList:Array<Event>;
	//} endregion
	
	public function dispose() {
		if(animation == null) {
			return;
		}
		animation = DisposeUtil.dispose(animation);
		userData = null;
		for(it in slotList) DisposeUtil.dispose(it);
		for(it in boneList) DisposeUtil.dispose(it);
		slotList = DisposeUtil.dispose(slotList);
		boneList = DisposeUtil.dispose(boneList);
	}
	
	public function invalidUpdate() _needUpdate = true;
	
	public function addChild(child:DBObject, ?parentName:String) {
		if(child == null) {
			throw "error";//new ArgumentError("the child argument must not be null");
		}
		if(parentName != null) {
			var boneParent = getBone(parentName);
			if (boneParent == null) {
				throw "error";//new ArgumentError();
			}
			boneParent.addChild(child);
		} else {
			if(child.parent != null) {
				child.parent.removeChild(child);
			}
			child.setArmature(this);
		}
	}
	
	public function addBone(bone:Bone, ?parentName:String) addChild(bone, parentName);
	
	public function removeBone(bone:Bone) {
		if(bone == null) {
			throw "error";//new ArgumentError("the bone argument must not be null");
		} else if(!boneList.has(bone)) {
			throw "error";//new ArgumentError();
		}
		if(bone.parent != null) {
			bone.parent.removeChild(bone);
		} else {
			bone.setArmature(null);
		}
	}
	
	public function removeBoneByName(name:String) {
		if (name == null) {
			return;
		}
		var bone = getBone(name);
		if(bone != null) {
			removeBone(bone);
		}
	}
	
	public function getBones(returnCopy:Bool = true):Array<Bone> return returnCopy ? boneList.copy() : boneList;
	
	public function getBone(name:String):Bone {
		if(name == null) {
			return null;
		}
		for(bone in boneList) {
			if(bone.name == name) {
				return bone;
			}
		}
		return null;
	}
	
	public function getBoneByDisplay(display:DisplayObject):Bone {
		var slot = getSlotByDisplay(display);
		return slot != null ? slot.parent : null;
	}
	
	public function removeSlot(slot:Slot) {
		if(slot == null) {
			throw "error";//new ArgumentError("the slot argument must not be null");
		} else if (!slotList.has(slot)) {
			throw "error";//new ArgumentError();
		}
		slot.parent.removeChild(slot);
	}
	
	public function removeSlotByName(name:String) {
		if(name == null) {
			return;
		}
		var slot = getSlot(name);
		if(slot != null) {
			removeSlot(slot);
		}
	}
	
	public function getSlots(returnCopy:Bool = true):Array<Slot> return returnCopy ? slotList.copy() : slotList;
	
	public function getSlot(name:String):Slot {
		if(name == null) {
			return null;
		}
		for(it in slotList) {
			if(it.name == name) {
				return it;
			}
		}
		return null;
	}
	
	public function getSlotByDisplay(display:DisplayObject):Slot {
		if(display == null) {
			return null;
		}
		for(it in slotList) {
			if(it.display == display) {
				return it;
			}
		}
		return null;
	}
	
	public function advanceTime(passedTime:Float) {
		if(animation.isPlaying || _needUpdate) {	
			_needUpdate = false;
			animation.advanceTime(passedTime);
			passedTime *= animation.timeScale;
			var i = boneList.length;
			while(i --> 0) {
				boneList[i].update();
			}
			i = slotList.length;
			while(i --> 0) {
				var slot = slotList[i];
				slot.update();
				if(slot.isDisplayOnStage) {
					var childArmature = slot.childArmature;
					if(childArmature != null) {
						childArmature.advanceTime(passedTime);
					}
				}
			}
			if(slotsZOrderChanged) {
				updateSlotsZOrder();
				/*
				if(this.hasEventListener(ArmatureEvent.Z_ORDER_UPDATED))
				{
					this.dispatchEvent(new ArmatureEvent(ArmatureEvent.Z_ORDER_UPDATED));
				}
				*/
			}
			/*
			if(_eventList.length) {
				for each(var event:Event in _eventList) {
					this.dispatchEvent(event);
				}
				_eventList.length = 0;
			}
			*/
		} else {
			passedTime *= animation.timeScale;
			var i = slotList.length;
			while(i --> 0) {
				var slot = slotList[i];
				if(slot.isDisplayOnStage) {
					var childArmature = slot.childArmature;
					if(childArmature != null) {
						childArmature.advanceTime(passedTime);
					}
				}
			}
		}
	}
	
	public function updateSlotsZOrder() {
		slotList.sort(function(s1, s2):Int return s2.zOrder > s1.zOrder ? 1 : -1);
		var i = slotList.length;
		while(i --> 0) {
			var slot = slotList[i];
			if(slot.isDisplayOnStage) {
				slot.displayBridge.addDisplay(display);
			}
		}
		slotsZOrderChanged = false;
	}
	
	//{ region dragonBones_internal
	public function addDBObject(object:DBObject) {
		if(Std.is(object, Slot)) {
			var slot:Slot = cast(object, Slot);
			if(!slotList.has(slot)) {
				slotList[slotList.length] = slot;
			}
		} else if(Std.is(object, Bone)) {
			var bone:Bone = cast(object, Bone);
			if(!boneList.has(bone)) {
				boneList[boneList.length] = bone;
				sortBoneList();
			}
		}
	}
	
	public function removeDBObject(object:DBObject) {
		if(Std.is(object, Slot)) {
			slotList.remove(cast(object, Slot));
		} else if(Std.is(object, Bone)) {
			boneList.remove(cast(object, Bone));
		}
	}
	
	public function sortBoneList() {
		var i = boneList.length;
		if(i == 0) {
			return;
		}
		var helpArray:Array<Dynamic> = [];
		while(i --> 0) {
			var level = 0;
			var bone:Bone = boneList[i];
			var boneParent = bone;
			while(boneParent != null) {
				level++;
				boneParent = boneParent.parent;
			}
			helpArray[i] = { level:level, bone:bone };
		}
		helpArray.sort(function(a, b):Int return b.level - a.level);
		i = helpArray.length;
		while(i --> 0) {
			boneList[i] = helpArray[i].bone;
		}
	}
	
	public function arriveAtFrame(frame:Frame, timelineState:TimelineState, animationState:AnimationState, isCross:Bool) {
		//if(frame.event && this.hasEventListener(FrameEvent.ANIMATION_FRAME_EVENT))
		//{
		//	var frameEvent:FrameEvent = new FrameEvent(FrameEvent.ANIMATION_FRAME_EVENT);
		//	frameEvent.animationState = animationState;
		//	frameEvent.frameLabel = frame.event;
		//	_eventList.push(frameEvent);
		//}
		//
		//if(frame.sound && _soundManager.hasEventListener(SoundEvent.SOUND))
		//{
		//	var soundEvent:SoundEvent = new SoundEvent(SoundEvent.SOUND);
		//	soundEvent.armature = this;
		//	soundEvent.animationState = animationState;
		//	soundEvent.sound = frame.sound;
		//	_soundManager.dispatchEvent(soundEvent);
		//}
		if(frame.action != null && animationState.isPlaying) {
			animation.gotoAndPlay(frame.action);
		}
	}
	//} endregion
}
