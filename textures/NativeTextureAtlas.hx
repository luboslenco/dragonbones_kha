package dragonbones.textures;
import dragonbones.utils.ConstValues;
import dragonbones.utils.DisposeUtil;
import dragonbones.flash.Rectangle;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class NativeTextureAtlas implements ITextureAtlas {

	public function new(texture:Dynamic, texAtlasXml:Xml, scale:Float = 1, ?isDifferentXML:Bool) {
		this.scale = scale;
		_isDifferentXML = isDifferentXML;
		
		_name2SubTexData = new Map();
		
		this.texture = texture;
		
		parseData(texAtlasXml);
	}
	
	public var texture(default, null):kha.Image;
	public var name(default, default):String;
	public var scale(default, null):Float;
	
	var _name2SubTexData:Map<String, Rectangle>;
	var _isDifferentXML:Bool;
	
	public function dispose() {
		name = null;
		texture = null;
		_name2SubTexData = null;
	}
	
	public function getRegion(name:String):Rectangle {
		return _name2SubTexData.get(name);
	}
	
	inline function parseData(texAtlasXml:Xml) {
		name = texAtlasXml.firstElement().get(ConstValues.A_NAME);
		
		var scale = _isDifferentXML ? scale : 1;
		
		for (subTexXml in texAtlasXml.firstElement().elementsNamed(ConstValues.SUB_TEXTURE)) {
			var subTexName = subTexXml.get(ConstValues.A_NAME);
			var subTexData = new SubTextureData();
			
			subTexData.x = Std.parseInt(subTexXml.get(ConstValues.A_X)) / scale;
			subTexData.y = Std.parseInt(subTexXml.get(ConstValues.A_Y)) / scale;
			subTexData.width = Std.parseInt(subTexXml.get(ConstValues.A_WIDTH)) / scale;
			subTexData.height = Std.parseInt(subTexXml.get(ConstValues.A_HEIGHT)) / scale;
			
			//1.4
			//subTexData.pivotX = Std.parseInt(subTexXml.get(ConstValues.A_PIVOT_X));
			//subTexData.pivotY = Std.parseInt(subTexXml.get(ConstValues.A_PIVOT_Y));
			
			_name2SubTexData.set(subTexName, subTexData);
		}
	}	
}
