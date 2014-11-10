package dragonbones.animation;
import dragonbones.Armature;
import dragonbones.Bone;
import dragonbones.events.AnimationEvent;
import dragonbones.Interfaces.INameable;
import dragonbones.objects.AnimationData;
import dragonbones.objects.Frame;
using Lambda;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
@:final class AnimationState implements INameable {
	
	static var _pool:Array<AnimationState> = [];
	
	//{ region dragonBones_internal
	public static function borrowObject():AnimationState return _pool.empty() ? new AnimationState() : _pool.pop();
	
	public static function returnObject(animationState:AnimationState) {
		animationState.setEmpty();
		
		if(!_pool.has(animationState)) {
			_pool[_pool.length] = animationState;
		}
	}
	
	public static function clear() {
		for(it in _pool) {
			it.setEmpty();
			_pool.remove(it);
		}
		TimelineState.clear();
	}
	//} endregion
	
	public function new() {
		_timelineStates = new Map();
	}
	
	public var name(default, default):String;
	public var tweenEnabled:Bool;
	public var blend:Bool;
	public var group:String;
	public var weight:Float;
	public var clip(default, null):AnimationData;
	public var loopCount(default, null):Int; 
	public var loop(default, null):Int;
	public var layer(default, null):Int;
	public var isPlaying(get, null):Bool;
	public var isComplete(default, null):Bool;
	public var fadeInTime(default, null):Float;
	public var totalTime(default, null):Float;
	public var currentTime(default, set):Float;
	public var timeScale(default, set):Float;
	public var displayControl:Bool;
	
	var _armature:Armature;
	var _currentFrame:Frame;
	var _mixingTransforms:Map<String, Int>;
	var _fadeState:Int;
	var _fadeOutTime:Float;
	var _fadeOutBeginTime:Float;
	var _fadeOutWeight:Float;
	var _fadeIn:Bool;
	var _fadeOut:Bool;
	var _pauseBeforeFadeInCompleteState:Int;
	
	function set_currentTime(value:Float):Float {
		currentTime = value < 0 || value != value ? 0 : value;
		return currentTime;
	}
	
	function set_timeScale(value:Float):Float {
		if(value < 0) {
			value = 0;
		} else if(value != value) {
			value = 1;
		}
		timeScale = value;
		return timeScale;
	}
	
	function get_isPlaying() return isPlaying && !isComplete;
	
	//{ region dragonBones_internal
	public var _timelineStates:Map<String, TimelineState>;
	public var _fadeWeight:Float;
	//} endregion
	
	public function fadeOut(fadeOutTime:Float, ?pause:Bool) {
		if(_armature == null || _fadeOutWeight >= 0) {
			return;
		}
		_fadeState = -1;
		_fadeOutWeight = _fadeWeight;
		_fadeOutTime = fadeOutTime * timeScale;
		_fadeOutBeginTime = currentTime;
		isPlaying = !pause;
		_fadeOut = true;
		displayControl = false;
		for(it in _timelineStates) {
			it.fadeOut();
		}
	}
	
	public function play() isPlaying = true;
	
	public function stop() isPlaying = false;
	
	public function getMixingTransform(timelineName:String):Int {
		return _mixingTransforms != null ? _mixingTransforms.get(timelineName) : -1;
	}
	
	public function addMixingTransform(timelineName:String, type:Int = 2, recursive:Bool = true) {
		if(clip == null || clip.getTimeline(timelineName) == null) {
			throw "Error";// new ArgumentError();
		}
		if(_mixingTransforms == null) {
			_mixingTransforms = new Map();
		}
		if(recursive) {
			var curBone:Bone = null;
			var boneList = _armature.boneList;
			var i = boneList.length;
			while(i --> 0) {
				var bone  = boneList[i];
				if(bone.name == timelineName) {
					curBone = bone;
				}
				if(curBone != null && (curBone == bone || curBone.contains(bone))) {
					_mixingTransforms.set(bone.name, type);
				}
			}
		} else {
			_mixingTransforms.set(timelineName, type);
		}
		updateTimelineStates();
	}
	
	public function removeMixingTransform(?timelineName:String, recursive:Bool = true) {
		if(timelineName == null) {
			_mixingTransforms = null;
		} else {
			if(recursive) {
				var boneList = _armature.boneList;
				var i = boneList.length;
				while(i --> 0) {
					var bone = boneList[i];
					var curBone:Bone = null;
					if(bone.name == timelineName) {
						curBone = bone;
					}
					if(curBone != null && (curBone == bone || curBone.contains(bone))) 					{
						_mixingTransforms.remove(bone.name);
					}
				}
			} else {
				_mixingTransforms.remove(timelineName);
			}
			if(_mixingTransforms.empty()) {
				_mixingTransforms = null;
			}
		}
		updateTimelineStates();
	}
	
	public function advanceTime(passedTime:Float):Bool {
		var event:AnimationEvent;
		var isComplete:Bool = false;
		if(_fadeIn) {	
			_fadeIn = false;
			_armature.animation.setActive(this, true);
			/*if(_armature.hasEventListener(AnimationEvent.FADE_IN)) {
				event = new AnimationEvent(AnimationEvent.FADE_IN);
				event.animationState = this;
				_armature.eventList.push(event);
			}*/
		}
		if(_fadeOut) {	
			_fadeOut = false;
			_armature.animation.setActive(this, true);
			/*if(_armature.hasEventListener(AnimationEvent.FADE_OUT)) {
				event = new AnimationEvent(AnimationEvent.FADE_OUT);
				event.animationState = this;
				_armature.eventList.push(event);
			}*/
		}
		currentTime += passedTime * timeScale;
		if(isPlaying && _pauseBeforeFadeInCompleteState != 0) {
			var progress:Float;
			var currentLoopCount:Int;
			if(_pauseBeforeFadeInCompleteState == -1) {
				_pauseBeforeFadeInCompleteState = 0;
				progress = 0;
				currentLoopCount = 0;
			} else {
				progress = currentTime / totalTime;
				currentLoopCount = Std.int(progress);
				if(currentLoopCount != loopCount) {
					if(loopCount == -1) {
						_armature.animation.setActive(this, true);
						/*if(_armature.hasEventListener(AnimationEvent.START)) {
							event = new AnimationEvent(AnimationEvent.START);
							event.animationState = this;
							_armature.eventList.push(event);
						}*/
					}
					loopCount = currentLoopCount;
					if(loopCount != 0) {
						if(loop != 0 && (loopCount * loopCount) >= (loop * loop - 1)) {
							isComplete = true;
							progress = 1;
							currentLoopCount = 0;
							/*if(_armature.hasEventListener(AnimationEvent.COMPLETE)) {
								event = new AnimationEvent(AnimationEvent.COMPLETE);
								event.animationState = this;
								_armature.eventList.push(event);
							}*/
						} else {
							/*if(_armature.hasEventListener(AnimationEvent.LOOP_COMPLETE)) {
								event = new AnimationEvent(AnimationEvent.LOOP_COMPLETE);
								event.animationState = this;
								_armature.eventList.push(event);
							}*/
						}
					}
				}
			}
			for(it in _timelineStates) {
				it.update(progress);
			}
			if(clip.frameList.length > 0) {
				var playedTime = totalTime * (progress - currentLoopCount);
				var isArrivedFrame = false;
				var frameIndex:Int;
				while(_currentFrame == null || (playedTime > _currentFrame.position + _currentFrame.duration) || playedTime < _currentFrame.position) {
					if(isArrivedFrame) {
						_armature.arriveAtFrame(_currentFrame, null, this, true);
					}
					isArrivedFrame = true;
					if(_currentFrame != null) {
						frameIndex = clip.frameList.indexOf(_currentFrame) + 1;
						if(frameIndex >= clip.frameList.length) {
							frameIndex = 0;
						}
						_currentFrame = clip.frameList[frameIndex];
					} else {
						_currentFrame = clip.frameList[0];
					}
				}
				if(isArrivedFrame) {
					_armature.arriveAtFrame(_currentFrame, null, this, false);
				}
			}
		}
		if(_fadeState > 0) {
			if(fadeInTime == 0) {
				_fadeWeight = 1;
				_fadeState = 0;
				_pauseBeforeFadeInCompleteState = 1;
				_armature.animation.setActive(this, false);
				/*if(_armature.hasEventListener(AnimationEvent.FADE_IN_COMPLETE)) {
					event = new AnimationEvent(AnimationEvent.FADE_IN_COMPLETE);
					event.animationState = this;
					_armature.eventList.push(event);
				}*/
			} else {
				_fadeWeight = currentTime / fadeInTime;
				if(_fadeWeight >= 1) {
					_fadeWeight = 1;
					_fadeState = 0;
					if(_pauseBeforeFadeInCompleteState == 0) {
						currentTime -= fadeInTime;
					}
					_pauseBeforeFadeInCompleteState = 1;
					_armature.animation.setActive(this, false);
					/*if(_armature.hasEventListener(AnimationEvent.FADE_IN_COMPLETE)) {
						event = new AnimationEvent(AnimationEvent.FADE_IN_COMPLETE);
						event.animationState = this;
						_armature.eventList.push(event);
					}*/
				}
			}
		} else if(_fadeState < 0) {
			if(_fadeOutTime == 0) {
				_fadeWeight = 0;
				_fadeState = 0;
				_armature.animation.setActive(this, false);
				/*if(_armature.hasEventListener(AnimationEvent.FADE_OUT_COMPLETE)) {
					event = new AnimationEvent(AnimationEvent.FADE_OUT_COMPLETE);
					event.animationState = this;
					_armature.eventList.push(event);
				}*/
				return true;
			} else {
				_fadeWeight = (1 - (currentTime - _fadeOutBeginTime) / _fadeOutTime) * _fadeOutWeight;
				if(_fadeWeight <= 0) {
					_fadeWeight = 0;
					_fadeState = 0;
					_armature.animation.setActive(this, false);
					/*if(_armature.hasEventListener(AnimationEvent.FADE_OUT_COMPLETE)) {
						event = new AnimationEvent(AnimationEvent.FADE_OUT_COMPLETE);
						event.animationState = this;
						_armature.eventList.push(event);
					}*/
					return true;
				}
			}
		}
		if(isComplete) {
			this.isComplete = true;
			if(loop < 0) {
				fadeOut((_fadeOutWeight != 0  ? _fadeOutWeight : fadeInTime) / timeScale, true);
			} else {
				_armature.animation.setActive(this, false);
			}
		}
		return false;
	}
	
	function updateTimelineStates() {
		if(_mixingTransforms != null) {
			for(it in _timelineStates.keys()) {
				if(_mixingTransforms.get(it) == null) {
					removeTimelineState(it);
				}
			}
			for(it in _mixingTransforms.keys()) {
				if(_timelineStates.get(it) == null) {
					addTimelineState(it);
				}
			}
		} else {
			for(it in clip.timelines.keys()) {
				if(_timelineStates.get(it) == null) {
					addTimelineState(it);
				}
			}
		}
	}
	
	function addTimelineState(name:String) {
		var bone = _armature.getBone(name);
		if(bone != null) {
			var timelineState = TimelineState.borrowObject();
			timelineState.fadeIn(bone, this, clip.getTimeline(name));
			_timelineStates.set(name, timelineState);
		}
	}
	
	function removeTimelineState(name:String) {
		TimelineState.returnObject(_timelineStates.get(name));
		_timelineStates.remove(name);
	}
	
	function setEmpty() {
		_armature = null;
		_currentFrame = null;
		clip = null;
		_mixingTransforms = null;
		for(it in _timelineStates.keys()) {
			removeTimelineState(it);
		}
	}
	
	//{ region dragonBones_internal
	public function fadeIn(armature:Armature, clip:AnimationData, fadeInTime:Float, timeScale:Float, loop:Int, layer:Int, displayControl:Bool, pauseBeforeFadeInComplete:Bool) {
		_armature = armature;
		this.clip = clip;
		name = clip.name;
		this.layer = layer;
		totalTime = clip.duration;
		if(Math.round(clip.duration * clip.frameRate) < 2 || timeScale == Math.POSITIVE_INFINITY || timeScale == Math.NEGATIVE_INFINITY) {
			this.timeScale = 1;
			currentTime = totalTime;
			this.loop = this.loop >= 0 ? 1 : -1;
		} else {
			this.timeScale = timeScale;
			currentTime = 0;
			this.loop = loop;
		}
		_pauseBeforeFadeInCompleteState = pauseBeforeFadeInComplete ? -1 : 1;
		this.fadeInTime = fadeInTime * this.timeScale;
		loopCount = -1;
		_fadeState = 1;
		_fadeOutBeginTime = 0;
		_fadeOutWeight = -1;
		_fadeWeight = 0;
		isPlaying = true;
		isComplete = false;
		_fadeIn = true;
		_fadeOut = false;
		this.displayControl = displayControl;
		weight = 1;
		blend = true;
		tweenEnabled = true;
		updateTimelineStates();
	}
	//} endregion
}
