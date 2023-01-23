package lib.engine.util.air
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevBinder;
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpDeviceType;
   import engine.core.gp.GpSource;
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import flash.ui.GameInput;
   import flash.ui.GameInputControl;
   import flash.ui.GameInputDevice;
   import flash.utils.Dictionary;
   
   public class AirGpDevice extends GpDevice
   {
       
      
      private var _gid:GameInputDevice;
      
      private var controlId2Index:Dictionary;
      
      protected var lastValues:Dictionary;
      
      private var _DEV_L1_DOWN:Boolean;
      
      private var _DEV_R1_DOWN:Boolean;
      
      private var _DEV_RSTICK_WAITING:Boolean;
      
      private var _DEV_RSTICK_STAGE:int;
      
      private var _DEV_MODE:Boolean;
      
      public function AirGpDevice(param1:GpSource, param2:GpDeviceType, param3:String, param4:String, param5:ILogger)
      {
         var _loc7_:GameInputDevice = null;
         var _loc8_:GameInputControl = null;
         this.controlId2Index = new Dictionary();
         this.lastValues = new Dictionary();
         super(param1,param2,param3,param4,param5);
         var _loc6_:int = 0;
         while(_loc6_ < GameInput.numDevices)
         {
            _loc7_ = GameInput.getDeviceAt(_loc6_);
            if(_loc7_.id == param3)
            {
               this._gid = _loc7_;
               break;
            }
            _loc6_++;
         }
         if(this._gid)
         {
            _loc6_ = 0;
            while(_loc6_ < this._gid.numControls)
            {
               _loc8_ = this._gid.getControlAt(_loc6_);
               this.controlId2Index[_loc8_.id] = _loc6_;
               _loc6_++;
            }
         }
      }
      
      override public function getControlValue(param1:GpControlButton) : Number
      {
         if(this._DEV_MODE)
         {
            return 0;
         }
         return this._getControlValue(param1);
      }
      
      private function _getControlValue(param1:GpControlButton) : Number
      {
         var _loc5_:int = 0;
         var _loc6_:GameInputControl = null;
         var _loc7_:Number = NaN;
         var _loc8_:Boolean = false;
         if(!param1 || !type || !this._gid || !this._gid.enabled)
         {
            return 0;
         }
         var _loc2_:String = type.getControlId(param1);
         var _loc3_:Number = 0;
         var _loc4_:String = GpDevice.getAxisIdFromButtonAxis(_loc2_);
         if(_loc4_)
         {
            _loc3_ = GpDevice.getAxisFactorFromButtonAxis(_loc2_);
            _loc2_ = _loc4_;
         }
         if(Boolean(_loc2_) && _loc2_ in this.controlId2Index)
         {
            _loc5_ = int(this.controlId2Index[_loc2_]);
            _loc6_ = this._gid.getControlAt(_loc5_);
            _loc7_ = !!_loc6_ ? _loc6_.value : 0;
            if(_loc7_)
            {
               _loc8_ = type.isControlInverted(param1);
               if(_loc8_)
               {
                  _loc7_ = -_loc7_;
               }
            }
            if(_loc4_)
            {
               _loc7_ = Math.max(0,_loc3_ * _loc7_);
            }
            return _loc7_;
         }
         return 0;
      }
      
      override public function handleActiveChanged() : void
      {
         var _loc3_:GameInputControl = null;
         if(!this._gid)
         {
            return;
         }
         var _loc1_:Boolean = _active && GpSource.instance.enabled;
         this._gid.enabled = _loc1_;
         var _loc2_:int = 0;
         while(_loc2_ < this._gid.numControls)
         {
            _loc3_ = this._gid.getControlAt(_loc2_);
            if(_loc1_)
            {
               _loc3_.addEventListener(Event.CHANGE,this.gameInputControlChangeHandler);
               this.lastValues[_loc3_.id] = _loc3_.value;
            }
            else
            {
               _loc3_.removeEventListener(Event.CHANGE,this.gameInputControlChangeHandler);
            }
            _loc2_++;
         }
      }
      
      final private function gameInputControlChangeHandler(param1:Event) : void
      {
         var _loc2_:GameInputControl = param1.target as GameInputControl;
         this.handleGameInputControlValue(_loc2_,_loc2_.value);
      }
      
      private function set DEV_MODE(param1:Boolean) : void
      {
         this._DEV_MODE = !PlatformInput.BLOCK_GP_DEV_MODE && param1;
      }
      
      final private function handleGameInputControlValue(param1:GameInputControl, param2:Number) : void
      {
         var _loc3_:GpControlButton = null;
         var _loc6_:int = 0;
         var _loc4_:Number = Number(this.lastValues[param1.id]);
         if(allwatcher != null)
         {
            if(GpSource.GP_DEBUG)
            {
               logger.info("GP_DEBUG AirGpDevice ALLWATCHED " + param1.id + " " + param1.value);
            }
            allwatcher(this,param1.id,param1.value);
            this.checkButtonAxis(param1.id,param1.value);
            return;
         }
         _loc3_ = type.getControl(param1.id);
         var _loc5_:Boolean = type.isControlInverted(_loc3_);
         if(_loc5_)
         {
            param2 = -param2;
         }
         if(_loc3_ == GpControlButton.AXIS_LEFT_H || _loc3_ == GpControlButton.AXIS_LEFT_V || _loc3_ == GpControlButton.AXIS_RIGHT_H || _loc3_ == GpControlButton.AXIS_RIGHT_V)
         {
            if(param2 <= stick_deadzone && param2 >= -stick_deadzone)
            {
               param2 = 0;
            }
         }
         if(_loc4_ == param2)
         {
            return;
         }
         if(GpSource.GP_DEBUG)
         {
            logger.info("GP_DEBUG AirGpDevice " + param1.id + " " + param2 + " (" + _loc3_ + ") " + (_loc5_ ? "inverted" : ""));
         }
         if(_loc3_ == GpControlButton.L1)
         {
            this._DEV_L1_DOWN = param2 >= 0.75;
         }
         if(_loc3_ == GpControlButton.R1)
         {
            this._DEV_R1_DOWN = param2 >= 0.75;
         }
         if(!this._DEV_MODE && !PlatformInput.BLOCK_GP_DEV_MODE)
         {
            if(this._DEV_R1_DOWN && this._DEV_L1_DOWN)
            {
               if(!this._DEV_RSTICK_WAITING)
               {
                  this._DEV_RSTICK_WAITING = true;
                  logger.info("GP_DEBUG _DEV_RSTICK_WAITING");
               }
               if(Math.abs(param2) >= 0.75)
               {
                  _loc6_ = this._DEV_RSTICK_STAGE;
                  this._DEV_RSTICK_STAGE |= _loc3_ == GpControlButton.AXIS_RIGHT_H && param2 > 0 ? 1 : 0;
                  this._DEV_RSTICK_STAGE |= _loc3_ == GpControlButton.AXIS_RIGHT_H && param2 < 0 ? 2 : 0;
                  this._DEV_RSTICK_STAGE |= _loc3_ == GpControlButton.AXIS_RIGHT_V && param2 > 0 ? 4 : 0;
                  this._DEV_RSTICK_STAGE |= _loc3_ == GpControlButton.AXIS_RIGHT_V && param2 < 0 ? 8 : 0;
                  if(_loc6_ != this._DEV_RSTICK_STAGE)
                  {
                     logger.info("GP_DEBUG _DEV_RSTICK_STAGE 0x" + this._DEV_RSTICK_STAGE.toString(16));
                     if(this._DEV_RSTICK_STAGE == 15)
                     {
                        this._DEV_RSTICK_STAGE = 0;
                        this._DEV_MODE = true;
                        logger.info("GP_DEBUG _DEV_MODE *ENGAGED");
                        return;
                     }
                  }
               }
            }
            else
            {
               this._DEV_RSTICK_WAITING = false;
               if(this._DEV_RSTICK_STAGE)
               {
                  logger.info("GP_DEBUG _DEV_RSTICK_STAGE *RESET");
                  this._DEV_RSTICK_STAGE = 0;
               }
            }
         }
         else
         {
            this._DEV_RSTICK_STAGE = 0;
            this._DEV_RSTICK_WAITING = false;
            if(this._DEV_R1_DOWN && this._DEV_L1_DOWN)
            {
               if(GpSource.GP_DEBUG)
               {
                  logger.info("GP_DEBUG _DEV_MODE processing " + _loc3_);
               }
            }
            else
            {
               logger.info("GP_DEBUG _DEV_MODE *RESET");
               this._DEV_MODE = false;
               this._DEV_RSTICK_STAGE = 0;
            }
         }
         if(param2 > 0.9 || param2 < -0.9)
         {
            GpSource.primaryDevice = this;
            PlatformInput.touchInputGp();
         }
         if(_loc3_)
         {
            this.lastValues[param1.id] = param2;
            if(this._DEV_MODE)
            {
               if(param2 > 0.75)
               {
                  this.sendDevCommand(_loc3_,1);
               }
               else
               {
                  this.sendDevCommand(_loc3_,-1);
               }
            }
            else
            {
               source.notifyBinders(_loc3_,param2);
            }
         }
         this.checkButtonAxis(param1.id,param2);
      }
      
      final private function checkButtonAxis(param1:String, param2:Number) : void
      {
         if(param2 != 1 && param2 != -1)
         {
            return;
         }
         var _loc3_:String = GpDevice.getButtonAxis(param1,param2);
         if(_loc3_)
         {
            this.handleButtonAxis(_loc3_);
         }
      }
      
      final private function handleButtonAxis(param1:String) : void
      {
         var _loc2_:GpControlButton = null;
         _loc2_ = type.getControl(param1);
         if(GpSource.GP_DEBUG)
         {
            logger.info("GP_DEBUG AirGpDevice " + param1 + " {1} (" + _loc2_ + ")");
         }
         if(allwatcher != null)
         {
            allwatcher(this,param1,1);
            return;
         }
         if(_loc2_)
         {
            if(this._DEV_MODE)
            {
               this.sendDevCommand(_loc2_,1);
            }
            else
            {
               source.notifyBinders(_loc2_,1);
            }
         }
      }
      
      private function getDpadState(param1:GpControlButton, param2:GpControlButton) : GpControlButton
      {
         if(param2)
         {
            return param2;
         }
         if(this._getControlValue(param1) > 0.75)
         {
            return param1;
         }
         return null;
      }
      
      private function sendDevCommand(param1:GpControlButton, param2:int) : void
      {
         var _loc3_:GpControlButton = null;
         _loc3_ = this.getDpadState(GpControlButton.D_U,_loc3_);
         _loc3_ = this.getDpadState(GpControlButton.D_D,_loc3_);
         _loc3_ = this.getDpadState(GpControlButton.D_L,_loc3_);
         _loc3_ = this.getDpadState(GpControlButton.D_R,_loc3_);
         GpDevBinder.instance.notifyBind(_loc3_,param1,param2);
      }
   }
}
