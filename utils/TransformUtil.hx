package dragonbones.utils;
import dragonbones.objects.DBTransform;
import dragonbones.flash.Matrix;
import dragonbones.flash.Point;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class TransformUtil{
	
	static var _helpMatrix:Matrix = new Matrix();
	static var _helpPoint:Point = new Point();
	
	public static inline function transformPointWithParent(transform:DBTransform, parent:DBTransform) {
		transformToMatrix(parent, _helpMatrix);
		
		_helpMatrix.invert();
		
		var x:Float = transform.x;
		var y:Float = transform.y;
		
		transform.x = _helpMatrix.a * x + _helpMatrix.c * y + _helpMatrix.tx;
		transform.y = _helpMatrix.d * y + _helpMatrix.b * x + _helpMatrix.ty;
		transform.skewX = formatRadian(transform.skewX - parent.skewX);
		transform.skewY = formatRadian(transform.skewY - parent.skewY);
	}
	
	public static inline function transformToMatrix(transform:DBTransform, matrix:Matrix) {
		matrix.a = transform.scaleX * Math.cos(transform.skewY);
		matrix.b = transform.scaleX * Math.sin(transform.skewY);
		matrix.c = -transform.scaleY * Math.sin(transform.skewX);
		matrix.d = transform.scaleY * Math.cos(transform.skewX);
		matrix.tx = transform.x;
		matrix.ty = transform.y;
	}
	
	public static inline function formatRadian(radian:Float):Float {
		radian %= ConstValues.DOUBLE_PI;
		if (radian > Math.PI) {
			radian -= ConstValues.DOUBLE_PI;
		}
		if (radian < -Math.PI) {
			radian += ConstValues.DOUBLE_PI;
		}
		return radian;
	}
}
