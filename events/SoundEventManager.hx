package dragonbones.events;
//import flash.events.EventDispatcher;
//import flash.events.IEventDispatcher;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */

class SoundEventManager {//extends EventDispatcher {
	
	public static var instance(get, null):SoundEventManager;
	
	static function get_instance():SoundEventManager {
		if (instance == null) {
			instance = new SoundEventManager();
		}
		return instance;
	}
	
	function new(/*?target:IEventDispatcher*/) {
		//super(target);
	}
}
