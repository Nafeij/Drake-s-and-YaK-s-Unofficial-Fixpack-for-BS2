package engine.core.gp
{
   import engine.core.logging.ILogger;
   import flash.utils.Dictionary;
   
   public class GpDevice
   {
      
      public static var allwatcher:Function;
      
      private static var _opposites:Dictionary;
      
      private static var _buttonAxis2Axis:Dictionary = new Dictionary();
      
      private static var _buttonAxis2AxisFactor:Dictionary = new Dictionary();
      
      private static var _buttonAxisPos:Dictionary = new Dictionary();
      
      private static var _buttonAxisNeg:Dictionary = new Dictionary();
       
      
      protected var _active:Boolean;
      
      public var type:GpDeviceType;
      
      public var id:String;
      
      public var desc:String;
      
      public var source:GpSource;
      
      public var stick_deadzone:Number = 0.15;
      
      public var logger:ILogger;
      
      public function GpDevice(param1:GpSource, param2:GpDeviceType, param3:String, param4:String, param5:ILogger)
      {
         super();
         this.logger = param5;
         this.type = param2;
         this.id = param3;
         this.source = param1;
         this.desc = param4;
      }
      
      public static function isButtonAxis(param1:String) : Boolean
      {
         var _loc2_:String = getOpposite(param1);
         return _loc2_ != null && Boolean(_loc2_);
      }
      
      public static function isOpposite(param1:String, param2:String) : Boolean
      {
         return getOpposite(param1) == param2;
      }
      
      private static function checkCache() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         var _loc3_:* = null;
         var _loc4_:* = null;
         if(!_opposites)
         {
            _opposites = new Dictionary();
            _loc1_ = 0;
            while(_loc1_ <= 40)
            {
               _loc2_ = "AXIS_" + _loc1_;
               _loc3_ = "BUTTON_" + _loc2_ + "_POS";
               _loc4_ = "BUTTON_" + _loc2_ + "_NEG";
               _buttonAxisPos[_loc2_] = _loc3_;
               _buttonAxisNeg[_loc2_] = _loc4_;
               _opposites[_loc3_] = _loc4_;
               _opposites[_loc4_] = _loc3_;
               _buttonAxis2Axis[_loc4_] = _loc2_;
               _buttonAxis2Axis[_loc3_] = _loc2_;
               _buttonAxis2AxisFactor[_loc4_] = -1;
               _buttonAxis2AxisFactor[_loc3_] = 1;
               _loc1_++;
            }
         }
      }
      
      public static function getAxisFactorFromButtonAxis(param1:String) : Number
      {
         checkCache();
         return _buttonAxis2AxisFactor[param1];
      }
      
      public static function getOpposite(param1:String) : String
      {
         checkCache();
         return _opposites[param1];
      }
      
      public static function getButtonAxis(param1:String, param2:Number) : String
      {
         checkCache();
         if(param2 == 1)
         {
            return _buttonAxisPos[param1];
         }
         if(param2 == -1)
         {
            return _buttonAxisNeg[param1];
         }
         return null;
      }
      
      public static function getAxisIdFromButtonAxis(param1:String) : String
      {
         checkCache();
         return _buttonAxis2Axis[param1];
      }
      
      public function toString() : String
      {
         return "type=" + this.type + ", id=" + this.id;
      }
      
      final public function set active(param1:Boolean) : void
      {
         if(this._active != param1)
         {
            this._active = param1;
            this.handleActiveChanged();
         }
      }
      
      final public function get active() : Boolean
      {
         return this._active;
      }
      
      public function handleActiveChanged() : void
      {
      }
      
      public function getControlValue(param1:GpControlButton) : Number
      {
         return 0;
      }
      
      public function getStickValue(param1:GpControlButton) : Number
      {
         var _loc2_:Number = this.getControlValue(param1);
         if(Math.abs(_loc2_) < this.stick_deadzone)
         {
            return 0;
         }
         return _loc2_;
      }
   }
}
