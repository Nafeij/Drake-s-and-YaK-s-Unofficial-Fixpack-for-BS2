package lib.engine.resource.air
{
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import flash.utils.IDataInput;
   
   public class ZipFileStream implements IDataInput
   {
       
      
      private var _position:uint = 0;
      
      private var _resource:ZipFileResource;
      
      private var _fileInfo:ZipFileResourceFileInfo;
      
      private var _tempBytes:ByteArray;
      
      public function ZipFileStream(param1:ZipFileResource, param2:String)
      {
         this._tempBytes = new ByteArray();
         super();
         this._resource = param1;
         this._fileInfo = param1.getFileInfo(param2);
         if(this._fileInfo == null)
         {
            throw new Error(param1.lastError);
         }
         this._tempBytes.endian = Endian.LITTLE_ENDIAN;
      }
      
      public function readBytes(param1:ByteArray, param2:uint = 0, param3:uint = 0) : void
      {
         this._resource.readFileBytes(param1,this._fileInfo,param2 + this._position,param3);
         this._position += param3;
      }
      
      public function readBoolean() : Boolean
      {
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,1);
         this._position += 1;
         this._tempBytes.position = 0;
         return this._tempBytes.readBoolean();
      }
      
      public function readByte() : int
      {
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,1);
         this._position += 1;
         this._tempBytes.position = 0;
         return this._tempBytes.readByte();
      }
      
      public function readUnsignedByte() : uint
      {
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,1);
         this._position += 1;
         this._tempBytes.position = 0;
         return this._tempBytes.readUnsignedByte();
      }
      
      public function readShort() : int
      {
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,2);
         this._position += 2;
         this._tempBytes.position = 0;
         return this._tempBytes.readShort();
      }
      
      public function readUnsignedShort() : uint
      {
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,2);
         this._position += 2;
         this._tempBytes.position = 0;
         return this._tempBytes.readUnsignedShort();
      }
      
      public function readInt() : int
      {
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,4);
         this._position += 4;
         this._tempBytes.position = 0;
         return this._tempBytes.readInt();
      }
      
      public function readUnsignedInt() : uint
      {
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,4);
         this._position += 4;
         this._tempBytes.position = 0;
         return this._tempBytes.readUnsignedInt();
      }
      
      public function readFloat() : Number
      {
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,4);
         this._position += 4;
         this._tempBytes.position = 0;
         return this._tempBytes.readFloat();
      }
      
      public function readDouble() : Number
      {
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,8);
         this._position += 8;
         this._tempBytes.position = 0;
         return this._tempBytes.readDouble();
      }
      
      public function readMultiByte(param1:uint, param2:String) : String
      {
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,param1);
         this._position += param1;
         this._tempBytes.position = 0;
         return this._tempBytes.readMultiByte(param1,param2);
      }
      
      public function readUTF() : String
      {
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,2);
         this._position += 2;
         var _loc1_:uint = this._tempBytes.readUnsignedShort();
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,_loc1_);
         this._position += _loc1_;
         this._tempBytes.position = 0;
         return this._tempBytes.readUTFBytes(_loc1_);
      }
      
      public function readUTFBytes(param1:uint) : String
      {
         this._tempBytes.position = 0;
         this._resource.readFileBytes(this._tempBytes,this._fileInfo,this._position,param1);
         this._position += param1;
         this._tempBytes.position = 0;
         return this._tempBytes.readUTFBytes(param1);
      }
      
      public function get bytesAvailable() : uint
      {
         return this._fileInfo.uncompressedSize - this._position;
      }
      
      public function readObject() : *
      {
         return null;
      }
      
      public function get objectEncoding() : uint
      {
         return 0;
      }
      
      public function set objectEncoding(param1:uint) : void
      {
      }
      
      public function get endian() : String
      {
         return Endian.LITTLE_ENDIAN;
      }
      
      public function set endian(param1:String) : void
      {
      }
   }
}
