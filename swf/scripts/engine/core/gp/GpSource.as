package engine.core.gp
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.logging.ILogger;
   import engine.core.pref.PrefBag;
   import engine.gui.GuiGp;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.system.Capabilities;
   import flash.utils.Dictionary;
   
   public class GpSource implements IGpSource
   {
      
      public static var FORCE_GP_ENABLE:Boolean = false;
      
      public static var GP_ENABLED:Boolean = false;
      
      public static var GP_DEBUG:Boolean = false;
      
      public static var GP_KEYBOARD:Boolean = false;
      
      public static const EVENT_PRIMARY_DEVICE:String = "GpSource.EVENT_PRIMARY_DEVICE";
      
      public static const EVENT_STICK_SENSITIVITY:String = "GpSource.EVENT_STICK_SENSITIVITY";
      
      public static const EVENT_STICK_INVERT:String = "GpSource.EVENT_STICK_INVERT";
      
      private static const PREF_STICK_INVERT_RIGHT:String = "PREF_STICK_INVERT_RIGHT";
      
      private static const PREF_STICK_INVERT_LEFT:String = "PREF_STICK_INVERT_LEFT";
      
      private static const PREF_STICK_SENSITIVITY:String = "PREF_STICK_SENSITIVITY";
      
      public static const dispatcher:EventDispatcher = new EventDispatcher();
      
      private static var _primaryDevice:GpDevice;
      
      public static var instance:GpSource;
      
      private static var _invertLeftStick:Boolean;
      
      private static var _invertRightStick:Boolean;
      
      private static var _stickSensitivity:int = 100;
      
      private static var _prefs:PrefBag;
      
      public static var stickSensitivityFactor:Number = 1;
      
      private static const STICK_SENSITIVITY_MIN:Number = 25;
      
      private static const STICK_SENSITIVITY_MAX:Number = 300;
      
      public static const STICK_SENSITIVITY_HIGH:Number = 150;
      
      public static const STICK_SENSITIVITY_MEDIUM:Number = 100;
      
      public static const STICK_SENSITIVITY_LOW:Number = 50;
       
      
      private var binders:Vector.<GpBinder>;
      
      private var devicesById:Dictionary;
      
      private var devices:Vector.<GpDevice>;
      
      protected var logger:ILogger;
      
      public var _enabled:Boolean = true;
      
      public function GpSource(param1:ILogger)
      {
         this.binders = new Vector.<GpBinder>();
         this.devicesById = new Dictionary();
         this.devices = new Vector.<GpDevice>();
         super();
         instance = this;
         this.logger = param1;
         GpDeviceType.interpretOs(Capabilities.os);
      }
      
      public static function set prefs(param1:PrefBag) : void
      {
         _prefs = param1;
         loadFromPrefs();
      }
      
      public static function get primaryDeviceType() : GpDeviceType
      {
         return !!_primaryDevice ? _primaryDevice.type : null;
      }
      
      public static function get primaryDevice() : GpDevice
      {
         return _primaryDevice;
      }
      
      public static function set primaryDevice(param1:GpDevice) : void
      {
         if(_primaryDevice == param1)
         {
            return;
         }
         _primaryDevice = param1;
         if(Boolean(instance) && Boolean(instance.logger))
         {
            instance.logger.info("GpSource primaryDevice " + _primaryDevice);
         }
         GuiGp.handlePrimaryDeviceChanged();
         dispatcher.dispatchEvent(new Event(EVENT_PRIMARY_DEVICE));
         PlatformInput.touchInputGp();
      }
      
      public static function get invertLeftStick() : Boolean
      {
         return _invertLeftStick;
      }
      
      public static function set invertLeftStick(param1:Boolean) : void
      {
         if(_invertLeftStick == param1)
         {
            return;
         }
         _invertLeftStick = param1;
         if(_prefs)
         {
            _prefs.setPref(PREF_STICK_INVERT_LEFT,param1);
         }
         dispatcher.dispatchEvent(new Event(EVENT_STICK_INVERT));
      }
      
      public static function get invertRightStick() : Boolean
      {
         return _invertRightStick;
      }
      
      public static function set invertRightStick(param1:Boolean) : void
      {
         if(_invertRightStick == param1)
         {
            return;
         }
         _invertRightStick = param1;
         if(_prefs)
         {
            _prefs.setPref(PREF_STICK_INVERT_RIGHT,param1);
         }
         dispatcher.dispatchEvent(new Event(EVENT_STICK_INVERT));
      }
      
      public static function get stickSensitivity() : int
      {
         return _stickSensitivity;
      }
      
      public static function set stickSensitivity(param1:int) : void
      {
         param1 = Math.max(STICK_SENSITIVITY_MIN,param1);
         param1 = Math.min(STICK_SENSITIVITY_MAX,param1);
         if(_stickSensitivity == param1)
         {
            return;
         }
         _stickSensitivity = param1;
         stickSensitivityFactor = param1 / 100;
         if(_prefs)
         {
            _prefs.setPref(PREF_STICK_SENSITIVITY,param1);
         }
         dispatcher.dispatchEvent(new Event(EVENT_STICK_SENSITIVITY));
      }
      
      private static function loadFromPrefs() : void
      {
         if(!_prefs)
         {
            return;
         }
         invertRightStick = _prefs.getPref(PREF_STICK_INVERT_RIGHT);
         invertLeftStick = _prefs.getPref(PREF_STICK_INVERT_LEFT);
         var _loc1_:* = _prefs.getPref(PREF_STICK_SENSITIVITY);
         if(_loc1_)
         {
            stickSensitivity = _loc1_;
         }
      }
      
      public function get numDevices() : int
      {
         return this.devices.length;
      }
      
      public function getDeviceByIndex(param1:int) : GpDevice
      {
         return this.devices[param1];
      }
      
      public function start(param1:Object, param2:Object) : void
      {
      }
      
      final public function addBinder(param1:GpBinder) : void
      {
         this.binders.push(param1);
      }
      
      final protected function removeDevice(param1:GpDevice) : void
      {
         delete this.devicesById[param1.id];
         var _loc2_:int = this.devices.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.devices.splice(_loc2_,1);
         }
      }
      
      final protected function addDevice(param1:int, param2:GpDeviceType, param3:String, param4:String, param5:Boolean) : GpDevice
      {
         this.logger.info("GpSource.addDevice " + param1 + " " + param2 + " " + param3);
         var _loc6_:GpDevice = this.devicesById[param3];
         if(_loc6_)
         {
            this.logger.info("GpSource.addDevice found pre-existing " + _loc6_);
         }
         if(!_loc6_)
         {
            _loc6_ = this.handleCreateDevice(param2,param3,param4);
            if(_loc6_)
            {
               _loc6_.active = true;
               this.devicesById[param3] = _loc6_;
            }
         }
         if(_loc6_)
         {
            while(this.devices.length < param1)
            {
               this.devices.push(null);
            }
            this.devices[param1] = _loc6_;
            if(!_primaryDevice)
            {
               if(PlatformInput.isGp || param5)
               {
                  primaryDevice = _loc6_;
               }
            }
         }
         return _loc6_;
      }
      
      final public function getDevice(param1:String) : GpDevice
      {
         return this.devicesById[param1];
      }
      
      protected function handleCreateDevice(param1:GpDeviceType, param2:String, param3:String) : GpDevice
      {
         return null;
      }
      
      final public function removeBinder(param1:GpBinder) : void
      {
         var _loc2_:int = this.binders.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.binders.splice(_loc2_,1);
         }
      }
      
      final public function notifyBinders(param1:GpControlButton, param2:Number) : void
      {
         var _loc3_:GpBinder = null;
         for each(_loc3_ in this.binders)
         {
            _loc3_.handleGpControl(param1,param2);
         }
      }
      
      public function set enabled(param1:Boolean) : void
      {
         var _loc2_:GpDevice = null;
         this._enabled = param1;
         for each(_loc2_ in this.devices)
         {
            _loc2_.handleActiveChanged();
         }
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
   }
}
