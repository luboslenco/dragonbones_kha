package dragonbones.animation;
import dragonbones.animation.IAnimatable;
import haxe.Timer;
using Lambda;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class WorldClock implements IAnimatable {
	
	public static var instance(get, null):WorldClock;
	
	static function get_instance():WorldClock {
		if (instance == null) {
			instance = new WorldClock();
		}
		return instance;
	}
	
	function new() {
		time = Timer.stamp();
		timeScale = 1;
		_animatableList = [];
	}
	
	public var time(default, null):Float;
	public var timeScale(default, set):Float;
	var _animatableList:Array<IAnimatable>;
	
	function set_timeScale(value:Float):Float {
		if(value < 0 || value != value) {
			timeScale = 0;
		} else {
			timeScale = value;
		}
		return timeScale;
	}
	
	public function contains(animatable:IAnimatable):Bool return _animatableList.has(animatable);
	
	public function add(animatable:IAnimatable) {
		if(animatable != null && !_animatableList.has(animatable)) {
			_animatableList[_animatableList.length] = animatable;
		}
	}
	
	public function remove(animatable:IAnimatable) _animatableList.remove(animatable);
	
	public function clear() _animatableList = [];
	
	public function advanceTime(passedTime:Float) {
		if(passedTime < 0) {
			var curTime = Timer.stamp();
			passedTime = curTime - time;
			time = curTime;
		}
		
		passedTime *= timeScale;
		
		for (i in 0..._animatableList.length) {
			_animatableList[i].advanceTime(passedTime);
		}
	}
}
