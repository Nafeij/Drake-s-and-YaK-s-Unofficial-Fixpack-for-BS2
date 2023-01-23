package com.junkbyte.console.vos
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.console_internal;
   
   public class GraphFPSGroup extends GraphGroup
   {
      
      public static const NAME:String = "consoleFPSGraph";
       
      
      public var maxLag:uint = 60;
      
      private var _console:Console;
      
      private var _historyLength:uint;
      
      private var _history:Array;
      
      private var _historyIndex:uint;
      
      private var _historyTotal:Number = 0;
      
      public function GraphFPSGroup(param1:Console, param2:uint = 5)
      {
         this._history = new Array();
         this._console = param1;
         this._historyLength = param2;
         super(NAME);
         var _loc3_:uint = 0;
         while(_loc3_ < param2)
         {
            this._history.push(0);
            _loc3_++;
         }
         rect.x = 170;
         rect.y = 15;
         alignRight = true;
         var _loc4_:GraphInterest = new GraphInterest("fps");
         _loc4_.col = 16724787;
         interests.push(_loc4_);
         _updateArgs.length = 1;
         freq = 200;
         fixedMin = 0;
         numberDisplayPrecision = 2;
      }
      
      override public function tick(param1:uint) : void
      {
         var _loc3_:uint = 0;
         if(param1 == 0)
         {
            return;
         }
         var _loc2_:Number = 1000 / param1;
         if(this._console.stage)
         {
            fixedMax = this._console.stage.frameRate;
            _loc3_ = fixedMax / _loc2_ / this._historyLength;
            if(_loc3_ > this.maxLag)
            {
               _loc3_ = this.maxLag;
            }
         }
         if(_loc3_ == 0)
         {
            _loc3_ = 1;
         }
         while(_loc3_ > 0)
         {
            this.dispatchFPS(_loc2_);
            _loc3_--;
         }
      }
      
      private function dispatchFPS(param1:Number) : void
      {
         this._historyTotal -= this._history[this._historyIndex];
         this._historyTotal += param1;
         this._history[this._historyIndex] = param1;
         ++this._historyIndex;
         if(this._historyIndex >= this._historyLength)
         {
            this._historyIndex = 0;
         }
         param1 = this._historyTotal / this._historyLength;
         if(param1 > fixedMax)
         {
            param1 = fixedMax;
         }
         _updateArgs[0] = Math.round(param1);
         console_internal::applyUpdateDispather(_updateArgs);
      }
   }
}
