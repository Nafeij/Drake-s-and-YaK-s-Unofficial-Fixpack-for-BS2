package engine.landscape.view
{
   import engine.anim.view.XAnimClipSpriteBase;
   import engine.gui.IReleasable;
   import engine.math.Rng;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Transform;
   
   public class DisplayObjectWrapper
   {
       
      
      protected var gi:IReleasable;
      
      public var anim:XAnimClipSpriteBase;
      
      public function DisplayObjectWrapper()
      {
         super();
      }
      
      public function release() : void
      {
         this.removeFromParent();
         if(this.gi)
         {
            this.gi.release();
            this.gi = null;
         }
         this.cleanup();
      }
      
      public function set color(param1:*) : void
      {
      }
      
      public function get numChildren() : int
      {
         return 0;
      }
      
      public function set transform(param1:Transform) : void
      {
      }
      
      public function get transform() : Transform
      {
         return null;
      }
      
      public function set transformMatrix(param1:Matrix) : void
      {
      }
      
      public function get transformMatrix() : Matrix
      {
         return null;
      }
      
      public function set visible(param1:Boolean) : void
      {
      }
      
      public function get visible() : Boolean
      {
         return false;
      }
      
      public function removeFromParent() : void
      {
      }
      
      public function getStageBounds() : Rectangle
      {
         return null;
      }
      
      public function getMyBounds() : Rectangle
      {
         return null;
      }
      
      public function get hasParent() : Boolean
      {
         return false;
      }
      
      public function contains(param1:DisplayObjectWrapper) : Boolean
      {
         return false;
      }
      
      public function addChild(param1:DisplayObjectWrapper) : void
      {
      }
      
      public function addChildAt(param1:DisplayObjectWrapper, param2:int) : void
      {
      }
      
      public function setChildIndex(param1:DisplayObjectWrapper, param2:int) : void
      {
      }
      
      public function get myChildIndex() : int
      {
         return -1;
      }
      
      public function bringToFront() : void
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function removeChild(param1:DisplayObjectWrapper) : void
      {
      }
      
      public function hitTestPoint(param1:Number, param2:Number) : Boolean
      {
         return false;
      }
      
      public function globalToLocal(param1:Point) : Point
      {
         return param1;
      }
      
      public function localToGlobal(param1:Point) : Point
      {
         return param1;
      }
      
      public function set x(param1:Number) : void
      {
      }
      
      public function set y(param1:Number) : void
      {
      }
      
      public function get x() : Number
      {
         return 0;
      }
      
      public function get y() : Number
      {
         return 0;
      }
      
      public function get name() : String
      {
         return null;
      }
      
      public function set name(param1:String) : void
      {
      }
      
      public function set scale(param1:Number) : void
      {
      }
      
      public function set scaleX(param1:Number) : void
      {
      }
      
      public function set scaleY(param1:Number) : void
      {
      }
      
      public function get scaleX() : Number
      {
         return 0;
      }
      
      public function get scaleY() : Number
      {
         return 0;
      }
      
      public function get width() : Number
      {
         return 0;
      }
      
      public function get height() : Number
      {
         return 0;
      }
      
      public function get rotationDegrees() : Number
      {
         return 0;
      }
      
      public function set rotationDegrees(param1:Number) : void
      {
      }
      
      public function get rotationRadians() : Number
      {
         return 0;
      }
      
      public function set rotationRadians(param1:Number) : void
      {
      }
      
      public function set blendMode(param1:String) : void
      {
      }
      
      public function get blendMode() : String
      {
         return null;
      }
      
      public function set opaqueBackground(param1:*) : void
      {
      }
      
      public function set alpha(param1:Number) : void
      {
      }
      
      public function get alpha() : Number
      {
         return 1;
      }
      
      public function removeAllChildren() : void
      {
      }
      
      final public function update(param1:int) : void
      {
         if(!this.anim || !this.anim.clip)
         {
            return;
         }
         if(this.anim.clip.playing)
         {
            this.anim.clip.advance(param1);
            this.anim.update();
         }
      }
      
      final public function cleanup() : void
      {
         this.removeFromParent();
         if(this.anim)
         {
            if(this.anim.clip)
            {
               this.anim.clip.stop();
               this.anim.clip.cleanup();
            }
            this.anim.cleanup();
            this.anim = null;
         }
      }
      
      final public function animPlay(param1:Rng, param2:int, param3:int) : Boolean
      {
         if(this.anim)
         {
            if(Boolean(this.anim.clip) && !this.anim.clip.playing)
            {
               if(param2 < 0)
               {
                  param2 = Math.round(param1.nextNumber() * (this.anim.clip.def.numFrames - 1));
               }
               this.anim.clip.repeatLimit = param3;
               this.anim.visible = true;
               this.anim.clip.start(param2);
            }
            return true;
         }
         return false;
      }
      
      final public function animStop() : void
      {
         if(Boolean(this.anim) && Boolean(this.anim.clip))
         {
            this.anim.clip.stop();
         }
      }
      
      final public function animToggle(param1:Boolean) : void
      {
         if(Boolean(this.anim) && Boolean(this.anim.clip))
         {
            if(!this.anim.clip.playing && param1)
            {
               this.anim.clip.start(this.anim.clip.frame);
            }
            else if(this.anim.clip.playing && !param1)
            {
               this.anim.clip.stop();
            }
         }
      }
      
      final public function animResume(param1:Boolean) : void
      {
         if(Boolean(this.anim) && Boolean(this.anim.clip))
         {
            if(!this.anim.clip.playing)
            {
               if(param1)
               {
                  this.anim.clip.resume();
               }
               else
               {
                  this.anim.clip.start(this.anim.clip.frame);
               }
            }
         }
      }
      
      final public function set animSpeedFactor(param1:Number) : void
      {
         if(Boolean(this.anim) && Boolean(this.anim.clip))
         {
            this.anim.clip.speedFactor = param1;
         }
      }
      
      final public function checkShowAnim(param1:int, param2:Boolean) : void
      {
         if(!this.anim)
         {
            return;
         }
         this.anim.visible = param2;
         if(!param2)
         {
            this.anim.clip.stop();
         }
         else
         {
            this.anim.clip.repeatLimit = param1;
            this.anim.visible = true;
            this.anim.clip.resume();
         }
      }
   }
}
