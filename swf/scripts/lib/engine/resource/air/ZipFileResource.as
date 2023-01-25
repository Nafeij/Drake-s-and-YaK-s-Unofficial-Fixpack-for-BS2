package lib.engine.resource.air
{
   import engine.core.logging.ILogger;
   import flash.errors.IOError;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.ByteArray;
   import flash.utils.CompressionAlgorithm;
   import flash.utils.Dictionary;
   import flash.utils.Endian;
   import flash.utils.Timer;
   
   public final class ZipFileResource
   {
      
      public static const LOCAL_FILE_SIGNATURE:uint = 67324752;
      
      public static const EOCD_SIGNATURE:uint = 101010256;
      
      public static const DIRFILE_SIGNATURE:uint = 33639248;
      
      public static const COMPRESS_NONE:uint = 0;
      
      public static const COMPRESS_SHRUNK:uint = 1;
      
      public static const COMPRESS_REDUCE_1:uint = 2;
      
      public static const COMPRESS_REDUCE_2:uint = 3;
      
      public static const COMPRESS_REDUCE_3:uint = 4;
      
      public static const COMPRESS_REDUCE_4:uint = 5;
      
      public static const COMPRESS_IMPLODE:uint = 6;
      
      public static const COMPRESS_TOKENIZE:uint = 7;
      
      public static const COMPRESS_DEFLATE:uint = 8;
      
      public static const COMPRESS_DEFLATE64:uint = 9;
      
      public static const COMPRESS_LIBIMPLODE:uint = 10;
      
      public static const COMPRESS_BZIP2:uint = 12;
      
      public static const COMPRESS_LZMA:uint = 14;
      
      public static const COMPRESS_TERSE:uint = 18;
      
      public static const COMPRESS_LZ77:uint = 19;
      
      public static const COMPRESS_WAVEPACK:uint = 97;
      
      public static const COMPRESS_PPMD:uint = 98;
       
      
      private var zipStream:FileStream;
      
      private var zipFile:File;
      
      private var compressionMethod:int = 0;
      
      private var compressedSize:uint = 0;
      
      private var uncompressedSize:uint = 0;
      
      private var fileDirectory:Dictionary;
      
      private var logger:ILogger;
      
      public var lastError:String = null;
      
      public var keepOpen:Boolean = false;
      
      private var _prefix:String = "";
      
      private var _cachedUrl:String = null;
      
      private var lastOpenTime:uint;
      
      private var closeTimer:Timer;
      
      private var errorOnOpen:Boolean = false;
      
      public function ZipFileResource(param1:File, param2:String, param3:ILogger)
      {
         super();
         this.zipFile = param1;
         this._prefix = param2;
         this.logger = param3;
         this._cachedUrl = param1.url;
      }
      
      public function get prefix() : String
      {
         return this._prefix;
      }
      
      public function get url() : String
      {
         return this._cachedUrl;
      }
      
      public function loadCentralDirectoryRecordAt(param1:uint) : uint
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.endian = Endian.LITTLE_ENDIAN;
         this.zipStream.position = param1;
         this.zipStream.readBytes(_loc2_,0,46);
         var _loc3_:uint = _loc2_.readUnsignedInt();
         if(_loc3_ != DIRFILE_SIGNATURE)
         {
            this.lastError = "invalid zip directory signature";
            return 0;
         }
         _loc2_.position = 10;
         var _loc4_:uint = _loc2_.readUnsignedShort();
         _loc2_.position = 20;
         var _loc5_:uint = _loc2_.readUnsignedInt();
         var _loc6_:uint = _loc2_.readUnsignedInt();
         var _loc7_:uint = _loc2_.readUnsignedShort();
         var _loc8_:uint = _loc2_.readUnsignedShort();
         var _loc9_:uint = _loc2_.readUnsignedShort();
         var _loc10_:uint = _loc2_.readUnsignedShort();
         _loc2_.position = 42;
         var _loc11_:uint = _loc2_.readUnsignedInt();
         this.zipStream.readBytes(_loc2_,0,_loc7_);
         _loc2_.position = 0;
         var _loc12_:String = _loc2_.readUTFBytes(_loc7_);
         if(_loc12_.length > 0 && _loc12_.charAt(_loc12_.length - 1) != "/")
         {
            this.fileDirectory[_loc12_] = _loc11_;
         }
         return 46 + _loc7_ + _loc8_ + _loc9_;
      }
      
      private function findEndOfCentralDirectory() : Number
      {
         var _loc3_:uint = 0;
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.endian = Endian.LITTLE_ENDIAN;
         var _loc2_:Number = this.zipFile.size - 22;
         while(_loc2_ >= 0)
         {
            this.zipStream.position = _loc2_;
            this.zipStream.readBytes(_loc1_,0,4);
            _loc1_.position = 0;
            _loc3_ = _loc1_.readUnsignedInt();
            if(_loc3_ == EOCD_SIGNATURE)
            {
               break;
            }
            _loc2_--;
         }
         return _loc2_;
      }
      
      public function loadCentralDirectory(param1:Boolean = true) : Boolean
      {
         var _loc13_:uint = 0;
         if(this.zipFile.size < 22)
         {
            this.lastError = "invalid zip directory size";
            return false;
         }
         var _loc2_:Boolean = false;
         if(this.zipStream == null)
         {
            _loc2_ = this.open();
         }
         if(this.zipStream == null)
         {
            this.lastError = "Unable to open zip file " + this.zipFile.url;
            return false;
         }
         this.logger.info("Reading central directory from " + this.zipFile.url);
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.endian = Endian.LITTLE_ENDIAN;
         var _loc4_:Number = this.findEndOfCentralDirectory();
         if(_loc4_ < 0)
         {
            this.lastError = "could not locate end of central directory in " + this.zipFile.url;
            return false;
         }
         this.zipStream.position = _loc4_ + 4;
         this.zipStream.readBytes(_loc3_,0,18);
         _loc3_.position = 0;
         var _loc5_:uint = _loc3_.readUnsignedShort();
         var _loc6_:uint = _loc3_.readUnsignedShort();
         var _loc7_:uint = _loc3_.readUnsignedShort();
         var _loc8_:uint = _loc3_.readUnsignedShort();
         var _loc9_:uint = _loc3_.readUnsignedInt();
         var _loc10_:uint = _loc3_.readUnsignedInt();
         var _loc11_:int = 0;
         this.logger.debug("Central Directory contains " + _loc8_ + " entries.");
         this.fileDirectory = new Dictionary();
         _loc4_ = _loc10_;
         var _loc12_:uint = 0;
         while(_loc12_ < _loc8_)
         {
            _loc13_ = this.loadCentralDirectoryRecordAt(_loc4_);
            if(_loc13_ <= 0)
            {
               this.logger.info("Error loading Central Directory record " + _loc12_ + " at " + _loc4_ + " from " + this.zipFile.url);
               this.lastError = "Error loading record " + _loc12_ + " at " + _loc4_;
               this.fileDirectory = null;
               if(_loc2_)
               {
                  this.close();
               }
               return false;
            }
            _loc11_++;
            _loc4_ += _loc13_;
            _loc12_++;
         }
         this.logger.info("Finished loading Central Directory from " + this.zipFile.url + " : indexed " + _loc11_ + " files.");
         if(param1 || _loc2_)
         {
            this.close();
         }
         return true;
      }
      
      public function readFileBytes(param1:ByteArray, param2:ZipFileResourceFileInfo, param3:uint, param4:uint) : void
      {
         var _loc5_:Boolean = false;
         if(this.zipStream == null)
         {
            _loc5_ = this.open();
            if(this.zipStream == null)
            {
               throw new Error("Failed to open stream.");
            }
         }
         if(param2.uncompressedSize < param3 + param4)
         {
            if(_loc5_)
            {
               this.close();
            }
            throw new Error("Invalid offset and length - would exceed the file size");
         }
         if(param2.compressionMethod != COMPRESS_NONE)
         {
            if(_loc5_)
            {
               this.close();
            }
            throw new Error("readFileBytes can only be used on uncompressed files.");
         }
         this.zipStream.position = param2.offset + param3;
         this.zipStream.readBytes(param1,param1.position,param4);
         if(_loc5_)
         {
            this.close();
         }
      }
      
      public function getFileInfo(param1:String, param2:Boolean = true) : ZipFileResourceFileInfo
      {
         var _loc11_:Boolean = false;
         if(this.open() == false)
         {
            this.logger.error("Failed to open zip file!");
            return null;
         }
         if(this.fileDirectory == null)
         {
            _loc11_ = this.loadCentralDirectory(false);
            if(!_loc11_)
            {
               this.logger.error("Failed to load the central directory.");
               this.close();
               return null;
            }
         }
         if(!this.fileDirectory.hasOwnProperty(param1))
         {
            this.logger.error("File " + param1 + " is not in the directory");
            this.lastError = "no such file";
            this.close();
            return null;
         }
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.endian = Endian.LITTLE_ENDIAN;
         var _loc4_:uint = uint(this.fileDirectory[param1]);
         this.zipStream.position = _loc4_;
         this.zipStream.readBytes(_loc3_,0,30);
         _loc3_.position = 0;
         var _loc5_:int = _loc3_.readInt();
         if(_loc5_ != LOCAL_FILE_SIGNATURE)
         {
            this.logger.error("Invalid file header signature for " + param1 + " at pos " + _loc4_ + " : " + _loc5_ + "!=" + LOCAL_FILE_SIGNATURE);
            this.lastError = "invalid file header";
            this.close();
            return null;
         }
         _loc3_.position = 8;
         this.compressionMethod = _loc3_.readByte();
         _loc3_.position = 18;
         this.compressedSize = _loc3_.readUnsignedInt();
         _loc3_.position = 22;
         this.uncompressedSize = _loc3_.readUnsignedInt();
         var _loc6_:int = 30;
         _loc3_.position = 26;
         var _loc7_:int = _loc3_.readShort();
         _loc6_ += _loc7_;
         _loc3_.position = 28;
         var _loc8_:int = _loc3_.readShort();
         _loc6_ += _loc8_;
         var _loc9_:uint = uint(_loc4_ + _loc6_);
         var _loc10_:ZipFileResourceFileInfo = new ZipFileResourceFileInfo(_loc9_,this.compressedSize,this.uncompressedSize,this.compressionMethod);
         if(param2)
         {
            this.close();
         }
         return _loc10_;
      }
      
      public function containsFile(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         if(this.fileDirectory == null)
         {
            _loc2_ = this.loadCentralDirectory(true);
            if(!_loc2_)
            {
               throw new Error("Failed to load central directory");
            }
         }
         if(!this.fileDirectory.hasOwnProperty(param1))
         {
            return false;
         }
         return true;
      }
      
      public function loadFile(param1:String) : ByteArray
      {
         if(this.open() == false)
         {
            this.logger.error("Failed to open " + this.zipFile.url);
            return null;
         }
         var _loc2_:ZipFileResourceFileInfo = this.getFileInfo(param1,false);
         if(_loc2_ == null)
         {
            this.logger.error("Failed to get file info for " + param1);
            this.close();
            return null;
         }
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.position = 0;
         this.zipStream.position = _loc2_.offset;
         this.zipStream.readBytes(_loc3_,0,_loc2_.compressedSize);
         if(_loc2_.compressionMethod == COMPRESS_DEFLATE)
         {
            _loc3_.inflate();
         }
         else if(_loc2_.compressionMethod == COMPRESS_LZMA)
         {
            _loc3_.uncompress(CompressionAlgorithm.LZMA);
         }
         else if(_loc2_.compressionMethod == COMPRESS_LZ77)
         {
            _loc3_.uncompress(CompressionAlgorithm.ZLIB);
         }
         else if(_loc2_.compressionMethod != COMPRESS_NONE)
         {
            this.lastError = "unsupported compression method (" + this.compressionMethod + ")";
            this.close();
            return null;
         }
         _loc3_.position = 0;
         this.close();
         return _loc3_;
      }
      
      public function open(param1:Boolean = false) : Boolean
      {
         var keepOpen:Boolean = param1;
         if(this.zipStream == null)
         {
            if(keepOpen)
            {
               this.logger.info("Opening zip resource at " + this.zipFile.url);
            }
            this.errorOnOpen = false;
            this.zipStream = new FileStream();
            if(this.closeTimer)
            {
               this.closeTimer.stop();
               this.closeTimer = null;
            }
            try
            {
               this.zipStream.open(this.zipFile,FileMode.READ);
            }
            catch(err:IOError)
            {
               logger.error("Failed to open " + zipFile.url + " of size " + zipFile.size + ": " + err.message);
               lastError = err.message;
               errorOnOpen = true;
            }
            if(this.errorOnOpen)
            {
               this.zipStream.close();
               this.zipStream = null;
               return false;
            }
            this.logger.info(this.zipFile.url + " opened. Size=" + this.zipFile.size);
         }
         this.keepOpen = this.keepOpen || keepOpen;
         return true;
      }
      
      private function onZipOpenError(param1:IOErrorEvent) : void
      {
         this.logger.error("Error opening zip resource at " + this.zipFile.url + ": " + param1.text);
         this.lastError = param1.text;
      }
      
      public function close(param1:Boolean = false) : void
      {
         var force:Boolean = param1;
         if(this.zipStream != null && (force || !this.keepOpen))
         {
            if(this.closeTimer != null)
            {
               this.closeTimer = new Timer(15000,1);
               this.closeTimer.addEventListener(TimerEvent.TIMER_COMPLETE,function(param1:TimerEvent):void
               {
                  if(zipStream != null)
                  {
                     logger.info("Closing zip resource at " + zipFile.url);
                     zipStream.close();
                     zipStream = null;
                  }
               });
            }
         }
         if(force)
         {
            this.keepOpen = false;
         }
      }
   }
}
