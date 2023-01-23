package game.gui
{
   import engine.core.logging.ILogger;
   import flash.display.DisplayObject;
   
   public class TallyTotalAnim
   {
       
      
      private var _target:DisplayObject;
      
      private var _x:Number;
      
      private var _dX:Number;
      
      private var _y:Number;
      
      private var _dY:Number;
      
      private var _scale:Number = 1;
      
      private var _dScale:Number;
      
      private var _duration:int;
      
      private var _dTime:int;
      
      public var delay:int;
      
      public var onComplete:Function;
      
      public var onCompleteParams:Array;
      
      private var _elapsed:int;
      
      private var _logger:ILogger;
      
      public function TallyTotalAnim(param1:ILogger)
      {
         super();
         this._logger = param1;
      }
      
      public function update(param1:int) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:GuiBase = null;
         if(this._elapsed <= 0)
         {
            this._updateAnimDeltaValues();
         }
         this._elapsed += param1;
         var _loc2_:Number = this.interp(this._dX,this._elapsed,param1,this.duration);
         _loc3_ = this.interp(this._dY,this._elapsed,param1,this.duration);
         this.target.x += _loc2_;
         this.target.y += _loc3_;
         if(this.target is GuiBase && this._dScale != 0)
         {
            _loc4_ = this.target as GuiBase;
            _loc4_.scale += this.interp(this._dScale,this._elapsed,param1,this.duration);
         }
      }
      
      public function doOnComplete() : void
      {
         if(this.onComplete == null)
         {
            return;
         }
         if(this.onCompleteParams == null || this.onCompleteParams.length == 0)
         {
            this.onComplete();
         }
         else if(this.onCompleteParams.length == 1)
         {
            this.onComplete(this.onCompleteParams[0]);
         }
         else if(this.onCompleteParams.length === 2)
         {
            this.onComplete(this.onCompleteParams[0],this.onCompleteParams[1]);
         }
      }
      
      private function interp(param1:Number, param2:int, param3:int, param4:int) : Number
      {
         return param1 * (param3 / param4);
      }
      
      public function get complete() : Boolean
      {
         return this._elapsed >= this.duration;
      }
      
      private function _updateAnimDeltaValues() : void
      {
         var _loc1_:GuiBase = null;
         if(this.target)
         {
            this._dX = this.x - this.target.x;
            this._dY = this.y - this.target.y;
            if(this.target is GuiBase)
            {
               _loc1_ = this.target as GuiBase;
               this._dScale = this.scale - _loc1_.scale;
            }
         }
      }
      
      public function get target() : DisplayObject
      {
         return this._target;
      }
      
      public function set target(param1:DisplayObject) : void
      {
         this._target = param1;
         this._updateAnimDeltaValues();
      }
      
      public function get x() : Number
      {
         return this._x;
      }
      
      public function set x(param1:Number) : void
      {
         this._x = param1;
         this._updateAnimDeltaValues();
      }
      
      public function get y() : Number
      {
         return this._y;
      }
      
      public function set y(param1:Number) : void
      {
         this._y = param1;
         this._updateAnimDeltaValues();
      }
      
      public function get scale() : Number
      {
         return this._scale;
      }
      
      public function set scale(param1:Number) : void
      {
         this._scale = param1;
         this._updateAnimDeltaValues();
      }
      
      public function get duration() : int
      {
         return this._duration;
      }
      
      public function set duration(param1:int) : void
      {
         this._duration = param1;
         this._updateAnimDeltaValues();
      }
   }
}
