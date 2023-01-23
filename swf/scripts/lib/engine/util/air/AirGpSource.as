package lib.engine.util.air
{
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpDeviceType;
   import engine.core.gp.GpSource;
   import engine.core.gp.KeyboardGpDevice;
   import engine.core.logging.ILogger;
   import flash.events.GameInputEvent;
   import flash.ui.GameInput;
   import flash.ui.GameInputDevice;
   import flash.utils.Dictionary;
   
   public class AirGpSource extends GpSource
   {
       
      
      private var gi:GameInput;
      
      private var devices:Vector.<GameInputDevice>;
      
      private var initialized:Boolean;
      
      public function AirGpSource(param1:ILogger)
      {
         this.devices = new Vector.<GameInputDevice>();
         super(param1);
         param1.info("AirGpSource GameInput.isSupported=" + GameInput.isSupported);
         if(!GameInput.isSupported)
         {
            return;
         }
         this.gi = new GameInput();
      }
      
      override public function start(param1:Object, param2:Object) : void
      {
         super.start(param1,param2);
         this.initialized = true;
         if(!this.gi)
         {
            return;
         }
         GpDeviceType.init(param1,param2,logger);
         this.gi.addEventListener(GameInputEvent.DEVICE_ADDED,this.deviceAddedHandler);
         this.gi.addEventListener(GameInputEvent.DEVICE_REMOVED,this.deviceRemovedHandler);
         this.gi.addEventListener(GameInputEvent.DEVICE_UNUSABLE,this.deviceUnusableHandler);
         this.updateDevices(true);
      }
      
      private function deviceAddedHandler(param1:GameInputEvent) : void
      {
         logger.info("AirGpSource GameInput added [" + this.debugStringDevice(param1.device) + "]");
         this.updateDevices(false);
      }
      
      private function deviceRemovedHandler(param1:GameInputEvent) : void
      {
         logger.info("AirGpSource GameInput removed [" + this.debugStringDevice(param1.device) + "]");
         this.updateDevices(false);
      }
      
      private function deviceUnusableHandler(param1:GameInputEvent) : void
      {
         logger.info("AirGpSource GameInput unusable [" + this.debugStringDevice(param1.device) + "]");
         this.updateDevices(false);
      }
      
      public function updateDevices(param1:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:GpDevice = null;
         var _loc5_:GameInputDevice = null;
         var _loc6_:GpDeviceType = null;
         if(!this.initialized)
         {
            return;
         }
         var _loc2_:Dictionary = new Dictionary();
         _loc3_ = 0;
         while(_loc3_ < numDevices)
         {
            _loc4_ = getDeviceByIndex(_loc3_);
            _loc2_[_loc4_] = _loc4_;
            _loc3_++;
         }
         logger.info("AirGpSource GameInput.numDevices=" + GameInput.numDevices);
         _loc3_ = 0;
         while(_loc3_ < GameInput.numDevices)
         {
            _loc5_ = GameInput.getDeviceAt(_loc3_);
            if(_loc5_ != null)
            {
               logger.info("AirGpSource GameInput device " + _loc3_ + " " + this.debugStringDevice(_loc5_));
               _loc6_ = GpDeviceType.findTypeForDevice(_loc5_);
               logger.info("AirGpSource GameInput device " + _loc3_ + " identified as " + _loc6_);
               _loc4_ = addDevice(_loc3_,_loc6_,_loc5_.id,_loc5_.name + " (" + _loc5_.numControls + ")",!param1);
               delete _loc2_[_loc4_];
            }
            else
            {
               logger.info("AirGpSource GameInput device " + _loc3_ + " is null!");
            }
            _loc3_++;
         }
         if(GpSource.GP_KEYBOARD)
         {
            _loc4_ = addDevice(_loc3_,GpDeviceType.addKeyboardType(),"keyboard","keyboard",false);
            delete _loc2_[_loc4_];
         }
         for each(_loc4_ in _loc2_)
         {
            removeDevice(_loc4_);
         }
         if(numDevices == 0 && !FORCE_GP_ENABLE)
         {
            primaryDevice = null;
         }
      }
      
      override protected function handleCreateDevice(param1:GpDeviceType, param2:String, param3:String) : GpDevice
      {
         if(param1.name == "keyboard")
         {
            return new KeyboardGpDevice(this,param1,param2,param3,logger);
         }
         return new AirGpDevice(this,param1,param2,param3,logger);
      }
      
      public function debugStringDevice(param1:GameInputDevice) : String
      {
         if(param1)
         {
            return "id=" + param1.id + ", name=[" + param1.name + "], numControls=" + param1.numControls + ", enabled=" + param1.enabled;
         }
         return "(null device)";
      }
   }
}
