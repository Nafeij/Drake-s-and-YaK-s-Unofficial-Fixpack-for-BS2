package engine.anim.def
{
   import engine.core.logging.ILogger;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import starling.display.BlendMode;
   import starling.utils.MatrixUtil;
   
   public class AnimFrameChild
   {
       
      
      public var childIndex:int;
      
      public var position:Point;
      
      public var rotation:Number = 0;
      
      public var scale:Point;
      
      public var alpha:Number = 1;
      
      public var color:uint = 16777215;
      
      public var frameNum:int;
      
      public var blendMode:String;
      
      public var visible:Boolean;
      
      public var transformMatrix:Matrix;
      
      public var mc:MovieClip;
      
      public function AnimFrameChild()
      {
         super();
      }
      
      private static function recursivePath(param1:DisplayObject) : String
      {
         var _loc2_:String = param1.name;
         var _loc3_:DisplayObject = param1.parent;
         while(_loc3_)
         {
            _loc2_ = _loc3_.name + "." + _loc2_;
            _loc3_ = _loc3_.parent;
         }
         return _loc2_;
      }
      
      public function get numBytes() : int
      {
         return 4 * 11 + (!!this.blendMode ? this.blendMode.length : 0);
      }
      
      public function fromMovieClip(param1:AnimClipChildDef, param2:MovieClip, param3:int, param4:int, param5:Number) : AnimFrameChild
      {
         var _loc6_:ColorTransform = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         this.mc = param2;
         this.frameNum = param3;
         this.visible = param2.visible;
         if(!param2.visible)
         {
            this.visible = param2.visible;
         }
         this.childIndex = param4;
         this.alpha = param2.alpha;
         this.alpha = Math.round(this.alpha * 100) / 100;
         if(Boolean(param2.transform) && Boolean(param2.transform.colorTransform))
         {
            _loc6_ = param2.transform.colorTransform;
            if(_loc6_.blueMultiplier != 1 || _loc6_.redMultiplier != 1 || _loc6_.greenMultiplier != 1 || _loc6_.blueOffset != 0 || _loc6_.redOffset != 0 || _loc6_.greenOffset != 0)
            {
               this.color = _loc6_.color;
            }
         }
         if(param2.blendMode != flash.display.BlendMode.NORMAL)
         {
            switch(param2.blendMode)
            {
               case starling.display.BlendMode.ADD:
               case starling.display.BlendMode.BELOW:
               case starling.display.BlendMode.ERASE:
               case starling.display.BlendMode.MULTIPLY:
               case starling.display.BlendMode.SCREEN:
               case starling.display.BlendMode.NONE:
                  this.blendMode = param2.blendMode;
                  break;
               default:
                  throw new ArgumentError("unsupported blend mode [" + param2.blendMode + "] on " + recursivePath(param2));
            }
         }
         if(param2.transform.matrix)
         {
            if(Boolean(this.mc.parent) && Boolean(this.mc.parent.transform))
            {
               this.transformMatrix = this.mc.parent.transform.matrix.clone();
            }
            else
            {
               this.transformMatrix = new Matrix();
            }
            this.transformMatrix.concat(param2.transform.matrix);
            if(param5)
            {
               this.transformMatrix.scale(1 / param5,1 / param5);
               this.transformMatrix.tx = param2.x * param5;
               this.transformMatrix.ty = param2.y * param5;
            }
         }
         else
         {
            if(param2.x != 0 || param2.y != 0)
            {
               this.position = new Point(param2.x,param2.y);
               this.position.x *= param2.parent.scaleX;
               this.position.y *= param2.parent.scaleY;
               this.position.x = Math.round(this.position.x * 100) / 100;
               this.position.y = Math.round(this.position.y * 100) / 100;
            }
            this.rotation = param2.rotation;
            this.rotation = Math.round(this.rotation * 100) / 100;
            _loc7_ = Math.abs(param2.scaleX - 1);
            _loc8_ = Math.abs(param2.scaleY - 1);
            if(_loc7_ > 0.01 || _loc8_ > 0.01)
            {
               this.scale = new Point(param2.scaleX,param2.scaleY);
               this.scale.x = Math.round(this.scale.x * 100) / 100;
               this.scale.y = Math.round(this.scale.y * 100) / 100;
            }
         }
         return this;
      }
      
      public function equals(param1:AnimFrameChild) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(this.position == null != (param1.position == null))
         {
            return false;
         }
         if(this.position)
         {
            if(!this.position.equals(param1.position))
            {
               return false;
            }
         }
         if(this.alpha != param1.alpha)
         {
            return false;
         }
         if(this.visible != param1.visible)
         {
            return false;
         }
         if(this.blendMode != param1.blendMode)
         {
            return false;
         }
         if(this.scale == null != (param1.scale == null))
         {
            return false;
         }
         if(this.scale)
         {
            if(!this.scale.equals(param1.scale))
            {
               return false;
            }
         }
         if(this.rotation != param1.rotation)
         {
            return false;
         }
         if(this.transformMatrix && !param1.transformMatrix || !this.transformMatrix && param1.transformMatrix)
         {
            return false;
         }
         if(Boolean(this.transformMatrix) && Boolean(param1.transformMatrix) && this.transformMatrix != param1.transformMatrix)
         {
            if(this.transformMatrix.a != param1.transformMatrix.a || this.transformMatrix.b != param1.transformMatrix.b || this.transformMatrix.c != param1.transformMatrix.c || this.transformMatrix.d != param1.transformMatrix.d || this.transformMatrix.tx != param1.transformMatrix.tx || this.transformMatrix.ty != param1.transformMatrix.ty)
            {
               return false;
            }
         }
         return true;
      }
      
      public function readBytes(param1:ByteArray, param2:ILogger) : void
      {
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         this.childIndex = param1.readUnsignedByte();
         this.frameNum = param1.readShort();
         if(this.frameNum >= 0)
         {
            return;
         }
         var _loc3_:uint = param1.readUnsignedByte();
         var _loc4_:Boolean = Boolean(_loc3_ & 1);
         var _loc5_:Boolean = Boolean(_loc3_ & 2);
         var _loc6_:Boolean = Boolean(_loc3_ & 4);
         var _loc7_:Boolean = Boolean(_loc3_ & 8);
         var _loc8_:Boolean = Boolean(_loc3_ & 16);
         var _loc9_:Boolean = Boolean(_loc3_ & 32);
         var _loc10_:Boolean = Boolean(_loc3_ & 64);
         var _loc11_:Boolean = Boolean(_loc3_ & 128);
         this.position = _loc4_ ? new Point(param1.readFloat(),param1.readFloat()) : null;
         this.scale = _loc5_ ? new Point(param1.readFloat(),param1.readFloat()) : null;
         this.rotation = _loc6_ ? param1.readFloat() : 0;
         this.alpha = _loc7_ ? param1.readFloat() : 1;
         this.blendMode = _loc8_ ? param1.readUTF() : null;
         this.visible = _loc9_;
         if(_loc10_)
         {
            this.color = this.color;
         }
         this.color = _loc10_ ? param1.readUnsignedInt() : this.color;
         if(_loc11_)
         {
            _loc12_ = param1.readFloat();
            _loc13_ = param1.readFloat();
            _loc14_ = param1.readFloat();
            _loc15_ = param1.readFloat();
            _loc16_ = param1.readFloat();
            _loc17_ = param1.readFloat();
            this.transformMatrix = new Matrix(_loc12_,_loc13_,_loc14_,_loc15_,_loc16_,_loc17_);
         }
      }
      
      public function writeBytes(param1:ByteArray, param2:int) : void
      {
         param1.writeByte(this.childIndex);
         if(param2 == this.frameNum || this.frameNum < 0)
         {
            param1.writeShort(-1);
            var _loc3_:uint = 0;
            var _loc4_:Boolean = Boolean(this.transformMatrix) && !MatrixUtil.is2DIdentityMatrix(this.transformMatrix);
            var _loc5_:Boolean = Boolean(this.position) && !_loc4_ && (Boolean(this.position.x) || Boolean(this.position.y));
            var _loc6_:Boolean = Boolean(this.scale) && !_loc4_ && (this.scale.x != 1 || this.scale.y != 1);
            var _loc7_:Boolean = !_loc4_ && this.rotation != 0;
            var _loc8_:* = this.alpha != 1;
            var _loc9_:Boolean = this.visible;
            var _loc10_:* = (this.color & 16777215) != 16777215;
            _loc3_ |= _loc5_ ? 1 : 0;
            _loc3_ |= _loc6_ ? 2 : 0;
            _loc3_ |= _loc7_ ? 4 : 0;
            _loc3_ |= _loc8_ ? 8 : 0;
            _loc3_ |= !!this.blendMode ? 16 : 0;
            _loc3_ |= _loc9_ ? 32 : 0;
            _loc3_ |= _loc10_ ? 64 : 0;
            _loc3_ |= _loc4_ ? 128 : 0;
            param1.writeByte(_loc3_);
            if(_loc5_)
            {
               param1.writeFloat(this.position.x);
               param1.writeFloat(this.position.y);
            }
            if(_loc6_)
            {
               param1.writeFloat(this.scale.x);
               param1.writeFloat(this.scale.y);
            }
            if(_loc7_)
            {
               param1.writeFloat(this.rotation);
            }
            if(_loc8_)
            {
               param1.writeFloat(this.alpha);
            }
            if(this.blendMode)
            {
               param1.writeUTF(this.blendMode);
            }
            if(_loc10_)
            {
               param1.writeUnsignedInt(this.color);
            }
            if(_loc4_)
            {
               param1.writeFloat(this.transformMatrix.a);
               param1.writeFloat(this.transformMatrix.b);
               param1.writeFloat(this.transformMatrix.c);
               param1.writeFloat(this.transformMatrix.d);
               param1.writeFloat(this.transformMatrix.tx);
               param1.writeFloat(this.transformMatrix.ty);
            }
            return;
         }
         param1.writeShort(this.frameNum);
      }
   }
}
