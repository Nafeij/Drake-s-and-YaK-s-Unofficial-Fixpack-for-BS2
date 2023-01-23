package engine.battle.board.view.indicator
{
   import as3isolib.utils.IsoUtil;
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import com.greensock.easing.Strong;
   import engine.core.logging.ILogger;
   import engine.landscape.view.DisplayObjectWrapper;
   import flash.display.BitmapData;
   import flash.errors.IllegalOperationError;
   import flash.utils.getTimer;
   
   public class EntityFlyTextEntry
   {
      
      public static var last_ordinal:int = 0;
       
      
      private var eft:EntityFlyText;
      
      public var timestamp:int;
      
      private var entered:Boolean;
      
      private var shouldDepart:Boolean;
      
      public var horizontalMargin:int;
      
      private var verticalMargin:int;
      
      public var id:String;
      
      public var displayObjectWrapper:DisplayObjectWrapper;
      
      protected var bmpWrapper:DisplayObjectWrapper;
      
      private var bmpd:BitmapData;
      
      public var ordinal:int;
      
      public var logger:ILogger;
      
      public var cleanedup:Boolean;
      
      public function EntityFlyTextEntry(param1:String, param2:EntityFlyText, param3:BitmapData)
      {
         super();
         this.displayObjectWrapper = IsoUtil.createDisplayObjectWrapper();
         this.ordinal = ++last_ordinal;
         this.bmpd = param3;
         this.eft = param2;
         this.id = param1;
         this.logger = param2.logger;
         this.horizontalMargin = 8 + param3.width / 2;
         this.verticalMargin = 2 + param3.height / 2;
         this.displayObjectWrapper.addChild(this.bmpWrapper);
         this.timestamp = getTimer();
      }
      
      public function get x() : Number
      {
         return this.displayObjectWrapper.x;
      }
      
      public function get y() : Number
      {
         return this.displayObjectWrapper.y;
      }
      
      public function set x(param1:Number) : void
      {
         this.displayObjectWrapper.x = param1;
      }
      
      public function set y(param1:Number) : void
      {
         this.displayObjectWrapper.y = param1;
      }
      
      public function toString() : String
      {
         return "FlyTextEntry [id=" + this.id + " ord=" + this.ordinal + "]";
      }
      
      public function isOverlapping(param1:EntityFlyTextEntry) : Boolean
      {
         return Math.abs(this.x - param1.x) < this.horizontalMargin + param1.horizontalMargin && Math.abs(this.y - param1.y) < this.verticalMargin + param1.verticalMargin;
      }
      
      public function isOverlappingY(param1:EntityFlyTextEntry) : Boolean
      {
         return Math.abs(this.y - param1.y) < this.verticalMargin + param1.verticalMargin;
      }
      
      public function set scale(param1:Number) : void
      {
         this.displayObjectWrapper.scale = param1;
      }
      
      public function get scale() : Number
      {
         return this.displayObjectWrapper.scaleX;
      }
      
      public function get alpha() : Number
      {
         return this.displayObjectWrapper.alpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         this.displayObjectWrapper.alpha = param1;
      }
      
      public function enter() : void
      {
         this.alpha = 0;
         this.scale = 0;
         TweenMax.to(this,0.5,{
            "scale":1,
            "alpha":1,
            "ease":Strong.easeOut
         });
         var _loc1_:Number = this.bmpWrapper.y - 72;
         TweenMax.to(this.bmpWrapper,1,{
            "y":_loc1_,
            "ease":Linear.easeOut,
            "onComplete":this.enterCompleteHandler
         });
      }
      
      public function depart() : void
      {
         if(!this.entered)
         {
            this.shouldDepart = true;
            return;
         }
         TweenMax.to(this,2,{
            "y":this.y - 400,
            "alpha":0,
            "ease":Linear.easeOut,
            "onComplete":this.tweenCompleteHandler
         });
      }
      
      public function cleanup() : void
      {
         if(this.cleanedup)
         {
            throw new IllegalOperationError("double cleanup of EntityFlyTextEntry id=" + this.id + " ord=" + this.ordinal);
         }
         this.cleanedup = true;
         TweenMax.killTweensOf(this);
         TweenMax.killTweensOf(this.bmpWrapper);
         if(this.bmpd)
         {
            this.bmpd.dispose();
            this.bmpd = null;
         }
      }
      
      public function tweenCompleteHandler() : void
      {
         this.displayObjectWrapper.removeFromParent();
         this.eft.flyTextEntryCompleteHandler(this);
         this.cleanup();
      }
      
      public function enterCompleteHandler() : void
      {
         this.entered = true;
         if(this.shouldDepart)
         {
            this.depart();
         }
      }
   }
}
