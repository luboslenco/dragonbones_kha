package dragonbones.utils;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
extern class BytesType {
	
	public static inline var SWF = "swf";
	public static inline var PNG = "png";
	public static inline var JPG = "jpg";
	public static inline var ATF = "atf";
	public static inline var ZIP = "zip";
	
	public static inline function getType(bytes:dragonbones.flash.ByteArray):String {
		var result:String = null;
		#if js
		var b1 = bytes.readByte();
		var b2 = bytes.readByte();
		var b3 = bytes.readByte();
		var b4 = bytes.readByte();
		bytes.position = 0;
		#else
		var b1 = bytes[0];
		var b2 = bytes[1];
		var b3 = bytes[2];
		var b4 = bytes[3];
		#end
		
		if(((b1 == 0x46) || (b1 == 0x43) || (b1 == 0x5A)) && (b2 == 0x57) && (b3 == 0x53)) {
			//CWS FWS ZWS
			result = SWF;
		} else if((b1 == 0x89) && (b2 == 0x50) && (b3 == 0x4E) && (b4 == 0x47)) {
			//89 50 4e 47 0d 0a 1a 0a
			result = PNG;
		} else if(b1 == 0xFF) {
			result = JPG;
		} else if((b1 == 0x41) && (b2 == 0x54) && (b3 == 0x46)) {
			result = ATF;
		} else if((b1 == 0x50) && (b2 == 0x4B)) {
			result = ZIP;
		}
		return result;
	}
}
