package starling.display
{
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import starling.core.RenderSupport;
   import starling.events.Event;
   import starling.utils.MathUtil;
   import starling.utils.MatrixUtil;
   import starling.utils.rad2deg;
   
   public class Sprite3D extends DisplayObjectContainer
   {
      
      private static const E:Number = 0.00001;
      
      private static var sHelperPoint:Vector3D = new Vector3D();
      
      private static var sHelperPointAlt:Vector3D = new Vector3D();
      
      private static var sHelperMatrix:Matrix3D = new Matrix3D();
       
      
      private var mRotationX:Number;
      
      private var mRotationY:Number;
      
      private var mScaleZ:Number;
      
      private var mPivotZ:Number;
      
      private var mZ:Number;
      
      private var mTransformationMatrix:Matrix;
      
      private var mTransformationMatrix3D:Matrix3D;
      
      private var mTransformationChanged:Boolean;
      
      public function Sprite3D()
      {
         super();
         this.mScaleZ = 1;
         this.mRotationX = this.mRotationY = this.mPivotZ = this.mZ = 0;
         this.mTransformationMatrix = new Matrix();
         this.mTransformationMatrix3D = new Matrix3D();
         setIs3D(true);
         addEventListener(Event.ADDED,this.onAddedChild);
         addEventListener(Event.REMOVED,this.onRemovedChild);
      }
      
      override public function render(param1:RenderSupport, param2:Number) : void
      {
         if(this.is2D)
         {
            super.render(param1,param2);
         }
         else
         {
            param1.finishQuadBatch();
            param1.pushMatrix3D();
            param1.transformMatrix3D(this);
            super.render(param1,param2);
            param1.finishQuadBatch();
            param1.popMatrix3D();
         }
      }
      
      override public function hitTest(param1:Point, param2:Boolean = false) : DisplayObject
      {
         if(this.is2D)
         {
            return super.hitTest(param1,param2);
         }
         if(param2 && (!visible || !touchable))
         {
            return null;
         }
         sHelperMatrix.copyFrom(this.transformationMatrix3D);
         sHelperMatrix.invert();
         stage.getCameraPosition(this,sHelperPoint);
         MatrixUtil.transformCoords3D(sHelperMatrix,param1.x,param1.y,0,sHelperPointAlt);
         MathUtil.intersectLineWithXYPlane(sHelperPoint,sHelperPointAlt,param1);
         return super.hitTest(param1,param2);
      }
      
      private function onAddedChild(param1:Event) : void
      {
         this.recursivelySetIs3D(param1.target as DisplayObject,true);
      }
      
      private function onRemovedChild(param1:Event) : void
      {
         this.recursivelySetIs3D(param1.target as DisplayObject,false);
      }
      
      private function recursivelySetIs3D(param1:DisplayObject, param2:Boolean) : void
      {
         var _loc3_:DisplayObjectContainer = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param1 is Sprite3D)
         {
            return;
         }
         if(param1 is DisplayObjectContainer)
         {
            _loc3_ = param1 as DisplayObjectContainer;
            _loc4_ = _loc3_.numChildren;
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               this.recursivelySetIs3D(_loc3_.getChildAt(_loc5_),param2);
               _loc5_++;
            }
         }
         param1.setIs3D(param2);
      }
      
      private function updateMatrices() : void
      {
         var _loc1_:Number = this.x;
         var _loc2_:Number = this.y;
         var _loc3_:Number = this.scaleX;
         var _loc4_:Number = this.scaleY;
         var _loc5_:Number = this.pivotX;
         var _loc6_:Number = this.pivotY;
         var _loc7_:Number = this.rotation;
         this.mTransformationMatrix3D.identity();
         if(_loc3_ != 1 || _loc4_ != 1 || this.mScaleZ != 1)
         {
            this.mTransformationMatrix3D.appendScale(_loc3_ || E,_loc4_ || E,this.mScaleZ || E);
         }
         if(this.mRotationX != 0)
         {
            this.mTransformationMatrix3D.appendRotation(rad2deg(this.mRotationX),Vector3D.X_AXIS);
         }
         if(this.mRotationY != 0)
         {
            this.mTransformationMatrix3D.appendRotation(rad2deg(this.mRotationY),Vector3D.Y_AXIS);
         }
         if(_loc7_ != 0)
         {
            this.mTransformationMatrix3D.appendRotation(rad2deg(_loc7_),Vector3D.Z_AXIS);
         }
         if(_loc1_ != 0 || _loc2_ != 0 || this.mZ != 0)
         {
            this.mTransformationMatrix3D.appendTranslation(_loc1_,_loc2_,this.mZ);
         }
         if(_loc5_ != 0 || _loc6_ != 0 || this.mPivotZ != 0)
         {
            this.mTransformationMatrix3D.prependTranslation(-_loc5_,-_loc6_,-this.mPivotZ);
         }
         if(this.is2D)
         {
            MatrixUtil.convertTo2D(this.mTransformationMatrix3D,this.mTransformationMatrix);
         }
         else
         {
            this.mTransformationMatrix.identity();
         }
      }
      
      final private function get is2D() : Boolean
      {
         return this.mZ > -E && this.mZ < E && this.mRotationX > -E && this.mRotationX < E && this.mRotationY > -E && this.mRotationY < E && this.mPivotZ > -E && this.mPivotZ < E;
      }
      
      override public function get transformationMatrix() : Matrix
      {
         if(this.mTransformationChanged)
         {
            this.updateMatrices();
            this.mTransformationChanged = false;
         }
         return this.mTransformationMatrix;
      }
      
      override public function set transformationMatrix(param1:Matrix) : void
      {
         super.transformationMatrix = param1;
         this.mRotationX = this.mRotationY = this.mPivotZ = this.mZ = 0;
         this.mTransformationChanged = true;
      }
      
      override public function get transformationMatrix3D() : Matrix3D
      {
         if(this.mTransformationChanged)
         {
            this.updateMatrices();
            this.mTransformationChanged = false;
         }
         return this.mTransformationMatrix3D;
      }
      
      override public function set x(param1:Number) : void
      {
         super.x = param1;
         this.mTransformationChanged = true;
      }
      
      override public function set y(param1:Number) : void
      {
         super.y = param1;
         this.mTransformationChanged = true;
      }
      
      public function get z() : Number
      {
         return this.mZ;
      }
      
      public function set z(param1:Number) : void
      {
         this.mZ = param1;
         this.mTransformationChanged = true;
      }
      
      override public function set pivotX(param1:Number) : void
      {
         super.pivotX = param1;
         this.mTransformationChanged = true;
      }
      
      override public function set pivotY(param1:Number) : void
      {
         super.pivotY = param1;
         this.mTransformationChanged = true;
      }
      
      public function get pivotZ() : Number
      {
         return this.mPivotZ;
      }
      
      public function set pivotZ(param1:Number) : void
      {
         this.mPivotZ = param1;
         this.mTransformationChanged = true;
      }
      
      override public function set scaleX(param1:Number) : void
      {
         super.scaleX = param1;
         this.mTransformationChanged = true;
      }
      
      override public function set scaleY(param1:Number) : void
      {
         super.scaleY = param1;
         this.mTransformationChanged = true;
      }
      
      public function get scaleZ() : Number
      {
         return this.mScaleZ;
      }
      
      public function set scaleZ(param1:Number) : void
      {
         this.mScaleZ = param1;
         this.mTransformationChanged = true;
      }
      
      override public function set skewX(param1:Number) : void
      {
         throw new Error("3D objects do not support skewing");
      }
      
      override public function set skewY(param1:Number) : void
      {
         throw new Error("3D objects do not support skewing");
      }
      
      override public function set rotation(param1:Number) : void
      {
         super.rotation = param1;
         this.mTransformationChanged = true;
      }
      
      public function get rotationX() : Number
      {
         return this.mRotationX;
      }
      
      public function set rotationX(param1:Number) : void
      {
         this.mRotationX = MathUtil.normalizeAngle(param1);
         this.mTransformationChanged = true;
      }
      
      public function get rotationY() : Number
      {
         return this.mRotationY;
      }
      
      public function set rotationY(param1:Number) : void
      {
         this.mRotationY = MathUtil.normalizeAngle(param1);
         this.mTransformationChanged = true;
      }
      
      public function get rotationZ() : Number
      {
         return rotation;
      }
      
      public function set rotationZ(param1:Number) : void
      {
         this.rotation = param1;
      }
   }
}
