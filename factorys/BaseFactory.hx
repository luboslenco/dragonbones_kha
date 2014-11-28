package dragonbones.factorys;
import dragonbones.Armature;
import dragonbones.Bone;
import dragonbones.TypeDefs.DisplayObject;
import dragonbones.objects.ArmatureData;
import dragonbones.objects.DisplayData;
import dragonbones.objects.Parsers.DataParser;
import dragonbones.objects.SkeletonData;
import dragonbones.objects.SkinData;
import dragonbones.Slot;
import dragonbones.textures.ITextureAtlas;
//import dragonbones.TypeDefs.EventDispatcher;
import dragonbones.utils.DisposeUtil;
//import flash.display.Bitmap;
import dragonbones.flash.DisplayObjectContainer;
//import flash.events.Event;
import dragonbones.flash.Matrix;
//import dragonbones.flash.ByteArray;
#if msignal
import msignal.Signal.Signal0;
#end
using Lambda;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class BaseFactory {//extends EventDispatcher {

	static var _helpMatrix:Matrix = new Matrix();
	
	function new() {
		//super();
		#if msignal
		onDataParsed = new Signal0();
		#end
		_name2SkeletonData = new Map();
		_name2TexAtlas = new Map();
	}
	
	#if msignal
	public var onDataParsed(default, null):Signal0;
	#end
	
	var _name2SkeletonData:Map<String, SkeletonData>;
	var _name2TexAtlas:Map<String, ITextureAtlas>;
	var _curDataName:String;
	var _curTexAtlasName:String;
	
	public function dispose(disposeData:Bool = true) {
		#if msignal
		onDataParsed = DisposeUtil.dispose(onDataParsed);
		#end
		if (disposeData) {
			for (it in _name2SkeletonData) DisposeUtil.dispose(it);
			for (it in _name2TexAtlas) DisposeUtil.dispose(it);
		}
		_name2SkeletonData = DisposeUtil.dispose(_name2SkeletonData);
		_name2TexAtlas = DisposeUtil.dispose(_name2TexAtlas);
		_curDataName = null;
		_curTexAtlasName = null;
	}
	
	public function parseData(decompressedData:dragonbones.objects.DecompressedData, ?dataName:String):SkeletonData {
		if(decompressedData == null) {
			throw "error";//new ArgumentError("the bytes argument must not be null");
		}

		var data = DataParser.parseData(decompressedData.dragonBonesData);
		if(dataName == null) {
			dataName = data.name;
		}
		addSkeletonData(data, dataName);

		var texAtlas:ITextureAtlas = null;
		texAtlas = generateTextureAtlas(decompressedData.texture, decompressedData.textureAtlasData);
		addTextureAtlas(texAtlas, dataName);

		return data;
	}
	
	public function getTextureDisplay(texName:String, ?texAtlasName:String, ?pivotX:Float, ?pivotY:Float):Dynamic {
		var texAtlas:ITextureAtlas = null;
		if(texAtlasName != null) {
			texAtlas = _name2TexAtlas.get(texAtlasName);
		}
		if(texAtlas == null && texAtlasName == null) {
			for (it in _name2TexAtlas.keys()) {
				texAtlasName = it;
				texAtlas = _name2TexAtlas.get(it);
				if(texAtlas.getRegion(texName) != null) {
					break;
				}
				texAtlas = null;
			}
		}
		if(texAtlas == null) {
			return null;
		}
		if ((pivotX != pivotX) || (pivotY != pivotY)) {
			var skeletonData = _name2SkeletonData.get(texAtlasName);
			if(skeletonData != null) {
				var pivot = skeletonData.getSubTexturePivot(texName);
				if(pivot != null) {
					pivotX = pivot.x;
					pivotY = pivot.y;
				}
			}
		}
		return generateDisplay(texAtlas, texName, pivotX, pivotY);
	}
	
	public function addSkeletonData(data:SkeletonData, ?name:String) {
		if(data == null) {
			throw "error";//new ArgumentError("the data argument must not be null");
		}
		if(name == null) {
			name = data.name;
		}
		if(name == null) {
			throw "error";//new ArgumentError("the name argument must not be null");
		}
		_name2SkeletonData.set(name, data);
	}
	
	public function removeSkeletonData(name:String) {
		if(_name2SkeletonData.exists(name)) {
			_name2SkeletonData.remove(name);
		}
	}
	
	public function getSkeletonData(name:String):SkeletonData {
		if(_name2SkeletonData.exists(name)) {
			return _name2SkeletonData.get(name);
		}
		return null;
	}
	
	public function addTextureAtlas(texAtlas:ITextureAtlas, ?name:String) {
		if(texAtlas == null) {
			throw "error";//new ArgumentError("the texAtlas argument must not be null");
		}
		if(name == null) {
			name = texAtlas.name;
		}
		if(name == null) {
			throw "error";//new ArgumentError("the name argument must not be null");
		}
		_name2TexAtlas.set(name, texAtlas);
	}
	
	public function removeTextureAtlas(name:String) {
		if(_name2TexAtlas.exists(name)) {
			_name2TexAtlas.remove(name);
		}
	}
	
	public function getTextureAtlas(name:String):ITextureAtlas {
		if(_name2TexAtlas.exists(name)) {
			return _name2TexAtlas.get(name);
		}
		return null;
	}
	
	public function buildArmature(armatureName:String, ?animationName:String, ?skeletonName:String, ?texAtlasName:String, ?skinName:String):Armature {
		var skeletonData:SkeletonData = null;
		var armatureData:ArmatureData = null;
		var animationArmatureData:ArmatureData = null;
		var skinDataCopy:SkinData = null;
		var displayDataCopy:DisplayData = null;
		
		if(skeletonName != null) {
			skeletonData = _name2SkeletonData.get(skeletonName);
			if(skeletonData != null) {
				armatureData = skeletonData.getArmatureData(armatureName);
			}
		} else  {
			for(it in _name2SkeletonData.keys()) {
				skeletonName = it;
				skeletonData = _name2SkeletonData.get(it);
				armatureData = skeletonData.getArmatureData(armatureName);
				if(armatureData != null) {
					break;
				}
			}
		}
		if(armatureData == null) {
			return null;
		}
		
		_curDataName = skeletonName;
		_curTexAtlasName = texAtlasName != null ? texAtlasName : skeletonName;
		
		var armature = generateArmature();
		armature.name = armatureName;
		
		for(it in armatureData.boneDataList) {
			var bone = new Bone();
			bone.name = it.name;
			bone.fixedRotation = it.fixedRotation;
			bone.scaleMode = it.scaleMode;
			bone.origin.copy(it.transform);
			if(armatureData.getBoneData(it.parent) != null) {
				armature.addBone(bone, it.parent);
			} else {
				armature.addBone(bone);
			}
		}
		
		if(animationName != null && animationName != armatureName) {
			animationArmatureData = skeletonData.getArmatureData(animationName);
			if(animationArmatureData != null) {
				for(it in _name2SkeletonData.keys()) {
					skeletonName = it;
					skeletonData = _name2SkeletonData.get(it);
					animationArmatureData = skeletonData.getArmatureData(animationName);
					if(animationArmatureData != null) {
						break;
					}
				}
			}
			
			var armatureDataCopy:ArmatureData = skeletonData.getArmatureData(animationName);
			if(armatureDataCopy != null) {
				skinDataCopy = armatureDataCopy.getSkinData("");
			}
		}
		
		armature.animation.animationDataList = animationArmatureData != null ? animationArmatureData.animationDataList : armatureData.animationDataList;
		var skinData = armatureData.getSkinData(skinName);
		if(skinData == null) {
			throw "error";//new ArgumentError("the skinData argument must not be null");
		}
		
		for(it in skinData.slotDataList) {
			var bone = armature.getBone(it.parent);
			if(bone == null) {
				continue;
			}
			
			var slot = generateSlot();
			slot.name = it.name;
			slot.blendMode = it.blendMode;
			slot.originZOrder = it.zOrder;
			slot.displayDataList = it.displayDataList;
			
			var helpArray:Array<Dynamic> = [];
			var displayDataList = slot.displayDataList;
			var i = displayDataList.length;
			while (i-- > 0) {
				var displayData = displayDataList[i];
				switch (displayData.type) {
					case DisplayData.ARMATURE:
						if(skinDataCopy != null) {
							var slotDataCopy = skinDataCopy.getSlotData(it.name);
							if(slotDataCopy != null) {
								displayDataCopy = slotDataCopy.displayDataList[i];
							}
						} else {
							displayDataCopy = null;
						}
						
						var childArmature = buildArmature(displayData.name, displayDataCopy != null ? displayDataCopy.name : null, _curDataName, _curTexAtlasName);
						if(childArmature != null) {
							helpArray[i] = childArmature;
						}
					case DisplayData.IMAGE, _:
						helpArray[i] = generateDisplay(_name2TexAtlas.get(_curTexAtlasName), displayData.name, displayData.pivot.x, displayData.pivot.y);
				}
			}
			slot.displayList = helpArray;
			slot.changeDisplay(0);
			bone.addChild(slot);
		}
		
		for(it in armature.boneList) {
			it.update();
		}
		for(it in armature.slotList) {
			it.update();
		}
		armature.updateSlotsZOrder();
		return armature;
	}
	
	function generateTextureAtlas(content:Dynamic, texAtlasRawData:Dynamic):ITextureAtlas return null;
	
	function generateArmature():Armature return null;
	
	function generateSlot():Slot return null;
	
	function generateDisplay(texAtlass:Dynamic, name:String, pivotX:Float, pivotY:Float):DisplayObject return null;
}
