package dragonbones.textures;
import dragonbones.Interfaces.IDisposable;
import dragonbones.Interfaces.INameable;
import dragonbones.flash.Rectangle;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */

interface ITextureAtlas extends INameable extends IDisposable {
	var name(default, default):String;
	function getRegion(name:String):Rectangle;
}
