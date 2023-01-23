package starling.textures
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DTextureFormat;
   import flash.display3D.textures.Texture;
   import flash.display3D.textures.TextureBase;
   import flash.errors.IllegalOperationError;
   import flash.geom.Rectangle;
   import flash.media.Camera;
   import flash.net.NetStream;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   import starling.core.Starling;
   import starling.errors.AbstractClassError;
   import starling.errors.MissingContextError;
   import starling.errors.NotSupportedError;
   import starling.utils.Color;
   import starling.utils.SystemUtil;
   import starling.utils.VertexData;
   import starling.utils.execute;
   import starling.utils.getNextPowerOfTwo;
   
   public class Texture
   {
      
      public static var outstandings:Vector.<starling.textures.Texture> = new Vector.<starling.textures.Texture>();
      
      public static var textureCount:int;
      
      public static var last_id:uint = 0;
       
      
      public var disposed:Boolean;
      
      public var owner:Object;
      
      public var id:uint = 0;
      
      public function Texture(param1:Object)
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.textures::Texture")
         {
            throw new AbstractClassError();
         }
         this.id = ++last_id;
         ++textureCount;
         if(outstandings)
         {
            outstandings.push(this);
         }
         this.owner = param1;
      }
      
      public static function debugDump() : String
      {
         var _loc2_:int = 0;
         var _loc3_:starling.textures.Texture = null;
         var _loc1_:* = "===== Texture.debugDump textureCount=" + textureCount + " outstandings=" + (!!outstandings ? outstandings.length : -1) + "\n";
         if(outstandings)
         {
            _loc2_ = 0;
            while(_loc2_ < outstandings.length)
            {
               _loc3_ = outstandings[_loc2_];
               _loc1_ += _loc2_ + "\t" + _loc3_.id + "\t" + _loc3_.width + "\t" + _loc3_.height + "\t" + _loc3_.width * _loc3_.height + "\t" + _loc3_.owner + "\n";
               _loc2_++;
            }
         }
         return _loc1_;
      }
      
      public static function fromData(param1:Object, param2:Object, param3:TextureOptions = null) : starling.textures.Texture
      {
         var _loc4_:starling.textures.Texture = null;
         if(param2 is Bitmap)
         {
            param2 = (param2 as Bitmap).bitmapData;
         }
         if(param3 == null)
         {
            param3 = new TextureOptions();
         }
         if(param2 is Class)
         {
            _loc4_ = fromEmbeddedAsset(param1,param2 as Class,param3.mipMapping,param3.optimizeForRenderToTexture,param3.scale,param3.format,param3.repeat);
         }
         else if(param2 is BitmapData)
         {
            _loc4_ = fromBitmapData(param1,param2 as BitmapData,param3.mipMapping,param3.optimizeForRenderToTexture,param3.scale,param3.format,param3.repeat);
         }
         else
         {
            if(!(param2 is ByteArray))
            {
               throw new ArgumentError("Unsupported \'data\' type: " + getQualifiedClassName(param2));
            }
            _loc4_ = fromAtfData(param1,param2 as ByteArray,param3.scale,param3.mipMapping,param3.onReady,param3.repeat);
         }
         return _loc4_;
      }
      
      public static function fromEmbeddedAsset(param1:Object, param2:Class, param3:Boolean = true, param4:Boolean = false, param5:Number = 1, param6:String = "bgra", param7:Boolean = false) : starling.textures.Texture
      {
         var texture:starling.textures.Texture = null;
         var owner:Object = param1;
         var assetClass:Class = param2;
         var mipMapping:Boolean = param3;
         var optimizeForRenderToTexture:Boolean = param4;
         var scale:Number = param5;
         var format:String = param6;
         var repeat:Boolean = param7;
         var asset:Object = new assetClass();
         if(asset is Bitmap)
         {
            texture = starling.textures.Texture.fromBitmap(owner,asset as Bitmap,mipMapping,optimizeForRenderToTexture,scale,format,repeat);
            texture.root.onRestore = function():void
            {
               texture.root.uploadBitmap(new assetClass());
            };
         }
         else
         {
            if(!(asset is ByteArray))
            {
               throw new ArgumentError("Invalid asset type: " + getQualifiedClassName(asset));
            }
            texture = starling.textures.Texture.fromAtfData(owner,asset as ByteArray,scale,mipMapping,null,repeat);
            texture.root.onRestore = function():void
            {
               texture.root.uploadAtfData(new assetClass());
            };
         }
         asset = null;
         return texture;
      }
      
      public static function fromBitmap(param1:Object, param2:Bitmap, param3:Boolean = true, param4:Boolean = false, param5:Number = 1, param6:String = "bgra", param7:Boolean = false) : starling.textures.Texture
      {
         return fromBitmapData(param1,param2.bitmapData,param3,param4,param5,param6,param7);
      }
      
      public static function fromBitmapData(param1:Object, param2:BitmapData, param3:Boolean = true, param4:Boolean = false, param5:Number = 1, param6:String = "bgra", param7:Boolean = false) : starling.textures.Texture
      {
         var texture:starling.textures.Texture = null;
         var owner:Object = param1;
         var data:BitmapData = param2;
         var generateMipMaps:Boolean = param3;
         var optimizeForRenderToTexture:Boolean = param4;
         var scale:Number = param5;
         var format:String = param6;
         var repeat:Boolean = param7;
         texture = starling.textures.Texture.empty(owner,data.width / scale,data.height / scale,true,generateMipMaps,optimizeForRenderToTexture,scale,format,repeat);
         texture.root.uploadBitmapData(data);
         texture.root.onRestore = function():void
         {
            texture.root.uploadBitmapData(data);
         };
         return texture;
      }
      
      public static function fromAtfData(param1:Object, param2:ByteArray, param3:Number = 1, param4:Boolean = true, param5:Function = null, param6:Boolean = false) : starling.textures.Texture
      {
         var atfData:AtfData;
         var nativeTexture:flash.display3D.textures.Texture;
         var concreteTexture:ConcreteTexture = null;
         var owner:Object = param1;
         var data:ByteArray = param2;
         var scale:Number = param3;
         var useMipMaps:Boolean = param4;
         var async:Function = param5;
         var repeat:Boolean = param6;
         var context:Context3D = Starling.context;
         if(context == null)
         {
            throw new MissingContextError();
         }
         atfData = new AtfData(data);
         nativeTexture = context.createTexture(atfData.width,atfData.height,atfData.format,false);
         concreteTexture = new ConcreteTexture(owner,nativeTexture,atfData.format,atfData.width,atfData.height,useMipMaps && atfData.numTextures > 1,false,false,scale,repeat);
         concreteTexture.uploadAtfData(data,0,async);
         concreteTexture.onRestore = function():void
         {
            concreteTexture.uploadAtfData(data,0);
         };
         return concreteTexture;
      }
      
      public static function fromNetStream(param1:Object, param2:NetStream, param3:Number = 1, param4:Function = null) : starling.textures.Texture
      {
         var owner:Object = param1;
         var stream:NetStream = param2;
         var scale:Number = param3;
         var onComplete:Function = param4;
         if(stream.client == stream && !("onMetaData" in stream))
         {
            stream.client = {"onMetaData":function(param1:Object):void
            {
            }};
         }
         return fromVideoAttachment(owner,"NetStream",stream,scale,onComplete);
      }
      
      public static function fromCamera(param1:Object, param2:Camera, param3:Number = 1, param4:Function = null) : starling.textures.Texture
      {
         return fromVideoAttachment(param1,"Camera",param2,param3,param4);
      }
      
      private static function fromVideoAttachment(param1:Object, param2:String, param3:Object, param4:Number, param5:Function) : starling.textures.Texture
      {
         var context:Context3D;
         var TEXTURE_READY:String = null;
         var base:TextureBase = null;
         var texture:ConcreteVideoTexture = null;
         var owner:Object = param1;
         var type:String = param2;
         var attachment:Object = param3;
         var scale:Number = param4;
         var onComplete:Function = param5;
         TEXTURE_READY = "textureReady";
         if(!SystemUtil.supportsVideoTexture)
         {
            throw new NotSupportedError("Video Textures are not supported on this platform");
         }
         context = Starling.context;
         if(context == null)
         {
            throw new MissingContextError();
         }
         base = context["createVideoTexture"]();
         base["attach" + type](attachment);
         base.addEventListener(TEXTURE_READY,function(param1:Object):void
         {
            base.removeEventListener(TEXTURE_READY,arguments.callee);
            execute(onComplete,texture);
         });
         texture = new ConcreteVideoTexture(owner,base,scale);
         texture.onRestore = function():void
         {
            texture.root.attachVideo(type,attachment);
         };
         return texture;
      }
      
      public static function fromColor(param1:Object, param2:Number, param3:Number, param4:uint = 4294967295, param5:Boolean = false, param6:Number = -1, param7:String = "bgra") : starling.textures.Texture
      {
         var texture:starling.textures.Texture = null;
         var owner:Object = param1;
         var width:Number = param2;
         var height:Number = param3;
         var color:uint = param4;
         var optimizeForRenderToTexture:Boolean = param5;
         var scale:Number = param6;
         var format:String = param7;
         texture = starling.textures.Texture.empty(owner,width,height,true,false,optimizeForRenderToTexture,scale,format);
         texture.root.clear(color,Color.getAlpha(color) / 255);
         texture.root.onRestore = function():void
         {
            texture.root.clear(color,Color.getAlpha(color) / 255);
         };
         return texture;
      }
      
      public static function empty(param1:Object, param2:Number, param3:Number, param4:Boolean = true, param5:Boolean = true, param6:Boolean = false, param7:Number = -1, param8:String = "bgra", param9:Boolean = false) : starling.textures.Texture
      {
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:TextureBase = null;
         if(param7 <= 0)
         {
            param7 = Starling.contentScaleFactor;
         }
         var _loc13_:Context3D = Starling.context;
         if(_loc13_ == null)
         {
            throw new MissingContextError();
         }
         var _loc14_:Number = param2 * param7;
         var _loc15_:Number = param3 * param7;
         var _loc16_:Boolean = !param5 && !param9 && Starling.current.profile != "baselineConstrained" && "createRectangleTexture" in _loc13_ && param8.indexOf("compressed") == -1;
         if(_loc16_)
         {
            _loc10_ = Math.ceil(_loc14_ - 1e-9);
            _loc11_ = Math.ceil(_loc15_ - 1e-9);
            _loc12_ = _loc13_["createRectangleTexture"](_loc10_,_loc11_,param8,param6);
         }
         else
         {
            _loc10_ = getNextPowerOfTwo(_loc14_);
            _loc11_ = getNextPowerOfTwo(_loc15_);
            _loc12_ = _loc13_.createTexture(_loc10_,_loc11_,param8,param6);
         }
         var _loc17_:ConcreteTexture = new ConcreteTexture(param1,_loc12_,param8,_loc10_,_loc11_,param5,param4,param6,param7,param9);
         _loc17_.onRestore = _loc17_.clear;
         if(_loc10_ - _loc14_ < 0.001 && _loc11_ - _loc15_ < 0.001)
         {
            return _loc17_;
         }
         return new SubTexture(param1,_loc17_,new Rectangle(0,0,param2,param3),true);
      }
      
      public static function fromTexture(param1:Object, param2:starling.textures.Texture, param3:Rectangle = null, param4:Rectangle = null, param5:Boolean = false) : starling.textures.Texture
      {
         return new SubTexture(param1,param2,param3,false,param4,param5);
      }
      
      public static function get maxSize() : int
      {
         var _loc1_:Starling = Starling.current;
         var _loc2_:String = !!_loc1_ ? _loc1_.profile : "baseline";
         if(_loc2_ == "baseline" || _loc2_ == "baselineConstrained")
         {
            return 2048;
         }
         return 4096;
      }
      
      public function dispose() : void
      {
         var _loc1_:int = 0;
         if(this.disposed)
         {
            throw new IllegalOperationError("Double dispose of texture " + this);
         }
         --textureCount;
         if(outstandings)
         {
            _loc1_ = outstandings.indexOf(this);
            if(_loc1_ < 0)
            {
               throw new IllegalOperationError("No mention of outstanding texture " + this);
            }
            outstandings.splice(_loc1_,1);
         }
      }
      
      public function toString() : String
      {
         return "id=" + this.id + " owner=" + this.owner;
      }
      
      public function adjustVertexData(param1:VertexData, param2:int, param3:int) : void
      {
      }
      
      public function adjustTexCoords(param1:Vector.<Number>, param2:int = 0, param3:int = 0, param4:int = -1) : void
      {
      }
      
      public function get frame() : Rectangle
      {
         return null;
      }
      
      public function get repeat() : Boolean
      {
         return false;
      }
      
      public function get width() : Number
      {
         return 0;
      }
      
      public function get height() : Number
      {
         return 0;
      }
      
      public function get nativeWidth() : Number
      {
         return 0;
      }
      
      public function get nativeHeight() : Number
      {
         return 0;
      }
      
      public function get scale() : Number
      {
         return 1;
      }
      
      public function get base() : TextureBase
      {
         return null;
      }
      
      public function get root() : ConcreteTexture
      {
         return null;
      }
      
      public function get format() : String
      {
         return Context3DTextureFormat.BGRA;
      }
      
      public function get mipMapping() : Boolean
      {
         return false;
      }
      
      public function get premultipliedAlpha() : Boolean
      {
         return false;
      }
   }
}
