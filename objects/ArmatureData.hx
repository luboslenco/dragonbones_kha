package dragonbones.objects;
import dragonbones.Interfaces.IDisposable;
import dragonbones.Interfaces.INameable;
import dragonbones.utils.DisposeUtil;
//import flash.errors.ArgumentError;
using Lambda;

/**
 * @author SlavaRa
 */
@:final class ArmatureData implements INameable implements IDisposable {

	public function new() {
		boneDataList = [];
		skinDataList = [];
		animationDataList = [];
	}
	
	public var name(default, default):String;
	public var boneDataList(default, null):Array<BoneData>;
	public var skinDataList(default, null):Array<SkinData>;
	public var animationDataList(default, null):Array<AnimationData>;
	
	public function dispose() {
		for(it in boneDataList) DisposeUtil.dispose(it);
		for(it in skinDataList) DisposeUtil.dispose(it);
		for(it in animationDataList) DisposeUtil.dispose(it);
		name = null;
		boneDataList = DisposeUtil.dispose(boneDataList);
		skinDataList = DisposeUtil.dispose(skinDataList);
		animationDataList = DisposeUtil.dispose(animationDataList);
	}
	
	public function getBoneData(name:String):BoneData {
		var result:INameable = getDataByName(cast boneDataList, name);
		return result != null ? cast(result, BoneData) : null;
	}
	
	public function getSkinData(name:String):SkinData {
		if(name == null) {
			return skinDataList[0];
		}
		var result:INameable = getDataByName(cast skinDataList, name);
		return result != null ? cast(result, SkinData) : null;
	}
	
	public function getAnimationData(name:String):AnimationData {
		var result:INameable = getDataByName(cast animationDataList, name);
		return result != null ? cast(result, AnimationData) : null;
	}
	
	public function addBoneData(data:BoneData) {
		if(data == null) {
			throw "error";//new ArgumentError("the data argument must not be null");
		} else if(boneDataList.has(data)) {
			throw "error";//new ArgumentError();
		}
		boneDataList[boneDataList.length] = data;
	}
	
	public function addSkinData(data:SkinData) {
		if(data == null) {
			throw "error";//new ArgumentError("the data argument must not be null");
		} else if(skinDataList.has(data)) {
			throw "error";//new ArgumentError();
		}
		skinDataList[skinDataList.length] = data;
	}
	
	public function addAnimationData(data:AnimationData) {
		if(data == null) {
			throw "error";//new ArgumentError("the data argument must not be null");
		} else if(animationDataList.has(data)) {
			throw "error";//new ArgumentError();
		}
		animationDataList[animationDataList.length] = data;
	}
	
	public function sortBoneDataList() {
		var i = boneDataList.length;
		if(i == 0) {
			return;
		}
		var helpArray:Array<Dynamic> = [];
		while(i --> 0) {
			var data = boneDataList[i];
			var level = 0;
			var parentData = data;
			while(parentData != null && parentData.parent != null) {
				level++;
				parentData = getBoneData(parentData.parent);
			}
			helpArray[i] = { level:level, data:data };
		}
		helpArray.sort(function f(a, b):Int return Reflect.compare(a.level, b.level));
		i = helpArray.length;
		while(i --> 0) {
			boneDataList[i] = helpArray[i].data;
		}
	}
	
	inline function getDataByName(collection:Array<INameable>, name:String):INameable {
		var result:INameable = null;
		for(it in collection) {
			if(it.name == name) {
				result = it;
				break;
			}
		}
		return result;
	}
	
}