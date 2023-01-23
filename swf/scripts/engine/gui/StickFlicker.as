package engine.gui
{
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpSource;
   import engine.core.logging.ILogger;
   import engine.gui.page.PageManagerAdapter;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class StickFlicker
   {
      
      private static const DPAD_VALUE_THRESHOLD:Number = 0.85;
       
      
      private var _stickResetRequired:Boolean;
      
      private var last_stick_angle:int = 0;
      
      private var valid_stick_angle:Boolean;
      
      private var _autoUpdate:Boolean;
      
      private var gpbindid:int = 0;
      
      private var _flickCallback:Function;
      
      private var _enabled:Boolean;
      
      private var _withPad:Boolean;
      
      private var name:String;
      
      private var logger:ILogger;
      
      private var threshold_sq:Number = 0.5;
      
      private var sticking:Boolean;
      
      private var count:int = 0;
      
      private var repeatDelayElapsed:int = 0;
      
      private var repeatDelay:int = 200;
      
      private var timer:Timer;
      
      private var lastUpdateTime:int = 0;
      
      public function StickFlicker(param1:Function, param2:Boolean, param3:Boolean, param4:String, param5:ILogger)
      {
         super();
         GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         this._flickCallback = param1;
         this._autoUpdate = param2;
         this._withPad = param3;
         this.name = param4;
         this.logger = param5;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(this._enabled == param1)
         {
            return;
         }
         this._enabled = param1;
         if(this._enabled)
         {
            if(this._autoUpdate)
            {
               if(!this.timer)
               {
                  this.timer = new Timer(0);
                  this.timer.addEventListener(TimerEvent.TIMER,this.timerHandler);
               }
               this.timer.start();
            }
            this.gpbindid = GpBinder.gpbinder.lastCmdId;
         }
         else if(this.timer)
         {
            this.timer.reset();
            this.lastUpdateTime = 0;
         }
         this.resetIfNecessary();
      }
      
      public function cleanup() : void
      {
         this.enabled = false;
         GpSource.dispatcher.removeEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         this._flickCallback = null;
         if(this.timer)
         {
            this.timer.removeEventListener(TimerEvent.TIMER,this.timerHandler);
            this.timer = null;
         }
      }
      
      private function primaryDeviceHandler(param1:Event) : void
      {
      }
      
      public function update(param1:int) : void
      {
         var _loc9_:int = 0;
         if(!GpSource.instance.enabled)
         {
            return;
         }
         var _loc2_:int = GpBinder.gpbinder.topLayer;
         var _loc3_:* = _loc2_ <= this.gpbindid;
         if(!this._enabled || !_loc3_ || PageManagerAdapter.IS_LOADING || GpBinder.DISALLOW_INPUT_DURING_LOAD)
         {
            return;
         }
         var _loc4_:GpDevice = GpSource.primaryDevice;
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:Number = _loc4_.getControlValue(GpControlButton.AXIS_LEFT_H);
         var _loc6_:Number = _loc4_.getControlValue(GpControlButton.AXIS_LEFT_V);
         if(this._withPad)
         {
            if(_loc4_.getControlValue(GpControlButton.D_L) > DPAD_VALUE_THRESHOLD)
            {
               _loc5_ = -1;
            }
            else if(_loc4_.getControlValue(GpControlButton.D_R) > DPAD_VALUE_THRESHOLD)
            {
               _loc5_ = 1;
            }
            if(_loc4_.getControlValue(GpControlButton.D_U) > DPAD_VALUE_THRESHOLD)
            {
               _loc6_ = -1;
            }
            else if(_loc4_.getControlValue(GpControlButton.D_D) > DPAD_VALUE_THRESHOLD)
            {
               _loc6_ = 1;
            }
         }
         if(_loc5_ <= _loc4_.stick_deadzone && _loc5_ >= -_loc4_.stick_deadzone && (_loc6_ <= _loc4_.stick_deadzone && _loc6_ >= -_loc4_.stick_deadzone))
         {
            if(this._stickResetRequired)
            {
               this._stickResetRequired = false;
            }
            this.sticking = false;
            return;
         }
         if(this._stickResetRequired)
         {
            return;
         }
         var _loc7_:Number = Math.min(1,_loc5_ * _loc5_ + _loc6_ * _loc6_);
         if(_loc7_ <= this.threshold_sq)
         {
            if(!this.sticking)
            {
               return;
            }
         }
         if(!this.sticking)
         {
            this.sticking = true;
            this.count = 0;
            this.repeatDelayElapsed = 0;
         }
         var _loc8_:int = Math.atan2(_loc6_,_loc5_) * 180 / Math.PI;
         this.last_stick_angle = _loc8_;
         if(!this.count)
         {
            ++this.count;
         }
         else
         {
            _loc9_ = this.repeatDelay + this.repeatDelay * (1 - _loc7_);
            if(this.count == 1)
            {
               _loc9_ *= 2;
            }
            this.repeatDelayElapsed += param1;
            if(this.repeatDelayElapsed < _loc9_)
            {
               return;
            }
            ++this.count;
            this.repeatDelayElapsed = 0;
         }
         if(this._flickCallback != null)
         {
            this._flickCallback(this,this.last_stick_angle);
         }
      }
      
      private function timerHandler(param1:TimerEvent) : void
      {
         var _loc2_:int = getTimer();
         var _loc3_:int = _loc2_ - this.lastUpdateTime;
         this.lastUpdateTime = _loc2_;
         if(this.lastUpdateTime > 0)
         {
            this.update(_loc3_);
         }
      }
      
      public function resetIfNecessary() : void
      {
         if(!this._stickResetRequired)
         {
            this.reset();
         }
      }
      
      private function reset() : void
      {
         if(this._autoUpdate && Boolean(this.timer))
         {
            this.timer.reset();
            this.timer.start();
         }
         this.sticking = false;
         this.count = 0;
         this.repeatDelayElapsed = 0;
         this._stickResetRequired = true;
      }
      
      public function get autoUpdate() : Boolean
      {
         return this._autoUpdate;
      }
   }
}
