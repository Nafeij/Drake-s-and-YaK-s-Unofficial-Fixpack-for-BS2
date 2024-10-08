package starling.textures
{
   import flash.display3D.Context3DTextureFormat;
   import flash.utils.ByteArray;
   
   public class AtfData
   {
       
      
      private var mFormat:String;
      
      private var mWidth:int;
      
      private var mHeight:int;
      
      private var mNumTextures:int;
      
      private var mIsCubeMap:Boolean;
      
      private var mData:ByteArray;
      
      public function AtfData(param1:ByteArray)
      {
         var _loc3_:* = false;
         var _loc4_:* = 0;
         super();
         if(!isAtfData(param1))
         {
            throw new ArgumentError("Invalid ATF data");
         }
         if(param1[6] == 255)
         {
            param1.position = 12;
         }
         else
         {
            param1.position = 6;
         }
         var _loc2_:uint = param1.readUnsignedByte();
         switch(_loc2_ & 127)
         {
            case 0:
            case 1:
               this.mFormat = Context3DTextureFormat.BGRA;
               break;
            case 12:
            case 2:
            case 3:
               this.mFormat = Context3DTextureFormat.COMPRESSED;
               break;
            case 13:
            case 4:
            case 5:
               this.mFormat = "compressedAlpha";
               break;
            default:
               throw new Error("Invalid ATF format");
         }
         this.mWidth = Math.pow(2,param1.readUnsignedByte());
         this.mHeight = Math.pow(2,param1.readUnsignedByte());
         this.mNumTextures = param1.readUnsignedByte();
         this.mIsCubeMap = (_loc2_ & 128) != 0;
         this.mData = param1;
         if(param1[5] != 0 && param1[6] == 255)
         {
            _loc3_ = (param1[5] & 1) == 1;
            _loc4_ = param1[5] >> 1 & 127;
            this.mNumTextures = _loc3_ ? 1 : _loc4_;
         }
      }
      
      public static function isAtfData(param1:ByteArray) : Boolean
      {
         var _loc2_:String = null;
         if(param1.length < 3)
         {
            return false;
         }
         _loc2_ = String.fromCharCode(param1[0],param1[1],param1[2]);
         return _loc2_ == "ATF";
      }
      
      public function get format() : String
      {
         return this.mFormat;
      }
      
      public function get width() : int
      {
         return this.mWidth;
      }
      
      public function get height() : int
      {
         return this.mHeight;
      }
      
      public function get numTextures() : int
      {
         return this.mNumTextures;
      }
      
      public function get isCubeMap() : Boolean
      {
         return this.mIsCubeMap;
      }
      
      public function get data() : ByteArray
      {
         return this.mData;
      }
   }
}
