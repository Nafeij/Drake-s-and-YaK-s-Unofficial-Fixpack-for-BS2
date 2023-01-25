package air.fmodstudio.ane
{
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   
   public class FmodEventId
   {
       
      
      private var _bytes:ByteArray = null;
      
      public function FmodEventId(param1:ByteArray)
      {
         super();
         this._bytes = new ByteArray();
         this._bytes.length = param1.length;
         this._bytes.endian = param1.endian;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            this._bytes[_loc2_] = param1[_loc2_];
            _loc2_++;
         }
      }
      
      public static function createFromDesc(param1:String) : FmodEventId
      {
         var _loc2_:ByteArray = FmodEventId.descToBytes(param1);
         return !!_loc2_ ? new FmodEventId(_loc2_) : null;
      }
      
      public static function formatBytes(param1:ByteArray, param2:Boolean) : String
      {
         var _loc4_:String = null;
         if(param1.length != 20)
         {
            return "<invalid number of event id bytes: " + param1.length + ">";
         }
         var _loc3_:* = param1[16] << 24 | param1[17] << 16 | param1[18] << 8 | param1[19];
         if(param2)
         {
            _loc4_ = "{";
            _loc4_ += byteToHexString(param1[0]) + byteToHexString(param1[1]) + byteToHexString(param1[2]) + byteToHexString(param1[3]) + "-" + byteToHexString(param1[4]) + byteToHexString(param1[5]) + "-" + byteToHexString(param1[6]) + byteToHexString(param1[7]) + "-" + byteToHexString(param1[8]) + byteToHexString(param1[9]) + "-" + byteToHexString(param1[10]) + byteToHexString(param1[11]) + byteToHexString(param1[12]) + byteToHexString(param1[13]) + byteToHexString(param1[14]) + byteToHexString(param1[15]) + "}-";
            return _loc4_ + _loc3_.toString();
         }
         return _loc3_.toString();
      }
      
      private static function byteToHexString(param1:int) : String
      {
         if(param1 < 0 || param1 > 255)
         {
            param1 = 0;
         }
         var _loc2_:String = param1.toString(16);
         if(param1 > 9)
         {
            _loc2_ = _loc2_.toLowerCase();
         }
         if(_loc2_.length < 2)
         {
            _loc2_ = "0" + _loc2_;
         }
         return _loc2_;
      }
      
      public static function descToBytes(param1:String) : ByteArray
      {
         var _loc2_:RegExp = /\s*\{([a-z0-9]{2})([a-z0-9]{2})([a-z0-9]{2})([a-z0-9]{2})-([a-z0-9]{2})([a-z0-9]{2})-([a-z0-9]{2})([a-z0-9]{2})-([a-z0-9]{2})([a-z0-9]{2})-([a-z0-9]{2})([a-z0-9]{2})([a-z0-9]{2})([a-z0-9]{2})([a-z0-9]{2})([a-z0-9]{2})\}-(\d+)/;
         var _loc3_:Array = _loc2_.exec(param1);
         if(!_loc3_ || _loc3_.length < 18)
         {
            return null;
         }
         var _loc4_:ByteArray = new ByteArray();
         _loc4_.endian = Endian.BIG_ENDIAN;
         var _loc5_:int = 0;
         while(_loc5_ < 16)
         {
            _loc4_.writeByte(parseInt(_loc3_[_loc5_ + 1],16));
            _loc5_++;
         }
         _loc4_.writeInt(_loc3_[17]);
         return _loc4_;
      }
      
      public function get bytes() : ByteArray
      {
         return this._bytes;
      }
      
      public function equals(param1:FmodEventId) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(this._bytes.length != param1.bytes.length)
         {
            return false;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._bytes.length)
         {
            if(this._bytes[_loc2_] != param1.bytes[_loc2_])
            {
               return false;
            }
            _loc2_++;
         }
         return true;
      }
      
      public function toString() : String
      {
         return FmodEventId.formatBytes(this._bytes,false);
      }
      
      public function toFullString() : String
      {
         return FmodEventId.formatBytes(this._bytes,true);
      }
   }
}
