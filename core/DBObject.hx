package dragonbones.core;
import dragonbones.Armature;
import dragonbones.Bone;
import dragonbones.Interfaces.IDisposable;
import dragonbones.Interfaces.INameable;
import dragonbones.objects.DBTransform;
import dragonbones.flash.Matrix;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class DBObject implements INameable implements IDisposable {

	public function new() {
		global = new DBTransform();
		origin = new DBTransform();
		offset = new DBTransform();
		tween = new DBTransform();
		tween.scaleX = 0;
		tween.scaleY = 0;
		globalTransformMatrix = new Matrix();
		_visible = true;
	}
	
	public var name(default, default):String;
	public var userData:Dynamic;
	public var fixedRotation:Bool;
	public var global(default, null):DBTransform;
	public var origin(default, null):DBTransform;
	public var offset(default, null):DBTransform;
	public var node(get, null):DBTransform;
	public var visible(get, set):Bool;
	public var parent(default, null):Bone;
	public var armature(default, null):Armature;
	
	var _scaleType:Int;
	var _visible:Bool;
	
	function get_visible():Bool return _visible;
	
	function set_visible(value:Bool):Bool {
		_visible = value;
		return _visible;
	}
	
	function get_node():DBTransform return offset;
	
	//{ region dragonBones_internal
	public var globalTransformMatrix:Matrix;
	public var isColorChanged:Bool;
	public var tween:DBTransform;
	
	public function setParent(value:Bone) parent = value;
	
	public function setArmature(value:Armature) {
		if(armature != null) {
			armature.removeDBObject(this);
		}
		armature = value;
		if(armature != null) {
			armature.addDBObject(this);
		}
	}
	
	public function update() {
		global.scaleX = (origin.scaleX + tween.scaleX) * offset.scaleX;
		global.scaleY = (origin.scaleY + tween.scaleY) * offset.scaleY;
		if(parent != null) {
			var x = origin.x + offset.x + tween.x;
			var y = origin.y + offset.y + tween.y;
			var parentMatrix = parent.globalTransformMatrix;
			
			global.x = parentMatrix.a * x + parentMatrix.c * y + parentMatrix.tx;
			global.y = parentMatrix.d * y + parentMatrix.b * x + parentMatrix.ty;
			globalTransformMatrix.tx = global.x;
			globalTransformMatrix.ty = global.y;
			global.skewX = origin.skewX + offset.skewX + tween.skewX;
			global.skewY = origin.skewY + offset.skewY + tween.skewY;
			
			if(!fixedRotation) {
				global.skewX += parent.global.skewX;
				global.skewY += parent.global.skewY;
			}
			if(parent.scaleMode >= _scaleType) {
				global.scaleX *= parent.global.scaleX;
				global.scaleY *= parent.global.scaleY;
			}
		} else {
			global.x = origin.x + offset.x + tween.x;
			global.y = origin.y + offset.y + tween.y;
			globalTransformMatrix.tx = global.x;
			globalTransformMatrix.ty = global.y;
			global.skewX = origin.skewX + offset.skewX + tween.skewX;
			global.skewY = origin.skewY + offset.skewY + tween.skewY;
		}
		globalTransformMatrix.a = global.scaleX * Math.cos(global.skewY);
		globalTransformMatrix.b = global.scaleX * Math.sin(global.skewY);
		globalTransformMatrix.c = -global.scaleY * Math.sin(global.skewX);
		globalTransformMatrix.d = global.scaleY * Math.cos(global.skewX);
	}
	//} endregion
	
	public function dispose() {
		userData = null;
		parent = null;
		armature = null;
		global = null;
		origin = null;
		offset = null;
		tween = null;
		globalTransformMatrix = null;
	}
}
