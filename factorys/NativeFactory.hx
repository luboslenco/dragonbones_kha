package dragonbones.factorys;
import dragonbones.Armature;
import dragonbones.display.NativeDisplayBridge;
import dragonbones.factorys.BaseFactory;
import dragonbones.Slot;
import dragonbones.textures.ITextureAtlas;
import dragonbones.textures.NativeTextureAtlas;
import dragonbones.flash.DisplayObject;
using Std;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class NativeFactory extends BaseFactory {

	public function new() { super(); }
	
	override function generateTextureAtlas(content:Dynamic, texAtlasRawData:Dynamic):ITextureAtlas {
		return new NativeTextureAtlas(content, texAtlasRawData, 1, false);
	}
	
	override function generateArmature():Armature return new Armature(new DisplayObject(null));
	
	override function generateSlot():Slot return new Slot(new NativeDisplayBridge());
	
	override function generateDisplay(texAtlass:Dynamic, name:String, pivotX:Float, pivotY:Float):DisplayObject {
		var nativeTexAtlas:NativeTextureAtlas = null;
		if(texAtlass.is(NativeTextureAtlas)) {
			nativeTexAtlas = cast(texAtlass, NativeTextureAtlas);
		}
		if(nativeTexAtlas == null) {
			return null;
		}

		if(nativeTexAtlas.texture != null) {
			var subTextureData = nativeTexAtlas.getRegion(name);
			if (subTextureData != null) {
				var obj = new DisplayObject(nativeTexAtlas.texture);
				obj.sourceX = subTextureData.x;
				obj.sourceY = subTextureData.y;
				obj.sourceW = subTextureData.width;
				obj.sourceH = subTextureData.height;
				obj.w = obj.sourceW;
				obj.h = obj.sourceH;
				obj.pivotX = pivotX;
				obj.pivotY = pivotY;
				return obj;
			}
		} else {
			throw "error";
		}

		return null;
	}
}
