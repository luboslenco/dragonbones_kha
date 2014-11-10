package dragonbones.flash;


import dragonbones.flash.ByteArray;


interface IMemoryRange {
	
	
	public function getByteBuffer ():ByteArray;
	public function getStart ():Int;
	public function getLength ():Int;
	
	
}
