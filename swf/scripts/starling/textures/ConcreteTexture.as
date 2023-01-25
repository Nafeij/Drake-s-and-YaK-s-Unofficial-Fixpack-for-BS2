package starling.textures
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display3D.Context3D;
   import flash.display3D.textures.Texture;
   import flash.display3D.textures.TextureBase;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.Camera;
   import flash.net.NetStream;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   import starling.core.RenderSupport;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.errors.MissingContextError;
   import starling.errors.NotSupportedError;
   import starling.events.Event;
   import starling.utils.Color;
   import starling.utils.execute;
   
   public class ConcreteTexture extends starling.textures.Texture
   {
      
      private static const TEXTURE_READY:String = "textureReady";
      
      private static var sOrigin:Point = new Point();
       
      
      private var mBase:TextureBase;
      
      private var mFormat:String;
      
      private var mWidth:int;
      
      private var mHeight:int;
      
      private var mMipMapping:Boolean;
      
      private var mPremultipliedAlpha:Boolean;
      
      private var mOptimizedForRenderTexture:Boolean;
      
      private var mScale:Number;
      
      private var mRepeat:Boolean;
      
      private var mOnRestore:Function;
      
      private var mDataUploaded:Boolean;
      
      private var mTextureReadyCallback:Function;
      
      public function ConcreteTexture(param1:Object, param2:TextureBase, param3:String, param4:int, param5:int, param6:Boolean, param7:Boolean, param8:Boolean = false, param9:Number = 1, param10:Boolean = false)
      {
         super(param1);
         this.mScale = param9 <= 0 ? 1 : param9;
         this.mBase = param2;
         this.mFormat = param3;
         this.mWidth = param4;
         this.mHeight = param5;
         this.mMipMapping = param6;
         this.mPremultipliedAlpha = param7;
         this.mOptimizedForRenderTexture = param8;
         this.mRepeat = param10;
         this.mOnRestore = null;
         this.mDataUploaded = false;
         this.mTextureReadyCallback = null;
      }
      
      override public function dispose() : void
      {
         if(this.mBase)
         {
            this.mBase.removeEventListener(TEXTURE_READY,this.onTextureReady);
            this.mBase.dispose();
         }
         this.onRestore = null;
         super.dispose();
      }
      
      public function uploadBitmap(param1:Bitmap) : void
      {
         this.uploadBitmapData(param1.bitmapData);
      }
      
      public function uploadBitmapData(param1:BitmapData) : void
      {
         var _loc2_:BitmapData = null;
         var _loc3_:flash.display3D.textures.Texture = null;
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc6_:int = 0;
         var _loc7_:BitmapData = null;
         var _loc8_:Matrix = null;
         var _loc9_:Rectangle = null;
         if(param1.width != this.mWidth || param1.height != this.mHeight)
         {
            _loc2_ = new BitmapData(this.mWidth,this.mHeight,true,0);
            _loc2_.copyPixels(param1,param1.rect,sOrigin);
            param1 = _loc2_;
         }
         if(this.mBase is flash.display3D.textures.Texture)
         {
            _loc3_ = this.mBase as flash.display3D.textures.Texture;
            _loc3_.uploadFromBitmapData(param1);
            if(this.mMipMapping && param1.width > 1 && param1.height > 1)
            {
               _loc4_ = param1.width >> 1;
               _loc5_ = param1.height >> 1;
               _loc6_ = 1;
               _loc7_ = new BitmapData(_loc4_,_loc5_,true,0);
               _loc8_ = new Matrix(0.5,0,0,0.5);
               _loc9_ = new Rectangle();
               while(_loc4_ >= 1 || _loc5_ >= 1)
               {
                  _loc9_.width = _loc4_;
                  _loc9_.height = _loc5_;
                  _loc7_.fillRect(_loc9_,0);
                  _loc7_.draw(param1,_loc8_,null,null,null,true);
                  _loc3_.uploadFromBitmapData(_loc7_,_loc6_++);
                  _loc8_.scale(0.5,0.5);
                  _loc4_ >>= 1;
                  _loc5_ >>= 1;
               }
               _loc7_.dispose();
            }
         }
         else
         {
            this.mBase["uploadFromBitmapData"](param1);
         }
         if(_loc2_)
         {
            _loc2_.dispose();
         }
         this.mDataUploaded = true;
      }
      
      public function uploadAtfData(param1:ByteArray, param2:int = 0, param3:* = null) : void
      {
         var _loc4_:Boolean = param3 is Function || param3 === true;
         var _loc5_:flash.display3D.textures.Texture = this.mBase as flash.display3D.textures.Texture;
         if(_loc5_ == null)
         {
            throw new Error("This texture type does not support ATF data");
         }
         if(param3 is Function)
         {
            this.mTextureReadyCallback = param3 as Function;
            this.mBase.addEventListener(TEXTURE_READY,this.onTextureReady);
         }
         _loc5_.uploadCompressedTextureFromByteArray(param1,param2,_loc4_);
         this.mDataUploaded = true;
      }
      
      public function attachNetStream(param1:NetStream, param2:Function = null) : void
      {
         this.attachVideo("NetStream",param1,param2);
      }
      
      public function attachCamera(param1:Camera, param2:Function = null) : void
      {
         this.attachVideo("Camera",param1,param2);
      }
      
      internal function attachVideo(param1:String, param2:Object, param3:Function = null) : void
      {
         var _loc4_:String = getQualifiedClassName(this.mBase);
         if(_loc4_ == "flash.display3D.textures::VideoTexture")
         {
            this.mDataUploaded = true;
            this.mTextureReadyCallback = param3;
            this.mBase["attach" + param1](param2);
            this.mBase.addEventListener(TEXTURE_READY,this.onTextureReady);
            return;
         }
         throw new Error("This texture type does not support " + param1 + " data");
      }
      
      private function onTextureReady(param1:Object) : void
      {
         this.mBase.removeEventListener(TEXTURE_READY,this.onTextureReady);
         execute(this.mTextureReadyCallback,this);
         this.mTextureReadyCallback = null;
      }
      
      private function onContextCreated() : void
      {
         this.starling_internal::createBase();
         if(this.mOnRestore != null)
         {
            this.mOnRestore();
         }
         if(!this.mDataUploaded)
         {
            this.clear();
         }
      }
      
      starling_internal function createBase() : void
      {
         var _loc1_:Context3D = Starling.context;
         var _loc2_:String = getQualifiedClassName(this.mBase);
         if(_loc2_ == "flash.display3D.textures::Texture")
         {
            this.mBase = _loc1_.createTexture(this.mWidth,this.mHeight,this.mFormat,this.mOptimizedForRenderTexture);
         }
         else if(_loc2_ == "flash.display3D.textures::RectangleTexture")
         {
            this.mBase = _loc1_["createRectangleTexture"](this.mWidth,this.mHeight,this.mFormat,this.mOptimizedForRenderTexture);
         }
         else
         {
            if(_loc2_ != "flash.display3D.textures::VideoTexture")
            {
               throw new NotSupportedError("Texture type not supported: " + _loc2_);
            }
            this.mBase = _loc1_["createVideoTexture"]();
         }
         this.mDataUploaded = false;
      }
      
      public function clear(param1:uint = 0, param2:Number = 0) : void
      {
         var _loc3_:Context3D = Starling.context;
         if(_loc3_ == null)
         {
            throw new MissingContextError();
         }
         if(this.mPremultipliedAlpha && param2 < 1)
         {
            param1 = Color.rgb(Color.getRed(param1) * param2,Color.getGreen(param1) * param2,Color.getBlue(param1) * param2);
         }
         _loc3_.setRenderToTexture(this.mBase);
         try
         {
            RenderSupport.clear(param1,param2);
         }
         catch(e:Error)
         {
         }
         _loc3_.setRenderToBackBuffer();
         this.mDataUploaded = true;
      }
      
      public function get optimizedForRenderTexture() : Boolean
      {
         return this.mOptimizedForRenderTexture;
      }
      
      public function get onRestore() : Function
      {
         return this.mOnRestore;
      }
      
      public function set onRestore(param1:Function) : void
      {
         Starling.current.removeEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated);
         if(Starling.handleLostContext && param1 != null)
         {
            this.mOnRestore = param1;
            Starling.current.addEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated);
         }
         else
         {
            this.mOnRestore = null;
         }
      }
      
      override public function get base() : TextureBase
      {
         return this.mBase;
      }
      
      override public function get root() : ConcreteTexture
      {
         return this;
      }
      
      override public function get format() : String
      {
         return this.mFormat;
      }
      
      override public function get width() : Number
      {
         return this.mWidth / this.mScale;
      }
      
      override public function get height() : Number
      {
         return this.mHeight / this.mScale;
      }
      
      override public function get nativeWidth() : Number
      {
         return this.mWidth;
      }
      
      override public function get nativeHeight() : Number
      {
         return this.mHeight;
      }
      
      override public function get scale() : Number
      {
         return this.mScale;
      }
      
      override public function get mipMapping() : Boolean
      {
         return this.mMipMapping;
      }
      
      override public function get premultipliedAlpha() : Boolean
      {
         return this.mPremultipliedAlpha;
      }
      
      override public function get repeat() : Boolean
      {
         return this.mRepeat;
      }
   }
}
