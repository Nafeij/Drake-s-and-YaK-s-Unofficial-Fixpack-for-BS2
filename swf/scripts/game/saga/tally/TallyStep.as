package game.saga.tally
{
   import engine.resource.loader.SoundControllerManager;
   import game.gui.IGuiTallyTotal;
   
   public class TallyStep implements ITallyStep
   {
      
      private static const PER_TICK_INTERVAL:int = 300;
       
      
      private var _perTickTime:int = 300;
      
      public var varName:String;
      
      public var multName:String;
      
      public var multValue:Number;
      
      public var startValue:Number;
      
      public var finalValue:Number;
      
      public var currentValue:Number;
      
      public var daysValue:Number;
      
      public var doRollText:Boolean = false;
      
      public var isSum:Boolean = false;
      
      public var gui:IGuiTallyTotal;
      
      public var countUp:Boolean = false;
      
      public var useDays:Boolean = false;
      
      public var addsToDays:Boolean = false;
      
      private var _rollCompleteDelay:int;
      
      public var complete:Function;
      
      private var _text:String;
      
      private var _tickElapsed:int;
      
      private var _tickPeriod:int = 300;
      
      private var _tickPeriodDelta:int = -20;
      
      private var _tickPeriodFloor:int = 50;
      
      private var _completeDelay:int = -1;
      
      private var _perTick:uint = 1;
      
      private var _tickModCap:int = 4;
      
      private var _lastFrameAward:Number = 0;
      
      private var _soundControllerManager:SoundControllerManager;
      
      public function TallyStep(param1:String, param2:String, param3:String, param4:SoundControllerManager)
      {
         super();
         this._text = param1;
         this.varName = param2;
         this.multName = param3;
         this._soundControllerManager = param4;
      }
      
      public function get lastFrameAward() : Number
      {
         return this._lastFrameAward;
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      public function set text(param1:String) : void
      {
         this._text = param1;
      }
      
      public function get rollCompleteDelay() : int
      {
         return this._rollCompleteDelay;
      }
      
      public function set rollCompleteDelay(param1:int) : void
      {
         this._rollCompleteDelay = Math.max(param1,0);
      }
      
      public function update(param1:int) : void
      {
         this._rollText(param1);
         if(this.gui)
         {
            this.gui.update(param1);
         }
         this._checkComplete(param1);
      }
      
      private function _checkComplete(param1:int) : void
      {
         if(this.complete == null)
         {
            return;
         }
         if(this._completeDelay >= 0)
         {
            this._completeDelay -= param1;
            if(this._completeDelay <= 0)
            {
               this.complete(this);
            }
         }
      }
      
      private function _rollText(param1:int) : void
      {
         var _loc2_:Number = NaN;
         this._lastFrameAward = 0;
         if(!this.doRollText)
         {
            return;
         }
         this._tickElapsed += param1;
         if(this._tickElapsed > this._tickPeriod)
         {
            this._tickElapsed = 0;
            this._soundControllerManager.soundController.playSound("ui_break_count_down",null);
            if(this.currentValue == this.finalValue)
            {
               this.doRollText = false;
               this._completeDelay = this.rollCompleteDelay;
               return;
            }
            if(this.countUp)
            {
               _loc2_ = Math.min(this._perTick,this.finalValue - this.currentValue);
            }
            else
            {
               _loc2_ = Math.max(-this._perTick,this.finalValue - this.currentValue);
            }
            this.currentValue += _loc2_;
            this.currentValue = this.countUp ? Math.min(this.currentValue,this.finalValue) : Math.max(this.currentValue,this.finalValue);
            if(this.useDays)
            {
               this.gui.setValueToDays(this.currentValue);
            }
            else
            {
               this.gui.updateNumValue(this.currentValue);
            }
            this.tickPeriod += this._tickPeriodDelta;
            this.gui.pulseValue(this.currentValue == this.finalValue);
            this._lastFrameAward = Math.abs(_loc2_) * this.multValue;
            if(this.tickPeriod == this._tickPeriodFloor)
            {
               this._perTickTime -= param1;
               if(this._perTickTime <= 0)
               {
                  this._perTick = Math.min(this._perTick + 1,this._tickModCap);
                  this._perTickTime = PER_TICK_INTERVAL;
               }
            }
         }
      }
      
      public function set tickPeriod(param1:int) : void
      {
         this._tickPeriod = param1;
         this._tickPeriod = Math.max(this._tickPeriod,this._tickPeriodFloor);
      }
      
      public function get tickPeriod() : int
      {
         return this._tickPeriod;
      }
      
      public function get delay() : Number
      {
         return this.tickPeriod / 1000;
      }
      
      public function set delay(param1:Number) : void
      {
         this.tickPeriod = int(param1 * 1000);
      }
   }
}
