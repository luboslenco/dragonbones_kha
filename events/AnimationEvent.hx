package dragonbones.events;
import dragonbones.animation.AnimationState;
import dragonbones.Armature;
//import dragonbones.TypeDefs.Event;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class AnimationEvent {//extends Event {

	public static inline var FADE_IN = "fadeIn";
	public static inline var MOVEMENT_CHANGE = "fadeIn";
	public static inline var FADE_OUT = "fadeOut";
	public static inline var START = "start";
	public static inline var COMPLETE = "complete";
	public static inline var LOOP_COMPLETE = "loopComplete";
	public static inline var FADE_IN_COMPLETE = "fadeInComplete";
	public static inline var FADE_OUT_COMPLETE = "fadeOutComplete";

	public function new(type:String, ?cancelable:Bool) {}// super(type, false, cancelable);
	
	public var animationState:AnimationState;
	//public var armature(get, null):Armature;
	public var movementID(get, null):String;
	
	//function get_armature():Armature return cast(target, Armature);
	
	function get_movementID():String return animationState.name;
	
	/*public override function clone():Event {
		var result = new AnimationEvent(type, cancelable);
		result.animationState = animationState;
		return result;
	}*/
}
