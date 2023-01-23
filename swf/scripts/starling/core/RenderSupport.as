package starling.core
{
   import com.adobe.utils.AGALMiniAssembler;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DCompareMode;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.Context3DStencilAction;
   import flash.display3D.Context3DTextureFormat;
   import flash.display3D.Context3DTriangleFace;
   import flash.display3D.Program3D;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import starling.display.BlendMode;
   import starling.display.DisplayObject;
   import starling.display.Quad;
   import starling.display.QuadBatch;
   import starling.display.Stage;
   import starling.errors.MissingContextError;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   import starling.utils.Color;
   import starling.utils.MatrixUtil;
   import starling.utils.RectangleUtil;
   import starling.utils.SystemUtil;
   
   public class RenderSupport
   {
      
      private static const RENDER_TARGET_NAME:String = "Starling.renderTarget";
      
      private static var sPoint:Point = new Point();
      
      private static var sPoint3D:Vector3D = new Vector3D();
      
      private static var sClipRect:Rectangle = new Rectangle();
      
      private static var sBufferRect:Rectangle = new Rectangle();
      
      private static var sScissorRect:Rectangle = new Rectangle();
      
      private static var sAssembler:AGALMiniAssembler = new AGALMiniAssembler();
      
      private static var sMatrix3D:Matrix3D = new Matrix3D();
      
      private static var sMatrixData:Vector.<Number> = new <Number>[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
       
      
      private var mProjectionMatrix:Matrix;
      
      private var mModelViewMatrix:Matrix;
      
      private var mMvpMatrix:Matrix;
      
      private var mMatrixStack:Vector.<Matrix>;
      
      private var mMatrixStackSize:int;
      
      private var mProjectionMatrix3D:Matrix3D;
      
      private var mModelViewMatrix3D:Matrix3D;
      
      private var mMvpMatrix3D:Matrix3D;
      
      private var mMatrixStack3D:Vector.<Matrix3D>;
      
      private var mMatrixStack3DSize:int;
      
      private var mDrawCount:int;
      
      private var mBlendMode:String;
      
      private var mClipRectStack:Vector.<Rectangle>;
      
      private var mClipRectStackSize:int;
      
      private var mQuadBatches:Vector.<QuadBatch>;
      
      private var mCurrentQuadBatchID:int;
      
      private var mMasks:Vector.<DisplayObject>;
      
      private var mStencilReferenceValue:uint = 0;
      
      public function RenderSupport()
      {
         this.mMasks = new Vector.<DisplayObject>(0);
         super();
         this.mProjectionMatrix = new Matrix();
         this.mModelViewMatrix = new Matrix();
         this.mMvpMatrix = new Matrix();
         this.mMatrixStack = new Vector.<Matrix>(0);
         this.mMatrixStackSize = 0;
         this.mProjectionMatrix3D = new Matrix3D();
         this.mModelViewMatrix3D = new Matrix3D();
         this.mMvpMatrix3D = new Matrix3D();
         this.mMatrixStack3D = new Vector.<Matrix3D>(0);
         this.mMatrixStack3DSize = 0;
         this.mDrawCount = 0;
         this.mBlendMode = BlendMode.NORMAL;
         this.mClipRectStack = new Vector.<Rectangle>(0);
         this.mCurrentQuadBatchID = 0;
         this.mQuadBatches = new <QuadBatch>[this.createQuadBatch()];
         this.loadIdentity();
         this.setProjectionMatrix(0,0,400,300);
      }
      
      public static function transformMatrixForObject(param1:Matrix, param2:DisplayObject) : void
      {
         MatrixUtil.prependMatrix(param1,param2.transformationMatrix);
      }
      
      public static function setDefaultBlendFactors(param1:Boolean) : void
      {
         setBlendFactors(param1);
      }
      
      public static function setBlendFactors(param1:Boolean, param2:String = "normal") : void
      {
         var _loc3_:Array = BlendMode.getBlendFactors(param2,param1);
         Starling.context.setBlendFactors(_loc3_[0],_loc3_[1]);
      }
      
      public static function clear(param1:uint = 0, param2:Number = 0) : void
      {
         Starling.context.clear(Color.getRed(param1) / 255,Color.getGreen(param1) / 255,Color.getBlue(param1) / 255,param2);
      }
      
      public static function assembleAgal(param1:String, param2:String, param3:Program3D = null) : Program3D
      {
         var _loc4_:Context3D = null;
         if(param3 == null)
         {
            _loc4_ = Starling.context;
            if(_loc4_ == null)
            {
               throw new MissingContextError();
            }
            param3 = _loc4_.createProgram();
         }
         param3.upload(sAssembler.assemble(Context3DProgramType.VERTEX,param1),sAssembler.assemble(Context3DProgramType.FRAGMENT,param2));
         return param3;
      }
      
      public static function getTextureLookupFlags(param1:String, param2:Boolean, param3:Boolean = false, param4:String = "bilinear") : String
      {
         var _loc5_:Array = ["2d",param3 ? "repeat" : "clamp"];
         if(param1 == Context3DTextureFormat.COMPRESSED)
         {
            _loc5_.push("dxt1");
         }
         else if(param1 == "compressedAlpha")
         {
            _loc5_.push("dxt5");
         }
         if(param4 == TextureSmoothing.NONE)
         {
            _loc5_.push("nearest",param2 ? "mipnearest" : "mipnone");
         }
         else if(param4 == TextureSmoothing.BILINEAR)
         {
            _loc5_.push("linear",param2 ? "mipnearest" : "mipnone");
         }
         else
         {
            _loc5_.push("linear",param2 ? "miplinear" : "mipnone");
         }
         return "<" + _loc5_.join() + ">";
      }
      
      public function dispose() : void
      {
         var _loc1_:QuadBatch = null;
         for each(_loc1_ in this.mQuadBatches)
         {
            _loc1_.dispose();
         }
      }
      
      public function setProjectionMatrix(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number = 0, param6:Number = 0, param7:Vector3D = null) : void
      {
         var _loc8_:Number = NaN;
         if(param5 <= 0)
         {
            param5 = param3;
         }
         if(param6 <= 0)
         {
            param6 = param4;
         }
         if(param7 == null)
         {
            param7 = sPoint3D;
            param7.setTo(param5 / 2,param6 / 2,param5 / Math.tan(0.5) * 0.5);
         }
         this.mProjectionMatrix.setTo(2 / param3,0,0,-2 / param4,-(2 * param1 + param3) / param3,(2 * param2 + param4) / param4);
         _loc8_ = Math.abs(param7.z);
         var _loc9_:Number = param7.x - param5 / 2;
         var _loc10_:Number = param7.y - param6 / 2;
         var _loc11_:Number = _loc8_ * 20;
         var _loc12_:Number = 1;
         var _loc13_:Number = param5 / param3;
         var _loc14_:Number = param6 / param4;
         sMatrixData[0] = 2 * _loc8_ / param5;
         sMatrixData[5] = -2 * _loc8_ / param6;
         sMatrixData[10] = _loc11_ / (_loc11_ - _loc12_);
         sMatrixData[14] = -_loc11_ * _loc12_ / (_loc11_ - _loc12_);
         sMatrixData[11] = 1;
         sMatrixData[0] *= _loc13_;
         sMatrixData[5] *= _loc14_;
         sMatrixData[8] = _loc13_ - 1 - 2 * _loc13_ * (param1 - _loc9_) / param5;
         sMatrixData[9] = -_loc14_ + 1 + 2 * _loc14_ * (param2 - _loc10_) / param6;
         this.mProjectionMatrix3D.copyRawDataFrom(sMatrixData);
         this.mProjectionMatrix3D.prependTranslation(-param5 / 2 - _loc9_,-param6 / 2 - _loc10_,_loc8_);
         this.applyClipRect();
      }
      
      public function setOrthographicProjection(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         var _loc5_:Stage = Starling.current.stage;
         sClipRect.setTo(param1,param2,param3,param4);
         this.setProjectionMatrix(param1,param2,param3,param4,_loc5_.stageWidth,_loc5_.stageHeight,_loc5_.cameraPosition);
      }
      
      public function loadIdentity() : void
      {
         this.mModelViewMatrix.identity();
         this.mModelViewMatrix3D.identity();
      }
      
      public function translateMatrix(param1:Number, param2:Number) : void
      {
         MatrixUtil.prependTranslation(this.mModelViewMatrix,param1,param2);
      }
      
      public function rotateMatrix(param1:Number) : void
      {
         MatrixUtil.prependRotation(this.mModelViewMatrix,param1);
      }
      
      public function scaleMatrix(param1:Number, param2:Number) : void
      {
         MatrixUtil.prependScale(this.mModelViewMatrix,param1,param2);
      }
      
      public function prependMatrix(param1:Matrix) : void
      {
         MatrixUtil.prependMatrix(this.mModelViewMatrix,param1);
      }
      
      public function transformMatrix(param1:DisplayObject) : void
      {
         MatrixUtil.prependMatrix(this.mModelViewMatrix,param1.transformationMatrix);
      }
      
      public function pushMatrix() : void
      {
         if(this.mMatrixStack.length < this.mMatrixStackSize + 1)
         {
            this.mMatrixStack.push(new Matrix());
         }
         this.mMatrixStack[int(this.mMatrixStackSize++)].copyFrom(this.mModelViewMatrix);
      }
      
      public function popMatrix() : void
      {
         this.mModelViewMatrix.copyFrom(this.mMatrixStack[int(--this.mMatrixStackSize)]);
      }
      
      public function resetMatrix() : void
      {
         this.mMatrixStackSize = 0;
         this.mMatrixStack3DSize = 0;
         this.loadIdentity();
      }
      
      public function get mvpMatrix() : Matrix
      {
         this.mMvpMatrix.copyFrom(this.mModelViewMatrix);
         this.mMvpMatrix.concat(this.mProjectionMatrix);
         return this.mMvpMatrix;
      }
      
      public function get modelViewMatrix() : Matrix
      {
         return this.mModelViewMatrix;
      }
      
      public function get projectionMatrix() : Matrix
      {
         return this.mProjectionMatrix;
      }
      
      public function set projectionMatrix(param1:Matrix) : void
      {
         this.mProjectionMatrix.copyFrom(param1);
         this.applyClipRect();
      }
      
      public function transformMatrix3D(param1:DisplayObject) : void
      {
         this.mModelViewMatrix3D.prepend(MatrixUtil.convertTo3D(this.mModelViewMatrix,sMatrix3D));
         this.mModelViewMatrix3D.prepend(param1.transformationMatrix3D);
         this.mModelViewMatrix.identity();
      }
      
      public function pushMatrix3D() : void
      {
         if(this.mMatrixStack3D.length < this.mMatrixStack3DSize + 1)
         {
            this.mMatrixStack3D.push(new Matrix3D());
         }
         this.mMatrixStack3D[int(this.mMatrixStack3DSize++)].copyFrom(this.mModelViewMatrix3D);
      }
      
      public function popMatrix3D() : void
      {
         this.mModelViewMatrix3D.copyFrom(this.mMatrixStack3D[int(--this.mMatrixStack3DSize)]);
      }
      
      public function get mvpMatrix3D() : Matrix3D
      {
         if(this.mMatrixStack3DSize == 0)
         {
            MatrixUtil.convertTo3D(this.mvpMatrix,this.mMvpMatrix3D);
         }
         else
         {
            this.mMvpMatrix3D.copyFrom(this.mProjectionMatrix3D);
            this.mMvpMatrix3D.prepend(this.mModelViewMatrix3D);
            this.mMvpMatrix3D.prepend(MatrixUtil.convertTo3D(this.mModelViewMatrix,sMatrix3D));
         }
         return this.mMvpMatrix3D;
      }
      
      public function get projectionMatrix3D() : Matrix3D
      {
         return this.mProjectionMatrix3D;
      }
      
      public function set projectionMatrix3D(param1:Matrix3D) : void
      {
         this.mProjectionMatrix3D.copyFrom(param1);
      }
      
      public function applyBlendMode(param1:Boolean) : void
      {
         setBlendFactors(param1,this.mBlendMode);
      }
      
      public function get blendMode() : String
      {
         return this.mBlendMode;
      }
      
      public function set blendMode(param1:String) : void
      {
         if(param1 != BlendMode.AUTO)
         {
            this.mBlendMode = param1;
         }
      }
      
      public function get renderTarget() : Texture
      {
         return Starling.current.contextData[RENDER_TARGET_NAME];
      }
      
      public function set renderTarget(param1:Texture) : void
      {
         this.setRenderTarget(param1);
      }
      
      public function setRenderTarget(param1:Texture, param2:int = 0) : void
      {
         Starling.current.contextData[RENDER_TARGET_NAME] = param1;
         this.applyClipRect();
         if(param1)
         {
            Starling.context.setRenderToTexture(param1.base,SystemUtil.supportsDepthAndStencil,param2);
         }
         else
         {
            Starling.context.setRenderToBackBuffer();
         }
      }
      
      public function pushClipRect(param1:Rectangle, param2:Boolean = true) : Rectangle
      {
         if(this.mClipRectStack.length < this.mClipRectStackSize + 1)
         {
            this.mClipRectStack.push(new Rectangle());
         }
         this.mClipRectStack[this.mClipRectStackSize].copyFrom(param1);
         param1 = this.mClipRectStack[this.mClipRectStackSize];
         if(param2 && this.mClipRectStackSize > 0)
         {
            RectangleUtil.intersect(param1,this.mClipRectStack[this.mClipRectStackSize - 1],param1);
         }
         ++this.mClipRectStackSize;
         this.applyClipRect();
         return param1;
      }
      
      public function popClipRect() : void
      {
         if(this.mClipRectStackSize > 0)
         {
            --this.mClipRectStackSize;
            this.applyClipRect();
         }
      }
      
      public function applyClipRect() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Rectangle = null;
         var _loc5_:Texture = null;
         this.finishQuadBatch();
         var _loc1_:Context3D = Starling.context;
         if(_loc1_ == null)
         {
            return;
         }
         if(this.mClipRectStackSize > 0)
         {
            _loc4_ = this.mClipRectStack[this.mClipRectStackSize - 1];
            _loc5_ = this.renderTarget;
            if(_loc5_)
            {
               _loc2_ = _loc5_.root.nativeWidth;
               _loc3_ = _loc5_.root.nativeHeight;
            }
            else
            {
               _loc2_ = Starling.current.backBufferWidth;
               _loc3_ = Starling.current.backBufferHeight;
            }
            MatrixUtil.transformCoords(this.mProjectionMatrix,_loc4_.x,_loc4_.y,sPoint);
            sClipRect.x = (sPoint.x * 0.5 + 0.5) * _loc2_;
            sClipRect.y = (0.5 - sPoint.y * 0.5) * _loc3_;
            MatrixUtil.transformCoords(this.mProjectionMatrix,_loc4_.right,_loc4_.bottom,sPoint);
            sClipRect.right = (sPoint.x * 0.5 + 0.5) * _loc2_;
            sClipRect.bottom = (0.5 - sPoint.y * 0.5) * _loc3_;
            sBufferRect.setTo(0,0,_loc2_,_loc3_);
            RectangleUtil.intersect(sClipRect,sBufferRect,sScissorRect);
            if(sScissorRect.width < 1 || sScissorRect.height < 1)
            {
               sScissorRect.setTo(0,0,1,1);
            }
            _loc1_.setScissorRectangle(sScissorRect);
         }
         else
         {
            _loc1_.setScissorRectangle(null);
         }
      }
      
      public function pushMask(param1:DisplayObject) : void
      {
         this.mMasks[this.mMasks.length] = param1;
         ++this.mStencilReferenceValue;
         var _loc2_:Context3D = Starling.context;
         if(_loc2_ == null)
         {
            return;
         }
         this.finishQuadBatch();
         _loc2_.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK,Context3DCompareMode.EQUAL,Context3DStencilAction.INCREMENT_SATURATE);
         this.drawMask(param1);
         _loc2_.setStencilReferenceValue(this.mStencilReferenceValue);
         _loc2_.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK,Context3DCompareMode.EQUAL,Context3DStencilAction.KEEP);
      }
      
      public function popMask() : void
      {
         var _loc1_:DisplayObject = this.mMasks.pop();
         --this.mStencilReferenceValue;
         var _loc2_:Context3D = Starling.context;
         if(_loc2_ == null)
         {
            return;
         }
         this.finishQuadBatch();
         _loc2_.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK,Context3DCompareMode.EQUAL,Context3DStencilAction.DECREMENT_SATURATE);
         this.drawMask(_loc1_);
         _loc2_.setStencilReferenceValue(this.mStencilReferenceValue);
         _loc2_.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK,Context3DCompareMode.EQUAL,Context3DStencilAction.KEEP);
      }
      
      private function drawMask(param1:DisplayObject) : void
      {
         this.pushMatrix();
         var _loc2_:Stage = param1.stage;
         if(_loc2_)
         {
            param1.getTransformationMatrix(_loc2_,this.mModelViewMatrix);
         }
         else
         {
            this.transformMatrix(param1);
         }
         param1.render(this,0);
         this.finishQuadBatch();
         this.popMatrix();
      }
      
      public function get stencilReferenceValue() : uint
      {
         return this.mStencilReferenceValue;
      }
      
      public function set stencilReferenceValue(param1:uint) : void
      {
         this.mStencilReferenceValue = param1;
         if(Starling.current.contextValid)
         {
            Starling.context.setStencilReferenceValue(param1);
         }
      }
      
      public function batchQuad(param1:Quad, param2:Number, param3:Texture = null, param4:String = null) : void
      {
         if(this.mQuadBatches[this.mCurrentQuadBatchID].isStateChange(param1.tinted,param2,param3,param4,this.mBlendMode))
         {
            this.finishQuadBatch();
         }
         this.mQuadBatches[this.mCurrentQuadBatchID].addQuad(param1,param2,param3,param4,this.mModelViewMatrix,this.mBlendMode);
      }
      
      public function batchQuadBatch(param1:QuadBatch, param2:Number) : void
      {
         if(this.mQuadBatches[this.mCurrentQuadBatchID].isStateChange(param1.tinted,param2,param1.texture,param1.smoothing,this.mBlendMode))
         {
            this.finishQuadBatch();
         }
         this.mQuadBatches[this.mCurrentQuadBatchID].addQuadBatch(param1,param2,this.mModelViewMatrix,this.mBlendMode);
      }
      
      public function finishQuadBatch() : void
      {
         var _loc1_:QuadBatch = this.mQuadBatches[this.mCurrentQuadBatchID];
         if(_loc1_.numQuads != 0)
         {
            if(this.mMatrixStack3DSize == 0)
            {
               _loc1_.renderCustom(this.mProjectionMatrix3D);
            }
            else
            {
               this.mMvpMatrix3D.copyFrom(this.mProjectionMatrix3D);
               this.mMvpMatrix3D.prepend(this.mModelViewMatrix3D);
               _loc1_.renderCustom(this.mMvpMatrix3D);
            }
            _loc1_.reset();
            ++this.mCurrentQuadBatchID;
            ++this.mDrawCount;
            if(this.mQuadBatches.length <= this.mCurrentQuadBatchID)
            {
               this.mQuadBatches.push(this.createQuadBatch());
            }
         }
      }
      
      public function nextFrame() : void
      {
         this.resetMatrix();
         this.trimQuadBatches();
         this.mMasks.length = 0;
         this.mCurrentQuadBatchID = 0;
         this.mBlendMode = BlendMode.NORMAL;
         this.mDrawCount = 0;
      }
      
      private function trimQuadBatches() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:int = this.mCurrentQuadBatchID + 1;
         var _loc2_:int = this.mQuadBatches.length;
         if(_loc2_ >= 16 && _loc2_ > 2 * _loc1_)
         {
            _loc3_ = _loc2_ - _loc1_;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               this.mQuadBatches.pop().dispose();
               _loc4_++;
            }
         }
      }
      
      private function createQuadBatch() : QuadBatch
      {
         var _loc1_:String = Starling.current.profile;
         var _loc2_:Boolean = _loc1_ != "baselineConstrained" && _loc1_ != "baseline";
         var _loc3_:QuadBatch = new QuadBatch();
         _loc3_.forceTinted = _loc2_;
         return _loc3_;
      }
      
      public function clear(param1:uint = 0, param2:Number = 0) : void
      {
         RenderSupport.clear(param1,param2);
      }
      
      public function raiseDrawCount(param1:uint = 1) : void
      {
         this.mDrawCount += param1;
      }
      
      public function get drawCount() : int
      {
         return this.mDrawCount;
      }
   }
}
