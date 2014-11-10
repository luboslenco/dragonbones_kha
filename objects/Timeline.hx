package dragonbones.objects;
import dragonbones.Interfaces.IDisposable;
import dragonbones.utils.DisposeUtil;
import dragonbones.flash.Point;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class Timeline implements IDisposable {

	public function new() {
		frameList = [];
		duration = 0;
		scale = 1;
	}
	
	public var frameList(default, null):Array<Frame>;
	public var duration(default, set):Float;
	public var scale(default, set):Float;
	
	function set_duration(value:Float):Float {
		duration = value >= 0 ? value : 0;
		return duration;
	}
	
	function set_scale(value:Float):Float {
		scale = value >= 0 ? value : 1;
		return scale;
	}
	
	public function dispose() {
		for(it in frameList) DisposeUtil.dispose(it);
		frameList = DisposeUtil.dispose(frameList);
	}
	
	public function addFrame(frame:Frame) {
		if(frame == null) {
			throw "error";// new ArgumentError("the frame argument must not be null");
		} else if(Lambda.has(frameList, frame)) {
			//throw new ArgumentError();
		}
		frameList[frameList.length] = frame;
	}
}

@:final class TransformTimeline extends Timeline {
	
	public static var HIDE_TIMELINE = new TransformTimeline();
	
	public function new() {
		super();
		originTransform = new DBTransform();
		originPivot = new Point();
		offset = 0;
	}
	
	public var transformed:Bool;
	public var originTransform:DBTransform;
	public var originPivot:Point;
	public var offset(default, set):Float;
	
	public function set_offset(value:Float):Float {
		if(value != 0) {
			offset = value % 1;
		} else {
			offset = 0;
		}
		if(offset < 0) {
			offset += 1;
		}
		return offset;
	}
	
	public override function dispose() {
		if(this == HIDE_TIMELINE) {
			return;
		}
		super.dispose();
		originTransform = DisposeUtil.dispose(originTransform);
		originPivot = DisposeUtil.dispose(originPivot);
	}
}
