package dragonbones.objects;
import dragonbones.Interfaces.IDisposable;
import dragonbones.Interfaces.INameable;
import dragonbones.utils.DisposeUtil;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
@:final class SlotData implements INameable implements IDisposable  {

	public function new() {
		displayDataList = [];
		zOrder = 0;
		blendMode = "normal";//TODO: to const
	}
	
	public var name(default, default):String;
	public var displayDataList(default, null):Array<DisplayData>;
	public var parent:String;
	public var zOrder:Float;
	public var blendMode:String;
	
	public function dispose() {
		name = null;
		for(it in displayDataList) DisposeUtil.dispose(it);
		displayDataList = null;
	}
	
	public function addDisplayData(data:DisplayData) {
		if(data == null) {
			throw "error";// new ArgumentError("the data argument must not be null");
		} else if(Lambda.has(displayDataList, data)) {
			//throw new ArgumentError();
		}
		displayDataList[displayDataList.length] = data;
	}
	
	public function getDisplayData(name:String):DisplayData {
		for(it in displayDataList) {
			if(it.name == name) {
				return it;
			}
		}
		return null;
	}
}
