package starling.textures
{
   import flash.display3D.Context3D;
   import flash.display3D.VertexBuffer3D;
   import flash.display3D.textures.TextureBase;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import starling.core.RenderSupport;
   import starling.core.Starling;
   import starling.display.BlendMode;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.errors.MissingContextError;
   import starling.filters.FragmentFilter;
   import starling.utils.SystemUtil;
   import starling.utils.execute;
   import starling.utils.getNextPowerOfTwo;
   
   public class RenderTexture extends SubTexture
   {
      
      private static var sClipRect:Rectangle = new Rectangle();
      
      public static var optimizePersistentBuffers:Boolean = false;
       
      
      private const CONTEXT_POT_SUPPORT_KEY:String = "RenderTexture.supportsNonPotDimensions";
      
      private const PMA:Boolean = true;
      
      private var mActiveTexture:Texture;
      
      private var mBufferTexture:Texture;
      
      private var mHelperImage:Image;
      
      private var mDrawing:Boolean;
      
      private var mBufferReady:Boolean;
      
      private var mIsPersistent:Boolean;
      
      private var mSupport:RenderSupport;
      
      public function RenderTexture(param1:Object, param2:int, param3:int, param4:Boolean = true, param5:Number = -1, param6:String = "bgra", param7:Boolean = false)
      {
         if(param5 <= 0)
         {
            param5 = Starling.contentScaleFactor;
         }
         var _loc8_:Number = param2;
         var _loc9_:Number = param3;
         if(!this.supportsNonPotDimensions)
         {
            _loc8_ = getNextPowerOfTwo(param2 * param5) / param5;
            _loc9_ = getNextPowerOfTwo(param3 * param5) / param5;
         }
         this.mActiveTexture = Texture.empty(param1,_loc8_,_loc9_,this.PMA,false,true,param5,param6,param7);
         this.mActiveTexture.root.onRestore = this.mActiveTexture.root.clear;
         super(param1,this.mActiveTexture,new Rectangle(0,0,param2,param3),true,null,false);
         var _loc10_:Number = this.mActiveTexture.root.width;
         var _loc11_:Number = this.mActiveTexture.root.height;
         this.mIsPersistent = param4;
         this.mSupport = new RenderSupport();
         this.mSupport.setProjectionMatrix(0,0,_loc10_,_loc11_,param2,param3);
         if(param4 && (!optimizePersistentBuffers || !SystemUtil.supportsRelaxedTargetClearRequirement))
         {
            this.mBufferTexture = Texture.empty(param1,_loc8_,_loc9_,this.PMA,false,true,param5,param6,param7);
            this.mBufferTexture.root.onRestore = this.mBufferTexture.root.clear;
            this.mHelperImage = new Image(this.mBufferTexture);
            this.mHelperImage.smoothing = TextureSmoothing.NONE;
         }
      }
      
      override public function dispose() : void
      {
         this.mSupport.dispose();
         this.mActiveTexture.dispose();
         if(this.isDoubleBuffered)
         {
            this.mBufferTexture.dispose();
            this.mHelperImage.dispose();
         }
         super.dispose();
      }
      
      public function draw(param1:DisplayObject, param2:Matrix = null, param3:Number = 1, param4:int = 0) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(this.mDrawing)
         {
            this.render(param1,param2,param3);
         }
         else
         {
            this.renderBundled(this.render,param1,param2,param3,param4);
         }
      }
      
      public function drawBundled(param1:Function, param2:int = 0) : void
      {
         this.renderBundled(param1,null,null,1,param2);
      }
      
      private function render(param1:DisplayObject, param2:Matrix = null, param3:Number = 1) : void
      {
         var _loc4_:FragmentFilter = param1.filter;
         var _loc5_:DisplayObject = param1.mask;
         this.mSupport.loadIdentity();
         this.mSupport.blendMode = param1.blendMode == BlendMode.AUTO ? BlendMode.NORMAL : param1.blendMode;
         if(param2)
         {
            this.mSupport.prependMatrix(param2);
         }
         else
         {
            this.mSupport.transformMatrix(param1);
         }
         if(_loc5_)
         {
            this.mSupport.pushMask(_loc5_);
         }
         if(_loc4_)
         {
            _loc4_.render(param1,this.mSupport,param3);
         }
         else
         {
            param1.render(this.mSupport,param3);
         }
         if(_loc5_)
         {
            this.mSupport.popMask();
         }
      }
      
      private function renderBundled(param1:Function, param2:DisplayObject = null, param3:Matrix = null, param4:Number = 1, param5:int = 0) : void
      {
         var previousRenderTarget:Texture;
         var tmpTexture:Texture = null;
         var renderBlock:Function = param1;
         var object:DisplayObject = param2;
         var matrix:Matrix = param3;
         var alpha:Number = param4;
         var antiAliasing:int = param5;
         var context:Context3D = Starling.context;
         if(context == null)
         {
            throw new MissingContextError();
         }
         if(!Starling.current.contextValid)
         {
            return;
         }
         if(this.isDoubleBuffered)
         {
            tmpTexture = this.mActiveTexture;
            this.mActiveTexture = this.mBufferTexture;
            this.mBufferTexture = tmpTexture;
            this.mHelperImage.texture = this.mBufferTexture;
         }
         previousRenderTarget = this.mSupport.renderTarget;
         sClipRect.setTo(0,0,this.mActiveTexture.width,this.mActiveTexture.height);
         this.mSupport.pushClipRect(sClipRect);
         this.mSupport.setRenderTarget(this.mActiveTexture,antiAliasing);
         if(this.isDoubleBuffered || !this.isPersistent || !this.mBufferReady)
         {
            this.mSupport.clear();
         }
         if(this.isDoubleBuffered && this.mBufferReady)
         {
            this.mHelperImage.render(this.mSupport,1);
         }
         else
         {
            this.mBufferReady = true;
         }
         try
         {
            this.mDrawing = true;
            execute(renderBlock,object,matrix,alpha);
         }
         finally
         {
            this.mDrawing = false;
            this.mSupport.finishQuadBatch();
            this.mSupport.nextFrame();
            this.mSupport.renderTarget = previousRenderTarget;
            this.mSupport.popClipRect();
         }
      }
      
      public function clear(param1:uint = 0, param2:Number = 0) : void
      {
         if(!Starling.current.contextValid)
         {
            return;
         }
         var _loc3_:Texture = this.mSupport.renderTarget;
         this.mSupport.renderTarget = this.mActiveTexture;
         this.mSupport.clear(param1,param2);
         this.mSupport.renderTarget = _loc3_;
         this.mBufferReady = true;
      }
      
      private function get supportsNonPotDimensions() : Boolean
      {
         var texture:TextureBase = null;
         var buffer:VertexBuffer3D = null;
         var target:Starling = Starling.current;
         var context:Context3D = Starling.context;
         var support:Object = target.contextData[this.CONTEXT_POT_SUPPORT_KEY];
         if(support == null)
         {
            if(target.profile != "baselineConstrained" && "createRectangleTexture" in context)
            {
               try
               {
                  texture = context["createRectangleTexture"](2,3,"bgra",true);
                  context.setRenderToTexture(texture);
                  context.clear();
                  context.setRenderToBackBuffer();
                  context.createVertexBuffer(1,1);
                  support = true;
               }
               catch(e:Error)
               {
                  support = false;
               }
               finally
               {
                  if(texture)
                  {
                     texture.dispose();
                  }
                  if(buffer)
                  {
                     buffer.dispose();
                  }
               }
            }
            else
            {
               support = false;
            }
            target.contextData[this.CONTEXT_POT_SUPPORT_KEY] = support;
         }
         return support;
      }
      
      private function get isDoubleBuffered() : Boolean
      {
         return this.mBufferTexture != null;
      }
      
      public function get isPersistent() : Boolean
      {
         return this.mIsPersistent;
      }
      
      override public function get base() : TextureBase
      {
         return this.mActiveTexture.base;
      }
      
      override public function get root() : ConcreteTexture
      {
         return this.mActiveTexture.root;
      }
   }
}
