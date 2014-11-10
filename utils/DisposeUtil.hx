package dragonbones.utils;
import dragonbones.Interfaces.IDisposable;
import msignal.Signal;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
extern class DisposeUtil {

	/**
	 * @return null only
	 */
	public static inline function dispose(target:Dynamic):Dynamic {
		if(Std.is(target, IDisposable)) {
			cast(target, IDisposable).dispose();
		} else if(Std.is(target, AnySignal)) {
			cast(target, AnySignal).removeAll();
		}//TODO: else target is Iterable
		return null;
	}
}