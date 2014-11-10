package dragonbones.objects;
import dragonbones.Interfaces.IDisposable;
import dragonbones.Interfaces.INameable;
import dragonbones.objects.SlotData;
import dragonbones.utils.DisposeUtil;
using Lambda;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
@:final class SkinData implements INameable implements IDisposable {

	public function new() slotDataList = [];
	
	public var name(default, default):String;
	public var slotDataList(default, null):Array<SlotData>;
	
	public function dispose() {
		name = null;
		for(it in slotDataList) DisposeUtil.dispose(it);
		slotDataList = DisposeUtil.dispose(slotDataList);
	}
	
	public function addSlotData(data:SlotData) {
		if(data == null) {
			throw "error";// new ArgumentError("the data argument must not be null");
		} else if(slotDataList.has(data)) {
			//new ArgumentError();
		}
		slotDataList[slotDataList.length] = data;
	}
	
	public function getSlotData(name:String):SlotData {
		for(it in slotDataList) {
			if(it.name == name) {
				return it;
			}
		}
		return null;
	}
}
