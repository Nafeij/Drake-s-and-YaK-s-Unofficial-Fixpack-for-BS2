package lib.engine.resource.air
{
   public class ZipFileResourceFileInfo
   {
       
      
      private var _offset:uint;
      
      private var _compressedSize:uint;
      
      private var _uncompressedSize:uint;
      
      private var _compressionMethod:uint;
      
      public function ZipFileResourceFileInfo(param1:uint, param2:uint, param3:uint, param4:uint = 0)
      {
         super();
         this._offset = param1;
         this._compressedSize = param2;
         this._uncompressedSize = param3;
         this._compressionMethod = param4;
      }
      
      public function get offset() : uint
      {
         return this._offset;
      }
      
      public function get compressedSize() : uint
      {
         return this._compressedSize;
      }
      
      public function get uncompressedSize() : uint
      {
         return this._uncompressedSize;
      }
      
      public function get compressionMethod() : uint
      {
         return this._compressionMethod;
      }
   }
}
