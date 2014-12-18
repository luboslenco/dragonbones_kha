package dragonbones.objects;
import dragonbones.core.DragonBones;
import dragonbones.objects.AnimationData;
import dragonbones.objects.ArmatureData;
import dragonbones.objects.DisplayData;
import dragonbones.objects.Frame;
import dragonbones.objects.Frame.TransformFrame;
import dragonbones.objects.SkeletonData;
import dragonbones.objects.SkinData;
import dragonbones.objects.SlotData;
import dragonbones.objects.Timeline.TransformTimeline;
//import dragonbones.utils.BytesType;
import dragonbones.utils.ConstValues;
import dragonbones.utils.DBDataUtil;
import dragonbones.flash.ColorTransform;
import dragonbones.flash.Point;
import dragonbones.flash.Rectangle;
//import dragonbones.flash.ByteArray;
using Lambda;
using Reflect;
using Std;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
//#if debug 
class DataParser {
//#else 
//extern class DataParser {
//#end
	/*public static inline function compressData(dragonBonesData:Dynamic, textureAtlasData:Dynamic, textureDataBytes:ByteArray):ByteArray {
		var retult = new ByteArray();
		retult.writeBytes(textureDataBytes);
		
		var dataBytes = new ByteArray();
		dataBytes.writeObject(textureAtlasData);
		dataBytes.compress();
		
		retult.position = retult.length;
		retult.writeBytes(dataBytes);
		retult.writeInt(dataBytes.length);
		
		dataBytes.length = 0;
		dataBytes.writeObject(dragonBonesData);
		dataBytes.compress();
		
		retult.position = retult.length;
		retult.writeBytes(dataBytes);
		retult.writeInt(dataBytes.length);
		return retult;
	}
	
	public static inline function decompressData(bytes:ByteArray):DecompressedData {
		var result:DecompressedData = null;
		var dataType:String = BytesType.getType(bytes);
		switch (dataType) {
			case BytesType.SWF, BytesType.PNG, BytesType.JPG, BytesType.ATF:
				var dragonBonesData:Dynamic;
				var textureAtlasData:Dynamic;
				
				var bytesCopy = new ByteArray();
				bytesCopy.writeBytes(bytes);
				bytes = bytesCopy;
				
				bytes.position = bytes.length - 4;
				var strSize = bytes.readInt();
				var position = bytes.length - 4 - strSize;
				
				var dataBytes = new ByteArray();
				dataBytes.writeBytes(bytes, position, strSize);
				dataBytes.uncompress();
				bytes.length = position;
				
				if(checkBytesTailisXML(dataBytes)) {
					dragonBonesData = Xml.parse(dataBytes.readUTFBytes(dataBytes.length));
				} else {
					dragonBonesData = dataBytes.readObject();
				}
				
				bytes.position = bytes.length - 4;
				strSize = bytes.readInt();
				position = bytes.length - 4 - strSize;
				
				dataBytes.length = 0;
				dataBytes.writeBytes(bytes, position, strSize);
				dataBytes.uncompress();
				bytes.length = position;
				
				if(checkBytesTailisXML(dataBytes)) {
					textureAtlasData = Xml.parse(dataBytes.readUTFBytes(dataBytes.length));
				} else {
					textureAtlasData = dataBytes.readObject();
				}
				
				result = new DecompressedData(dragonBonesData, textureAtlasData, bytes);
				result.textureBytesDataType = dataType;
			case BytesType.ZIP: throw "error";//new Error("Can not decompress zip!");
			case _: throw "error";//new Error("Nonsupport data!");
		}
		return result;
	}*/
	
	public static inline function parseTextureAtlas(rawData:Dynamic, scale:Float = 1):Dynamic {
		//if(rawData.is(Xml)) {
			return XMLDataParser.parseTextureAtlasData(cast(rawData, Xml), scale);
		//} else {
		//	return ObjectDataParser.parseTextureAtlasData(rawData, scale);
		//}
	}
	
	public static inline function parseData(rawData:Dynamic):SkeletonData {
		//if(rawData.is(Xml)) {
			return XMLDataParser.parseSkeletonData(cast(rawData, Xml));
		//} else {
		//	return ObjectDataParser.parseSkeletonData(rawData);
		//}
	}
	
	/*public static inline function checkBytesTailisXML(bytes:ByteArray):Bool {
		var spaceCharCode = " ".charCodeAt(0);
		var tCharCode = "\t".charCodeAt(0);
		var rCharCode = "\r".charCodeAt(0);
		var nCharCode = "\n".charCodeAt(0);
		var result:Bool = false;
		var offset = bytes.length;
		var count1 = 20;
		while(count1 --> 0) {
			if(offset --> 0) {
				var curCharCode:Int = bytes[offset];
				if(">".charCodeAt(0) == curCharCode) {
					var count2 = 20;
					while(count2 --> 0) {
						if(offset --> 0) {
							if(bytes[offset] == "<".charCodeAt(0)) {
								result = true;
								break;
							}
						} else {
							break;
						}
					}
					break;
				} else if(curCharCode == spaceCharCode || curCharCode == tCharCode || curCharCode == rCharCode || curCharCode == nCharCode) {
					result = false;
					break;
				}
			}
		}
		return result;
	}*/
}

/*#if debug 
class ObjectDataParser {
#else
extern class ObjectDataParser {
#end
	public static inline function parseTextureAtlasData(rawData:Dynamic, scale:Float = 1):Dynamic {
		var result:Dynamic = { };
		result.setProperty("__name", rawData.getProperty(ConstValues.A_NAME));
		var list:Dynamic = rawData.getProperty(ConstValues.SUB_TEXTURE);
		for (it in list.fields()) {
			var subTexObject:Dynamic = list.getProperty(it);
			var rect = new Rectangle(
					cast(subTexObject.getProperty(ConstValues.A_X), Int) / scale,
					cast(subTexObject.getProperty(ConstValues.A_Y), Int) / scale,
					cast(subTexObject.getProperty(ConstValues.A_WIDTH), Int) / scale,
					cast(subTexObject.getProperty(ConstValues.A_HEIGHT), Int) / scale);
			result.setProperty(subTexObject.getProperty(ConstValues.A_NAME), rect);
		}
		return result;
	}
	
	public static inline function parseSkeletonData(rawData:Dynamic):SkeletonData {
		if(rawData == null) {
			throw "error";//new ArgumentError("the rawData argument must not be null");
		} else if(rawData.getProperty(ConstValues.A_VERSION) != DragonBones.DATA_VERSION) {
			throw "error";//new Error("Nonsupport version!");
		}
		var frameRate = cast(rawData.getProperty(ConstValues.A_FRAME_RATE), Int);
		var result = new SkeletonData();
		result.name = rawData.getProperty(ConstValues.A_NAME);
		var list:Dynamic = rawData.getProperty(ConstValues.ARMATURE);
		for(it in list.fields()) {
			result.addArmatureData(parseArmatureData(list.getProperty(it), result, frameRate));
		}
		return result;
	}
	
	static inline function parseArmatureData(rawData:Dynamic, data:SkeletonData, frameRate:Int):ArmatureData {
		var result = new ArmatureData();
		result.name = rawData.getProperty(ConstValues.A_NAME);
		var list:Dynamic = rawData.getProperty(ConstValues.BONE);
		for(it in list.fields()) {
			result.addBoneData(parseBoneData(list.getProperty(it)));
		}
		list = rawData.getProperty(ConstValues.SKIN);
		for(it in list.fields()) {
			result.addSkinData(parseSkinData(list.getProperty(it), data));
		}
		DBDataUtil.transformArmatureData(result);
		result.sortBoneDataList();
		list = rawData.getProperty(ConstValues.ANIMATION);
		for(it in list.fields()) {
			result.addAnimationData(parseAnimationData(list.getProperty(it), result, frameRate));
		}
		return result;
	}
	
	static inline function parseBoneData(rawData:Dynamic):BoneData {
		var result = new BoneData();
		result.name = rawData.getProperty(ConstValues.A_NAME);
		result.parent = rawData.getProperty(ConstValues.A_PARENT);
		if(rawData.hasField(ConstValues.A_LENGTH)) {
			result.length = cast(rawData.getProperty(ConstValues.A_LENGTH), Float);
		} else {
			result.length = 0;
		}
		var scaleModeObj:Dynamic = rawData.getProperty(ConstValues.A_SCALE_MODE);
		if (scaleModeObj != null) {
			result.scaleMode = cast(scaleModeObj, Int);
		}
		var inheritRotation:Bool = false;
		if(rawData.hasField(ConstValues.A_FIXED_ROTATION)) {
			inheritRotation = cast(rawData.getProperty(ConstValues.A_FIXED_ROTATION), Bool);
		}
		if (inheritRotation) {
			result.fixedRotation = inheritRotation;
		}
		parseTransform(rawData.getProperty(ConstValues.TRANSFORM), result.global);
		result.transform.copy(result.global);
		return result;
	}
	
	static inline function parseSkinData(rawData:Dynamic, data:SkeletonData):SkinData {
		var result = new SkinData();
		result.name = rawData.getProperty(ConstValues.A_NAME);
		var list:Dynamic = rawData.getProperty(ConstValues.SLOT);
		for(it in list.fields()) {
			result.addSlotData(parseSlotData(list.getProperty(it), data));
		}
		return result;
	}
	
	static inline function parseSlotData(rawData:Dynamic, data:SkeletonData):SlotData {
		var result = new SlotData();
		result.name = rawData.getProperty(ConstValues.A_NAME);
		result.parent = rawData.getProperty(ConstValues.A_PARENT);
		result.zOrder = cast(rawData.getProperty(ConstValues.A_Z_ORDER), Float);
		result.blendMode = rawData.getProperty(ConstValues.A_BLENDMODE);
		if(result.blendMode == null) {
			result.blendMode = "normal";
		}
		var list:Dynamic = rawData.getProperty(ConstValues.DISPLAY);
		for(it in list.fields()) {
			result.addDisplayData(parseDisplayData(list.getProperty(it), data));
		}
		return result;
	}
	
	static inline function parseDisplayData(rawData:Dynamic, data:SkeletonData):DisplayData {
		var result = new DisplayData();
		result.name = rawData.getProperty(ConstValues.A_NAME);
		result.type = rawData.getProperty(ConstValues.A_TYPE);
		result.pivot = data.addSubTexturePivot(0, 0, result.name);
		parseTransform(rawData.getProperty(ConstValues.TRANSFORM), result.transform, result.pivot);
		return result;
	}
	
	static inline function parseAnimationData(rawData:Dynamic, data:ArmatureData, frameRate:Int):AnimationData {
		var result = new AnimationData();
		result.name = rawData.getProperty(ConstValues.A_NAME);
		result.frameRate = frameRate;
		result.loop = cast(rawData.getProperty(ConstValues.A_LOOP), Int);
		result.fadeInTime = cast(rawData.getProperty(ConstValues.A_FADE_IN_TIME), Float);
		result.duration = cast(rawData.getProperty(ConstValues.A_DURATION), Float) / frameRate;
		result.scale = cast(rawData.getProperty(ConstValues.A_SCALE), Float);
		if(rawData.hasField(ConstValues.A_TWEEN_EASING)) {
			var tweenEase = rawData.getProperty(ConstValues.A_TWEEN_EASING);
			if(tweenEase == null) {
				result.tweenEasing = Math.NaN;
			} else {
				result.tweenEasing = cast(tweenEase, Float);
			}
		} else {
			result.tweenEasing = Math.NaN;
		}
		parseTimeline(rawData, result, function(rawData:Dynamic, frameRate:Int):Frame {
			return parseFrame(rawData, new Frame(), frameRate);
		}, frameRate);
		var list:Dynamic = rawData.getProperty(ConstValues.TIMELINE);
		for(it in list.fields()) {
			var timelineObject:Dynamic = list.getProperty(it);
			var timelineName = timelineObject.getProperty(ConstValues.A_NAME);
			var timeline = parseTransformTimeline(timelineObject, result.duration, frameRate);
			result.addTimeline(timeline, timelineName);
		}
		DBDataUtil.addHideTimeline(result, data);
		DBDataUtil.transformAnimationData(result, data);
		return result;
	}
	
	static inline function parseTimeline(rawData:Dynamic, timeline:Timeline, frameParser:Dynamic->Int->Frame, frameRate:Int):Void {
		var position:Float = 0;
		var frame:Frame = null;
		var list:Dynamic = rawData.getProperty(ConstValues.FRAME);
		for(it in list.fields()) {
			var frameObject:Dynamic = list.getProperty(it);
			frame = frameParser(frameObject, frameRate);
			frame.position = position;
			timeline.addFrame(frame);
			position += frame.duration;
		}
		if(frame != null) {
			frame.duration = timeline.duration - frame.position;
		}
	}
	
	static inline function parseTransformTimeline(rawData:Dynamic, duration:Float, frameRate:Int):TransformTimeline {
		var result = new TransformTimeline();
		result.duration = duration;
		parseTimeline(rawData, result, function(rawData:Dynamic, frameRate:Int):TransformFrame {
			var result = new TransformFrame();
			parseFrame(rawData, result, frameRate);
			if(rawData.hasField(ConstValues.A_HIDE)) {
				result.visible = cast(rawData.getProperty(ConstValues.A_HIDE), Int) != 1;
			} else {
				result.visible = true;
			}
			if(rawData.hasField(ConstValues.A_TWEEN_EASING)) {
				var tweenEase = rawData.getProperty(ConstValues.A_TWEEN_EASING);
				if(tweenEase != tweenEase) {
					result.tweenEasing = Math.NaN;
				} else {
					result.tweenEasing = tweenEase;
				}
			}
			if(rawData.hasField(ConstValues.A_TWEEN_ROTATE)) {
				result.tweenRotate = cast(rawData.getProperty(ConstValues.A_TWEEN_ROTATE), Int);
			}
			if(rawData.hasField(ConstValues.A_DISPLAY_INDEX)) {
				result.displayIndex = cast(rawData.getProperty(ConstValues.A_DISPLAY_INDEX), Int);
			}
			if(rawData.hasField(ConstValues.A_Z_ORDER)) {
				result.zOrder = cast(rawData.getProperty(ConstValues.A_Z_ORDER), Float);
			}
			parseTransform(rawData.getProperty(ConstValues.TRANSFORM), result.global, result.pivot);
			result.transform.copy(result.global);
			var colorTransformObject:Dynamic = rawData.getProperty(ConstValues.COLOR_TRANSFORM);
			if(colorTransformObject != null) {
				result.color = new ColorTransform();
				result.color.alphaOffset = cast(colorTransformObject.getProperty(ConstValues.A_ALPHA_OFFSET), Float);
				result.color.redOffset = cast(colorTransformObject.getProperty(ConstValues.A_RED_OFFSET), Float);
				result.color.greenOffset = cast(colorTransformObject.getProperty(ConstValues.A_GREEN_OFFSET), Float);
				result.color.blueOffset = cast(colorTransformObject.getProperty(ConstValues.A_BLUE_OFFSET), Float);
				result.color.alphaMultiplier = cast(colorTransformObject.getProperty(ConstValues.A_ALPHA_MULTIPLIER), Float);
				result.color.redMultiplier = cast(colorTransformObject.getProperty(ConstValues.A_RED_MULTIPLIER), Float);
				result.color.greenMultiplier = cast(colorTransformObject.getProperty(ConstValues.A_GREEN_MULTIPLIER), Float);
				result.color.blueMultiplier = cast(colorTransformObject.getProperty(ConstValues.A_BLUE_MULTIPLIER), Float);
			}
			return result;
		}, frameRate);
		result.scale = cast(rawData.getProperty(ConstValues.A_SCALE), Float);
		result.offset = cast(rawData.getProperty(ConstValues.A_OFFSET), Float);
		return result;
	}
	
	static inline function parseFrame(rawData:Dynamic, result:Frame, frameRate:Int):Frame {
		result.duration = cast(rawData.getProperty(ConstValues.A_DURATION), Float) / frameRate;
		result.action = rawData.getProperty(ConstValues.A_ACTION);
		result.event = rawData.getProperty(ConstValues.A_EVENT);
		result.sound = rawData.getProperty(ConstValues.A_SOUND);
		return result;
	}
	
	static inline function parseTransform(?rawData:Dynamic, ?transform:DBTransform, ?pivot:Point):Void {
		if(rawData != null) {
			if(transform != null) {
				transform.x = cast(rawData.getProperty(ConstValues.A_X), Float);
				transform.y = cast(rawData.getProperty(ConstValues.A_Y), Float);
				transform.skewX = cast(rawData.getProperty(ConstValues.A_SKEW_X), Float) * ConstValues.ANGLE_TO_RADIAN;
				transform.skewY = cast(rawData.getProperty(ConstValues.A_SKEW_Y), Float) * ConstValues.ANGLE_TO_RADIAN;
				transform.scaleX = cast(rawData.getProperty(ConstValues.A_SCALE_X), Float);
				transform.scaleY = cast(rawData.getProperty(ConstValues.A_SCALE_Y), Float);
			}   
			if(pivot != null) {
				if(rawData.hasField(ConstValues.A_PIVOT_X)) {
					pivot.x = cast(rawData.getProperty(ConstValues.A_PIVOT_X), Float);
				} else {
					pivot.x = 0;
				}
				if(rawData.hasField(ConstValues.A_PIVOT_Y)) {
					pivot.y = cast(rawData.getProperty(ConstValues.A_PIVOT_Y), Float);
				} else {
					pivot.y = 0;
				}
			}
		}
	}
}*/

//#if debug 
class XMLDataParser {
//#else
//extern class XMLDataParser {
//#end
	public static inline function parseTextureAtlasData(rawData:Xml, scale:Float = 1):Dynamic {
		var result = { };
		result.setField("__name", rawData.firstElement().get(ConstValues.A_NAME));
		for (it in rawData.firstElement().elementsNamed(ConstValues.SUB_TEXTURE)) {
			var rect:Rectangle = new Rectangle();
			rect.x = it.get(ConstValues.A_X).parseInt() / scale;
			rect.y = it.get(ConstValues.A_Y).parseInt() / scale;
			rect.width = it.get(ConstValues.A_WIDTH).parseInt() / scale;
			rect.height = it.get(ConstValues.A_HEIGHT).parseInt() / scale;
			result.setField(it.get(ConstValues.A_NAME), rect);
		}
		return result;
	}
	
	public static inline function parseSkeletonData(rawData:Xml):SkeletonData {
		if(rawData == null) {
			throw "error";//new ArgumentError("the xml argument must not be null");
		}
		var v = rawData.firstElement().get(ConstValues.A_VERSION);
		if(ConstValues.OLD_VERSIONS.has(v)) {
			return null;//OldXMLDataParser.parse(rawData);
		} else if (v != DragonBones.DATA_VERSION) {
			throw "non supported version error";//new NonSupportVersionError();
			return null;
		} else {
			var frameRate = rawData.firstElement().get(ConstValues.A_FRAME_RATE).parseInt();
			var data = new SkeletonData();
			data.name = rawData.firstElement().get(ConstValues.A_NAME);
			for(armature in rawData.firstElement().elementsNamed(ConstValues.ARMATURE)) {
				data.addArmatureData(parseArmatureData(armature, data, frameRate));
			}
			return data;
		}
	}
	
	static inline function parseArmatureData(rawData:Xml, data:SkeletonData, frameRate:Int):ArmatureData {
		var armatureData = new ArmatureData();
		armatureData.name = rawData.get(ConstValues.A_NAME);
		for(it in rawData.elementsNamed(ConstValues.BONE)) {
			armatureData.addBoneData(parseBoneData(it));
		}
		for(it in rawData.elementsNamed(ConstValues.SKIN)) {
			armatureData.addSkinData(parseSkinData(it, data));
		}
		DBDataUtil.transformArmatureData(armatureData);
		armatureData.sortBoneDataList();
		for(it in rawData.elementsNamed(ConstValues.ANIMATION)) {
			armatureData.addAnimationData(parseAnimationData(it, armatureData, frameRate));
		}
		return armatureData;
	}
	
	static inline function parseBoneData(rawData:Xml):BoneData {
		var boneData = new BoneData();
		boneData.name = rawData.get(ConstValues.A_NAME);
		boneData.parent = rawData.get(ConstValues.A_PARENT);
		boneData.length = rawData.get(ConstValues.A_LENGTH).parseFloat();
		var inheritScale = rawData.get(ConstValues.A_SCALE_MODE);
		if(inheritScale != null) {
			boneData.scaleMode = inheritScale.parseInt();
		}
		var temp = rawData.get(ConstValues.A_FIXED_ROTATION);
		if (temp != null) {
			var fixedRotation = temp.split(",")[0];
			boneData.fixedRotation = !["0", "false", "no", "", null].has(fixedRotation);
		}
		return boneData;
	}
	
	static inline function parseSkinData(rawData:Xml, data:SkeletonData):SkinData {
		var skinData = new SkinData();
		skinData.name = rawData.get(ConstValues.A_NAME);
		for(it in rawData.elementsNamed(ConstValues.SLOT)) {
			skinData.addSlotData(parseSlotData(it, data));
		}
		return skinData;
	}
	
	static inline function parseSlotData(rawData:Xml, data:SkeletonData):SlotData {
		var slotData = new SlotData();
		slotData.name = rawData.get(ConstValues.A_NAME);
		slotData.parent = rawData.get(ConstValues.A_PARENT);
		slotData.zOrder = rawData.get(ConstValues.A_Z_ORDER).parseFloat();
		slotData.blendMode = rawData.get(ConstValues.A_BLENDMODE);
		if(slotData.blendMode == null) {
			slotData.blendMode = "normal";
		}
		for(it in rawData.elementsNamed(ConstValues.DISPLAY)) {
			slotData.addDisplayData(parseDisplayData(it, data));
		}
		return slotData;
	}
	
	static inline function parseDisplayData(rawData:Xml, data:SkeletonData):DisplayData {
		var displayData = new DisplayData();
		displayData.name = rawData.get(ConstValues.A_NAME);
		displayData.type = rawData.get(ConstValues.A_TYPE);
		displayData.pivot = data.addSubTexturePivot(0, 0, displayData.name);
		parseTransform(rawData.elementsNamed(ConstValues.TRANSFORM).next(), displayData.transform, displayData.pivot);
		return displayData;
	}
	
	static inline function parseTransform(rawData:Xml, transform:DBTransform, pivot:Point):Void {
		if(rawData != null) {
			if(transform != null) {
				transform.x = rawData.get(ConstValues.A_X).parseFloat();
				transform.y = rawData.get(ConstValues.A_Y).parseFloat();
				transform.skewX = rawData.get(ConstValues.A_SKEW_X).parseFloat() * ConstValues.ANGLE_TO_RADIAN;
				transform.skewY = rawData.get(ConstValues.A_SKEW_Y).parseFloat() * ConstValues.ANGLE_TO_RADIAN;
				transform.scaleX = rawData.get(ConstValues.A_SCALE_X).parseFloat();
				transform.scaleY = rawData.get(ConstValues.A_SCALE_Y).parseFloat();
			}
			if(pivot != null) {
				pivot.setTo(rawData.get(ConstValues.A_PIVOT_X).parseFloat(), rawData.get(ConstValues.A_PIVOT_Y).parseFloat());
			}
		}
	}
	
	static inline function parseAnimationData(rawData:Xml, data:ArmatureData, frameRate:Int):AnimationData {
		var animationData = new AnimationData();
		animationData.name = rawData.get(ConstValues.A_NAME);
		animationData.frameRate = frameRate;
		animationData.loop = rawData.get(ConstValues.A_LOOP).parseInt();
		animationData.fadeInTime = rawData.get(ConstValues.A_FADE_IN_TIME).parseFloat();
		animationData.duration = rawData.get(ConstValues.A_DURATION).parseFloat() / frameRate;
		animationData.scale = rawData.get(ConstValues.A_SCALE).parseFloat();
		animationData.tweenEasing = rawData.get(ConstValues.A_TWEEN_EASING).parseFloat();
		parseTimeline(rawData, animationData, function(rawData:Xml, frameRate:Int):Frame {
			return parseFrame(rawData, new Frame(), frameRate);
		}, frameRate);
		for(it in rawData.elementsNamed(ConstValues.TIMELINE)) {
			var timeline = parseTransformTimeline(it, animationData.duration, frameRate);
			var timelineName = it.get(ConstValues.A_NAME);
			animationData.addTimeline(timeline, timelineName);
		}
		DBDataUtil.addHideTimeline(animationData, data);
		DBDataUtil.transformAnimationData(animationData, data);
		return animationData;
	}
	
	static inline function parseTransformTimeline(rawData:Xml, duration:Float, frameRate:Int):TransformTimeline {
		var timeline = new TransformTimeline();
		timeline.duration = duration;
		parseTimeline(rawData, timeline, function(rawData:Xml, frameRate:Int):TransformFrame {
			var frame = new TransformFrame();
			parseFrame(rawData, frame, frameRate);
			
			#if js
			var rvisible = rawData.get(ConstValues.A_HIDE).parseInt() != 1;
			var rtweenEasing = rawData.get(ConstValues.A_TWEEN_EASING).parseFloat();
			var rtweenRotate = rawData.get(ConstValues.A_TWEEN_ROTATE).parseInt();
			var rdisplayIndex = rawData.get(ConstValues.A_DISPLAY_INDEX).parseInt();
			var rzOrder = rawData.get(ConstValues.A_Z_ORDER).parseFloat();
			if (rvisible != null) frame.visible = rvisible;
			if (rtweenEasing != null) frame.tweenEasing = rtweenEasing;
			if (rtweenRotate != null) frame.tweenRotate = rtweenRotate;
			if (rdisplayIndex != null) frame.displayIndex = rdisplayIndex;
			if (rzOrder != null) frame.zOrder = rzOrder;
			#else
			frame.visible = rawData.get(ConstValues.A_HIDE).parseInt() != 1;
			frame.tweenEasing = rawData.get(ConstValues.A_TWEEN_EASING).parseFloat();
			frame.tweenRotate = rawData.get(ConstValues.A_TWEEN_ROTATE).parseInt();
			frame.displayIndex = rawData.get(ConstValues.A_DISPLAY_INDEX).parseInt();
			
			//frame.zOrder = rawData.firstElement().get(ConstValues.A_Z_ORDER).parseFloat();
			frame.zOrder = rawData.get(ConstValues.A_Z_ORDER).parseFloat();
			#end
			
			parseTransform(rawData.elementsNamed(ConstValues.TRANSFORM).next(), frame.global, frame.pivot);
			frame.transform.copy(frame.global);
			
			rawData = rawData.elementsNamed(ConstValues.COLOR_TRANSFORM).next();
			if(rawData != null) {
				frame.color = new ColorTransform();
				frame.color.alphaOffset = rawData.get(ConstValues.A_ALPHA_OFFSET).parseFloat();
				frame.color.redOffset = rawData.get(ConstValues.A_RED_OFFSET).parseFloat();
				frame.color.greenOffset = rawData.get(ConstValues.A_GREEN_OFFSET).parseFloat();
				frame.color.blueOffset = rawData.get(ConstValues.A_BLUE_OFFSET).parseFloat();
				frame.color.alphaMultiplier = rawData.get(ConstValues.A_ALPHA_MULTIPLIER).parseFloat() * 0.01;
				frame.color.redMultiplier = rawData.get(ConstValues.A_RED_MULTIPLIER).parseFloat() * 0.01;
				frame.color.greenMultiplier = rawData.get(ConstValues.A_GREEN_MULTIPLIER).parseFloat() * 0.01;
				frame.color.blueMultiplier = rawData.get(ConstValues.A_BLUE_MULTIPLIER).parseFloat() * 0.01;
			}
			return frame;
		}, frameRate);
		timeline.scale = rawData.get(ConstValues.A_SCALE).parseFloat();
		timeline.offset = rawData.get(ConstValues.A_OFFSET).parseFloat();
		return timeline;
	}
	
	static inline function parseTimeline(rawData:Xml, timeline:Timeline, frameParser:Xml->Int->Frame, frameRate:Int):Void {
		var position:Float = 0;
		var frame:Frame = null;
		for(it in rawData.elementsNamed(ConstValues.FRAME)) {
			frame = frameParser(it, frameRate);
			frame.position = position;
			timeline.addFrame(frame);
			position += frame.duration;
		}
		if(frame != null) {
			frame.duration = timeline.duration - frame.position;
		}
	}
	
	static inline function parseFrame(rawDaya:Xml, result:Frame, frameRate:Int):Frame {
		result.duration = rawDaya.get(ConstValues.A_DURATION).parseFloat() / frameRate;
		result.action = rawDaya.get(ConstValues.A_ACTION);
		result.event = rawDaya.get(ConstValues.A_EVENT);
		result.sound = rawDaya.get(ConstValues.A_SOUND);
		return result;
	}
}

/*#if debug
class OldXMLDataParser {
#else
extern class OldXMLDataParser {
#end
	public static inline function parse(rawData:Xml):SkeletonData {
		var frameRate = rawData.firstElement().get(ConstValues.A_FRAME_RATE).parseInt();
		var result = new SkeletonData();
		result.name = rawData.firstElement().get(ConstValues.A_NAME);
		for(armaturesData in rawData.firstElement().elementsNamed(OldConstValues.ARMATURES)) {
			for(it in armaturesData.elementsNamed(OldConstValues.ARMATURE)) {
				result.addArmatureData(parseArmatureData(it, result));
			}
		}
		for(animationsData in rawData.firstElement().elementsNamed(OldConstValues.ANIMATIONS)) {
			for(it in animationsData.elementsNamed(OldConstValues.ANIMATION)) {
				var armatureData = result.getArmatureData(it.get(OldConstValues.A_NAME));
				if(armatureData != null) {
					for(animationData in it.elementsNamed(OldConstValues.MOVEMENT)) {
						armatureData.addAnimationData(parseAnimationData(animationData, armatureData, frameRate));
					}
				}
			}
		}
		return result;
	}
	
	static inline function parseArmatureData(rawData:Xml, data:SkeletonData):ArmatureData {
		var result = new ArmatureData();
		result.name = rawData.get(OldConstValues.A_NAME);
		for(it in rawData.elementsNamed(OldConstValues.BONE)) {
			result.addBoneData(parseBoneData(it));
		}
		result.addSkinData(parseSkinData(rawData, data));
		DBDataUtil.transformArmatureData(result);
		result.sortBoneDataList();
		return result;
	}
	
	static inline function parseBoneData(rawData:Xml):BoneData {
		var result = new BoneData();
		result.name = rawData.get(OldConstValues.A_NAME);
		result.parent = rawData.get(OldConstValues.A_PARENT);
		parseTransform(rawData, result.global);
		result.transform.copy(result.global);
		return result;
	}
	
	static inline function parseSkinData(rawData:Xml, data:SkeletonData):SkinData {
		var result = new SkinData();
		for(it in rawData.elementsNamed(OldConstValues.BONE)) {
			result.addSlotData(parseSlotData(it, data));
		}
		return result;
	}
	
	static inline function parseSlotData(rawData:Xml, data:SkeletonData):SlotData {
		var result = new SlotData();
		result.name = rawData.get(OldConstValues.A_NAME);
		result.parent = result.name;
		result.zOrder = rawData.get(OldConstValues.A_Z_ORDER).parseFloat();
		for(it in rawData.elementsNamed(OldConstValues.DISPLAY)) {
			result.addDisplayData(parseDisplayData(it, data));
		}
		return result;
	}
	
	static inline function parseDisplayData(rawData:Xml, data:SkeletonData):DisplayData {
		var result = new DisplayData();
		result.name = rawData.get(OldConstValues.A_NAME);
		if(rawData.get(OldConstValues.A_TYPE).parseInt() == 1) {
			result.type = DisplayData.ARMATURE;
		} else {
			result.type = DisplayData.IMAGE;
		}
		result.transform.x = Math.NaN;
		result.transform.y = Math.NaN;
		result.transform.skewX = 0;
		result.transform.skewY = 0;
		result.transform.scaleX = 1;
		result.transform.scaleY = 1;
		result.pivot = data.addSubTexturePivot(rawData.get(OldConstValues.A_PIVOT_X).parseFloat(), rawData.get(OldConstValues.A_PIVOT_Y).parseFloat(),  result.name );
		return result;
	}
	
	static inline function parseAnimationData(rawData:Xml, armatureData:ArmatureData, frameRate:Int):AnimationData {
		var result = new AnimationData();
		result.name = rawData.get(OldConstValues.A_NAME);
		result.frameRate = frameRate;
		result.loop = rawData.get(OldConstValues.A_LOOP).parseInt() == 1 ? 0 : 1;
		result.fadeInTime = rawData.get(OldConstValues.A_FADE_IN_TIME).parseInt() / frameRate;
		result.duration = rawData.get(OldConstValues.A_DURATION).parseInt() / frameRate;
		var durationTween = rawData.get(OldConstValues.A_DURATION_TWEEN).split(",")[0].parseFloat();
		if(durationTween != durationTween) {
			result.scale = 1;
		} else {
			result.scale = durationTween / frameRate / result.duration;
		}
		result.tweenEasing = rawData.get(OldConstValues.A_TWEEN_EASING).split(",")[0].parseFloat();
		parseTimeline(rawData, result, function(rawData:Xml, frameRate:Int):Frame {
			return parseFrame(rawData, new Frame(), frameRate);
		}, frameRate);
		var skinData = armatureData.skinDataList[0];
		for(it in rawData.elementsNamed(OldConstValues.BONE)) {
			var timeline = parseTransformTimeline(it, result.duration, frameRate);
			var timelineName = it.get(OldConstValues.A_NAME);
			result.addTimeline(timeline, timelineName);
			if(skinData != null) {
				formatDisplayTransformXYAndTimelinePivot(skinData.getSlotData(timelineName), timeline);
			}
		}
		DBDataUtil.addHideTimeline(result, armatureData);
		DBDataUtil.transformAnimationData(result, armatureData);
		return result;
	}
	
	static inline function parseTimeline(rawData:Xml, timeline:Timeline, frameParser:Xml->Int->Frame, frameRate:Int):Void {
		var position:Float = 0;
		var frame:Frame = null;
		for(it in rawData.elementsNamed(OldConstValues.FRAME)) {
			frame = frameParser(it, frameRate);
			frame.position = position;
			timeline.addFrame(frame);
			position += frame.duration;
		}
		if(frame != null) {
			frame.duration = timeline.duration - frame.position;
		}
	}
	
	static inline function parseTransformTimeline(rawData:Xml, duration:Float, frameRate:Int):TransformTimeline {
		var result = new TransformTimeline();
		result.duration = duration;
		parseTimeline(rawData, result, function(rawData:Xml, frameRate:Int):TransformFrame {
			var result = new TransformFrame();
			parseFrame(rawData, result, frameRate);
			result.visible = rawData.get(OldConstValues.A_VISIBLE) != null ? rawData.get(OldConstValues.A_VISIBLE).parseInt() == 1 : true;
			result.tweenEasing = rawData.get(OldConstValues.A_TWEEN_EASING).parseFloat();
			result.tweenRotate = rawData.get(OldConstValues.A_TWEEN_ROTATE).parseInt();
			result.displayIndex = rawData.get(OldConstValues.A_DISPLAY_INDEX).parseInt();
			result.zOrder = rawData.get(OldConstValues.A_Z_ORDER).parseInt();
			parseTransform(rawData, result.global, result.pivot);
			result.transform.copy(result.global);
			result.pivot.x *= -1;
			result.pivot.y *= -1;
			var colorTransformXML = rawData.elementsNamed(OldConstValues.COLOR_TRANSFORM).next();
			if(colorTransformXML != null) {
				result.color = new ColorTransform();
				result.color.alphaOffset = colorTransformXML.get(OldConstValues.A_ALPHA_OFFSET).parseInt();
				result.color.redOffset = colorTransformXML.get(OldConstValues.A_RED_OFFSET).parseInt();
				result.color.greenOffset = colorTransformXML.get(OldConstValues.A_GREEN_OFFSET).parseInt();
				result.color.blueOffset = colorTransformXML.get(OldConstValues.A_BLUE_OFFSET).parseInt();
				result.color.alphaMultiplier = colorTransformXML.get(OldConstValues.A_ALPHA_MULTIPLIER).parseInt() * 0.01;
				result.color.redMultiplier = colorTransformXML.get(OldConstValues.A_RED_MULTIPLIER).parseInt() * 0.01;
				result.color.greenMultiplier = colorTransformXML.get(OldConstValues.A_GREEN_MULTIPLIER).parseInt() * 0.01;
				result.color.blueMultiplier = colorTransformXML.get(OldConstValues.A_BLUE_MULTIPLIER).parseInt() * 0.01;
			}
			return result;
		}, frameRate);
		result.scale = rawData.get(OldConstValues.A_SCALE).parseFloat();
		result.offset = (1 - rawData.get(OldConstValues.A_OFFSET).parseFloat()) % 1;
		return result;
	}
	
	static inline function parseFrame(rawData:Xml, result:Frame, frameRate:Int):Frame {
		result.duration = rawData.get(OldConstValues.A_DURATION).parseInt() / frameRate;
		result.action = rawData.get(OldConstValues.A_ACTION);
		result.event = rawData.get(OldConstValues.A_EVENT);
		result.sound = rawData.get(OldConstValues.A_SOUND);
		return result;
	}
	
	static inline function parseTransform(?rawData:Xml, ?transform:DBTransform, ?pivot:Point):Void {
		if(rawData != null) {
			if(transform != null) {
				transform.x = rawData.get(OldConstValues.A_X).parseFloat();
				transform.y = rawData.get(OldConstValues.A_Y).parseFloat();
				transform.skewX = rawData.get(OldConstValues.A_SKEW_X).parseFloat() * ConstValues.ANGLE_TO_RADIAN;
				transform.skewY = rawData.get(OldConstValues.A_SKEW_Y).parseFloat() * ConstValues.ANGLE_TO_RADIAN;
				transform.scaleX = rawData.get(OldConstValues.A_SCALE_X).parseFloat();
				transform.scaleY = rawData.get(OldConstValues.A_SCALE_Y).parseFloat();
			}
			if(pivot != null) {
				pivot.x = rawData.get(OldConstValues.A_PIVOT_X).parseFloat();
				pivot.y = rawData.get(OldConstValues.A_PIVOT_Y).parseFloat();
			}
		}
	}
	
	static inline function formatDisplayTransformXYAndTimelinePivot(slotData:SlotData, timeline:TransformTimeline):Void {
		if(slotData != null) {
			for(frame in timeline.frameList) {
				var transformFrame = cast(frame, TransformFrame);
				if(transformFrame.displayIndex >= 0) {
					var displayData = slotData.displayDataList[transformFrame.displayIndex];
					if(displayData.transform.x != displayData.transform.x) {
						displayData.transform.x = transformFrame.pivot.x;
						displayData.transform.y = transformFrame.pivot.y;
					}
					transformFrame.pivot.offset(-displayData.transform.x, -displayData.transform.y);
				}
			}
		}
	}
}*/
