package dragonbones.objects;
import dragonbones.Interfaces.IDisposable;
import dragonbones.Interfaces.INameable;
import dragonbones.utils.DisposeUtil;
import dragonbones.flash.Point;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class SkeletonData implements INameable implements IDisposable {

	public function new() {
		armatureDataList = [];
		_subTexturePivots = new Map();
	}
	
	public var name(default, default):String;
	public var armatureNames(get, null):Array<String>;
	public var armatureDataList(default, null):Array<ArmatureData>;
	
	var _subTexturePivots:Map<String, Point>;
	
	function get_armatureNames():Array<String> {
		var result:Array<String> = [];
		for(it in armatureDataList) {
			result[result.length] = it.name;
		}
		return result;
	}
	
	public function dispose() {
		name = null;
		for(it in armatureDataList) DisposeUtil.dispose(it);
		armatureDataList = DisposeUtil.dispose(armatureDataList);
		_subTexturePivots = DisposeUtil.dispose(_subTexturePivots);
	}
	
	public function addArmatureData(data:ArmatureData) {
		if(data == null) {
			throw "error";//new ArgumentError("the data argument must not be null");
		} else if(Lambda.has(armatureDataList, data)) {
			//new ArgumentError();
		}
		armatureDataList[armatureDataList.length] = data;
	}
	
	public function removeArmatureData(data:ArmatureData) armatureDataList.remove(data);
	
	public function removeArmatureDataByName(name:String) {
		for(it in armatureDataList) {
			if(it.name == name) {
				armatureDataList.remove(it);
			}
		}
	}
	
	public function getArmatureData(name:String):ArmatureData {
		for(it in armatureDataList) {
			if(it.name == name) {
				return it;
			}
		}
		return null;
	}
	
	public function addSubTexturePivot(x:Float, y:Float, subTextureName:String):Point {
		var point:Point = null;
		if(_subTexturePivots.exists(subTextureName)) {
			point = _subTexturePivots.get(subTextureName);
			point.setTo(x, y);
		} else {
			point = new Point(x, y);
			_subTexturePivots.set(subTextureName, point);
		}
		return point;
	}
	
	public function removeSubTexturePivot(?subTextureName:String) {
		if(subTextureName != null && _subTexturePivots.exists(subTextureName)) {
			_subTexturePivots.remove(subTextureName);
		} else {
			for(it in _subTexturePivots.keys()) {
				_subTexturePivots.remove(it);
			}
		}
	}
	
	public function getSubTexturePivot(subTextureName:String):Point return _subTexturePivots[subTextureName];	
}
