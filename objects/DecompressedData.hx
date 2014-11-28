package dragonbones.objects;
import dragonbones.Interfaces.IDisposable;
//import dragonbones.flash.ByteArray;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
@:final class DecompressedData implements IDisposable {

	public function new(dragonBonesData:Dynamic, textureAtlasData:Dynamic) {
		this.dragonBonesData = dragonBonesData;
		this.textureAtlasData = textureAtlasData;

		var element = textureAtlasData.firstElement();
        var textureName = element.get("imagePath").split(".")[0];
		texture = fox.sys.Assets.getImage(textureName);
	}
	
	public var dragonBonesData:Xml;
	public var textureAtlasData:Xml;
	public var texture:kha.Image;
	
	public function dispose() {
		this.dragonBonesData = null;
		this.textureAtlasData = null;
		this.texture = null;
	}
}
