package dragonbones.objects;
import dragonbones.Interfaces.INameable;
import dragonbones.objects.Timeline.TransformTimeline;
import dragonbones.utils.DisposeUtil;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
@:final class AnimationData extends Timeline implements INameable {

	public function new() {
		super();
		loop = 0;
		tweenEasing = Math.NaN;
		timelines = new Map();
		fadeInTime = 0;
	}
	
	public var name(default, default):String;
	public var frameRate:Int;
	public var loop:Int;
	public var tweenEasing:Float;
	public var timelines(default, null):Map<String, TransformTimeline>;
	public var fadeInTime(default, set):Float;
	
	function set_fadeInTime(value:Float):Float {
		fadeInTime = value != value ? 0 : value;
		return fadeInTime;
	}
	
	public override function dispose() {
		super.dispose();
		name = null;
		for(it in timelines) DisposeUtil.dispose(it);
		timelines = DisposeUtil.dispose(timelines);
	}
	
	public function addTimeline(timeline:TransformTimeline, name:String) {
		if(timeline == null) {
			throw "error";//new ArgumentError("the timeline argument must not be null");
		}
		timelines.set(name, timeline);
	}
	
	public function getTimeline(name:String):TransformTimeline  return timelines.get(name);
}
