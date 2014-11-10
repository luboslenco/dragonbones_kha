package dragonbones.animation;
import dragonbones.Armature;
import dragonbones.events.SoundEventManager;
import dragonbones.Interfaces.IDisposable;
import dragonbones.objects.AnimationData;
import dragonbones.objects.DBTransform;
import dragonbones.utils.DisposeUtil;
import dragonbones.flash.Point;
using Lambda;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class Animation implements IDisposable {

	public static inline var NONE = "none";
	public static inline var SAME_LAYER = "sameLayer";
	public static inline var SAME_GROUP = "sameGroup";
	public static inline var SAME_LAYER_AND_GROUP = "sameLayerAndGroup";
	public static inline var ALL = "all";
	
	static var _soundManager:SoundEventManager = SoundEventManager.instance;
	
	public function new(armature:Armature) {
		_armature = armature;
		animationLayer = [];
		animationList = [];
		isPlaying = false;
		_isActive = false;
		tweenEnabled = true;
		timeScale = 1;
	}
	
	public var tweenEnabled(default, null):Bool;
	public var animationList(default, null):Array<String>;
	public var movementID(get, null):String;
	public var lastAnimationState(default, null):AnimationState;
	public var movementList(get, null):Array<String>;
	public var isPlaying(get, null):Bool;
	public var isComplete(get, null):Bool;
	public var animationDataList(default, set):Array<AnimationData>;
	public var timeScale(default, set):Float;
	
	var _armature:Armature;
	var _isActive:Bool;
	
	//{ region dragonBones_internal
	public var animationLayer:Array<Array<AnimationState>>;
	//} endregion
	
	function get_movementList():Array<String> return animationList;
	
	function get_movementID():String return lastAnimationState != null ? lastAnimationState.name : null;
	
	function get_lastAnimationState():AnimationState return lastAnimationState;
	
	function get_isPlaying():Bool return isPlaying && _isActive;
	
	function get_isComplete():Bool {
		if(lastAnimationState == null || !lastAnimationState.isComplete) {
			return false;
		}
		for(layer in animationLayer) {
			for(it in layer) {
				if(!it.isComplete) {
					return false;
				}
			}
		}
		return true;
	}
	
	function set_animationDataList(value:Array<AnimationData>):Array<AnimationData> {
		animationDataList = value;
		animationList = [];
		for(it in animationDataList) {
			animationList[animationList.length] = it.name;
		}
		return animationDataList;
	}
	
	function set_timeScale(value:Float):Float {
		timeScale = value < 0 ? 0 : value;
		return timeScale;
	}
	
	public function dispose() {
		if(_armature == null) {
			return;
		}
		stop();
		for(layer in animationLayer) {
			for(it in layer) {
				AnimationState.returnObject(it);
			}
		}
		animationLayer = DisposeUtil.dispose(animationLayer);
		_armature = null;
		animationDataList = null;
		animationList = null;
	}
	
	public function gotoAndPlay(animationName:String, fadeInTime:Float = -1, duration:Float = -1, ?loop:Float, layer:Int = 0, ?group:String, fadeOutMode:String = SAME_LAYER_AND_GROUP, displayControl:Bool = true, pauseFadeOut:Bool = true, pauseFadeIn:Bool = true):AnimationState {
		if (animationDataList == null) {
			return null;
		}
		
		var animationData:AnimationData = null;
		var i = animationDataList.length;
		while(i --> 0) {
			if(animationDataList[i].name == animationName) {
				animationData = animationDataList[i];
				break;
			}
		}
		if (animationData == null) {
			return null;
		}
		
		isPlaying = true;
		fadeInTime = fadeInTime < 0 ? (animationData.fadeInTime < 0 ? 0.3 : animationData.fadeInTime) : fadeInTime;
		
		var durationScale:Float;
		if(duration < 0) {
			durationScale = animationData.scale < 0 ? 1 : animationData.scale;
		} else {
			durationScale = duration / animationData.duration;
		}
		
		loop = loop == null || loop != loop ? animationData.loop : loop;
		layer = addLayer(layer);
		
		switch(fadeOutMode) {
			case NONE:
			case SAME_LAYER:
				var animationStateList = animationLayer[layer];
				for(it in animationStateList) {
					it.fadeOut(fadeInTime, pauseFadeOut);
				}
			case SAME_GROUP:
				for(layer in animationLayer) {
					for(it in layer) {
						if(it.group == group) {
							it.fadeOut(fadeInTime, pauseFadeOut);
						}
					}
				}
			case ALL:
				for(layer in animationLayer) {
					for(it in layer) {
						it.fadeOut(fadeInTime, pauseFadeOut);
					}
				}
			case SAME_LAYER_AND_GROUP, _:
				var animationStateList = animationLayer[layer];
				for(it in animationStateList) {
					if(it.group == group) {
						it.fadeOut(fadeInTime, pauseFadeOut);
					}
				}
		}
		lastAnimationState = AnimationState.borrowObject();
		lastAnimationState.group = group;
		lastAnimationState.tweenEnabled = tweenEnabled;
		lastAnimationState.fadeIn(_armature, animationData, fadeInTime, 1 / durationScale, Std.int(loop), layer, displayControl, pauseFadeIn);
		addState(lastAnimationState);
		var i = _armature.slotList.length;
		while(i --> 0) {
			var slot = _armature.slotList[i];
			if(slot.childArmature != null) {
				slot.childArmature.animation.gotoAndPlay(animationName, fadeInTime);
			}
		}
		lastAnimationState.advanceTime(0);
		return lastAnimationState;
	}
	
	public function play() {
		if (animationDataList == null || animationDataList.empty()) {
			return;
		} else if(lastAnimationState == null) {
			gotoAndPlay(animationDataList[0].name);
		} else if (!isPlaying) {
			isPlaying = true;
		} else {
			gotoAndPlay(lastAnimationState.name);
		}
	}
	
	public function stop() {
		isPlaying = false;
		lastAnimationState = null;
	}
	
	public function getState(name:String, layer:Int = 0):AnimationState {
		var i = animationLayer.length;
		if(i == 0) {
			return null;
		} else if(layer >= i) {
			layer = i - 1;
		}
		var animationStateList = animationLayer[layer];
		if(animationStateList == null) {
			return null;
		}
		for(it in animationStateList) {
			if(it.name == name) {
				return it;
			}
		}
		return null;
	}
	
	public function hasAnimation(name:String):Bool {
		for(it in animationDataList) {
			if(it.name == name) {
				return true;
			}
		}
		return false;
	}
	
	public function advanceTime(passedTime:Float) {
		passedTime *= timeScale;
		
		var l:Int = _armature.boneList.length;
		var k:Int = l;
		var animationState:AnimationState;
		var transform:DBTransform;
		var pivot:Point;
		
		l--;
		while(k --> 0) {
			var bone = _armature.boneList[k];
			var boneName = bone.name;
			var weigthLeft:Float = 1;
			var x:Float = 0;
			var y:Float = 0;
			var skewX:Float = 0;
			var skewY:Float = 0;
			var scaleX:Float = 0;
			var scaleY:Float = 0;
			var pivotX:Float = 0;
			var pivotY:Float = 0;
			var i = animationLayer.length;
			while(i --> 0) {
				var layerTotalWeight:Float = 0;
				var animationStateList = animationLayer[i];
				var stateListLength = animationStateList.length;
				var j = 0;
				while(j < stateListLength) {
					animationState = animationStateList[j];
					if(k == l && animationState.advanceTime(passedTime)) {
						removeState(animationState);
						stateListLength--;
						continue;
					}
					var timelineState = animationState._timelineStates.get(boneName);
					if(timelineState != null && timelineState.tweenActive) {
						var weight = animationState._fadeWeight * animationState.weight * weigthLeft;
						transform = timelineState.transform;
						pivot = timelineState.pivot;
						x += transform.x * weight;
						y += transform.y * weight;
						skewX += transform.skewX * weight;
						skewY += transform.skewY * weight;
						scaleX += transform.scaleX * weight;
						scaleY += transform.scaleY * weight;
						pivotX += pivot.x * weight;
						pivotY += pivot.y * weight;
						layerTotalWeight += weight;
					}
					j++;
				}
				if(layerTotalWeight >= weigthLeft) {
					break;
				} else {
					weigthLeft -= layerTotalWeight;
				}
			}
			transform = bone.tween;
			pivot = bone.tweenPivot;
			transform.x = x;
			transform.y = y;
			transform.skewX = skewX;
			transform.skewY = skewY;
			transform.scaleX = scaleX;
			transform.scaleY = scaleY;
			pivot.setTo(pivotX, pivotY);
		}
	}
	
	function addLayer(layer:Int):Int {
		if(layer >= animationLayer.length) {
			layer = animationLayer.length;
			animationLayer[layer] = [];
		}
		return layer;
	}
	
	function addState(animationState:AnimationState) {
		var animationStateList = animationLayer[animationState.layer];
		animationStateList[animationStateList.length] = animationState;
	}
	
	function removeState(animationState:AnimationState) {
		var layer = animationState.layer;
		var animationStateList = animationLayer[animationState.layer];
		animationStateList.remove(animationState);
		AnimationState.returnObject(animationState);
		if(animationStateList.empty() && (layer == animationLayer.length - 1)) {
			animationLayer.pop();
		}
	}
	
	//{ region dragonBones_internal
	public function setActive(animationState:AnimationState, active:Bool) {
		if(active) {
			_isActive = true;
		} else {
			for(layer in animationLayer) {
				for(it in layer) {
					if(it.isPlaying) {
						return;
					}
				}
			}
			_isActive = false;
		}
	}
	//} endregion
}
