package engine.core.gp
{
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import flash.errors.IllegalOperationError;
   import flash.ui.GameInputDevice;
   import flash.utils.Dictionary;
   
   public class GpDeviceType
   {
      
      public static var typesByFeatures:Dictionary = new Dictionary();
      
      public static var typesByName:Dictionary = new Dictionary();
      
      public static var visualCategories:Vector.<String> = new Vector.<String>();
      
      public static var DEFAULT_VISUAL_CATEGORY:String = "ps4";
      
      private static var keyboardType:GpDeviceType;
      
      private static var initialized:Boolean;
      
      public static var error:Boolean;
      
      public static var CURRENT_OS:String;
      
      private static var featuresSep:String = ":::";
      
      private static var VERSION:int = 2;
       
      
      private var mapping:MappingInfo;
      
      private var cachedMapping:MappingInfo;
      
      public var name:String;
      
      public var visualCategory:String;
      
      public var unknown:Boolean;
      
      public var userCfg:Boolean;
      
      public var isKeyboard:Boolean;
      
      private var _localeOverlays:Dictionary;
      
      public function GpDeviceType(param1:String, param2:String)
      {
         this.mapping = new MappingInfo();
         super();
         this.name = param1;
         this.visualCategory = param2;
         typesByName[param1] = this;
         this.isKeyboard = param1 == "keyboard";
         this.unknown = this.isKeyboard;
      }
      
      public static function interpretOs(param1:String) : void
      {
         param1 = param1.toLowerCase();
         if(param1.indexOf("windows") >= 0)
         {
            CURRENT_OS = "win";
         }
         else if(param1.indexOf("mac") >= 0)
         {
            CURRENT_OS = "mac";
         }
         else if(param1.indexOf("linux") >= 0)
         {
            CURRENT_OS = "linux";
         }
         else if(param1.indexOf("orbis") >= 0)
         {
            CURRENT_OS = "ps4";
         }
         else if(param1.indexOf("durango") >= 0)
         {
            CURRENT_OS = "durango";
         }
         else
         {
            CURRENT_OS = "unknown";
         }
      }
      
      public static function addKeyboardType() : GpDeviceType
      {
         return addTypeByName("keyboard","ps4");
      }
      
      public static function add(param1:String, param2:String, param3:String, param4:int, param5:String) : void
      {
         var _loc6_:GpDeviceType = addTypeByName(param1,param5);
         var _loc7_:String = getFeaturesString(param2,param3,param4);
         typesByFeatures[_loc7_] = _loc6_;
      }
      
      public static function addTypeByName(param1:String, param2:String) : GpDeviceType
      {
         var _loc3_:GpDeviceType = typesByName[param1];
         if(!_loc3_)
         {
            _loc3_ = new GpDeviceType(param1,param2);
         }
         return _loc3_;
      }
      
      public static function findTypeForDevice(param1:GameInputDevice) : GpDeviceType
      {
         if(!initialized)
         {
            throw new IllegalOperationError("GpDeviceType is not initialized");
         }
         var _loc2_:String = getFeaturesString(CURRENT_OS,param1.name,param1.numControls);
         var _loc3_:GpDeviceType = typesByFeatures[_loc2_];
         if(_loc3_)
         {
            return _loc3_;
         }
         _loc3_ = addTypeByName(param1.name,DEFAULT_VISUAL_CATEGORY);
         _loc3_.addDeviceFeatures(CURRENT_OS,param1.name,param1.numControls,null);
         _loc3_.unknown = true;
         return _loc3_;
      }
      
      private static function getFeaturesString(param1:String, param2:String, param3:int) : String
      {
         return param1 + featuresSep + param2 + featuresSep + param3;
      }
      
      public static function init(param1:Object, param2:Object, param3:ILogger) : void
      {
         if(initialized)
         {
            return;
         }
         initialized = true;
         if(param1)
         {
            fromJson(param1,param3,false);
         }
         if(param2)
         {
            fromJson(param2,param3,true);
         }
      }
      
      public static function toJsonUserCfgs() : Object
      {
         var _loc2_:String = null;
         var _loc3_:GpDeviceType = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc8_:String = null;
         var _loc9_:GpDeviceType = null;
         var _loc10_:Array = null;
         var _loc1_:Object = {"version":VERSION};
         for(_loc2_ in typesByName)
         {
            _loc3_ = typesByName[_loc2_];
            if(_loc3_.userCfg)
            {
               _loc4_ = _loc3_.visualCategory;
               _loc5_ = _loc1_[_loc4_];
               if(!_loc5_)
               {
                  _loc5_ = {};
                  _loc1_[_loc4_] = _loc5_;
               }
               _loc6_ = {};
               _loc5_[_loc3_.name] = _loc6_;
               _loc3_.mapping.toJson(_loc6_);
               _loc7_ = [];
               _loc6_["devices"] = _loc7_;
               for(_loc8_ in typesByFeatures)
               {
                  _loc9_ = typesByFeatures[_loc8_];
                  if(_loc9_ == _loc3_)
                  {
                     _loc10_ = _loc8_.split(featuresSep);
                     if(Boolean(_loc10_) && _loc10_.length == 3)
                     {
                        _loc7_.push({
                           "name":_loc10_[1],
                           "controls":int(_loc10_[2]),
                           "os":_loc10_[0]
                        });
                     }
                  }
               }
               if(_loc3_.isKeyboard)
               {
                  _loc6_["keyboard"] = true;
               }
            }
         }
         return _loc1_;
      }
      
      private static function fromJson(param1:Object, param2:ILogger, param3:Boolean) : void
      {
         var devfs:Array;
         var vis:String = null;
         var name:String = null;
         var mk:String = null;
         var mv:String = null;
         var d_name:String = null;
         var jod:Object = null;
         var j_vis:Object = null;
         var type:GpDeviceType = null;
         var j_type:Object = null;
         var map:* = undefined;
         var inverts:* = undefined;
         var devices:* = undefined;
         var cb:GpControlButton = null;
         var jinvert_cbs:String = null;
         var jdevice:Object = null;
         var j:Object = param1;
         var logger:ILogger = param2;
         var userCfg:Boolean = param3;
         var version:int = int(j.version);
         if(userCfg && version != VERSION)
         {
            logger.i("GP  ","GpDeviceType skipping version [" + version + "]");
            return;
         }
         devfs = [];
         try
         {
            for(vis in j)
            {
               if(vis != "version")
               {
                  visualCategories.push(vis);
                  name = undefined;
                  mk = undefined;
                  mv = undefined;
                  d_name = undefined;
                  j_vis = j[vis];
                  for(name in j_vis)
                  {
                     type = addTypeByName(name,vis);
                     type.userCfg = userCfg;
                     j_type = j_vis[name];
                     type.isKeyboard = j_type["keyboard"];
                     map = j_type.map;
                     if(map != undefined)
                     {
                        for(mk in map)
                        {
                           mv = String(map[mk]);
                           if(mv)
                           {
                              cb = Enum.parse(GpControlButton,mv) as GpControlButton;
                              cb = cb.swap;
                              type.addControl(mk,cb);
                           }
                           mv = undefined;
                        }
                        mk = undefined;
                     }
                     inverts = j_type.inverts;
                     if(inverts != undefined)
                     {
                        for each(jinvert_cbs in inverts)
                        {
                           cb = Enum.parse(GpControlButton,jinvert_cbs) as GpControlButton;
                           type.setInverted(cb,true);
                        }
                     }
                     devices = j_type.devices;
                     if(devices != undefined)
                     {
                        for each(jdevice in devices)
                        {
                           devfs.push({
                              "type":type,
                              "jdevice":jdevice
                           });
                        }
                     }
                  }
               }
            }
            devfs.sortOn("controls");
            devfs.sortOn("d_name");
            devfs.sortOn("os");
            for each(jod in devfs)
            {
               type = jod.type;
               jdevice = jod.jdevice;
               type.addDeviceFeatures(jdevice.os,jdevice.name,jdevice.controls,logger);
            }
         }
         catch(e:Error)
         {
            error = true;
            logger.error("Failed to load gp controls JSON:\n" + "vis    [" + vis + "]\n" + "name   [" + name + "]\n" + "mk     [" + mk + "]\n" + "mv     [" + mv + "]\n" + "d_name [" + d_name + "]\n" + e.getStackTrace());
         }
      }
      
      public function getLocaleOverlay(param1:LocaleCategory) : LocaleCategory
      {
         if(!this._localeOverlays)
         {
            this._localeOverlays = new Dictionary();
            this._localeOverlays[LocaleCategory.GUI] = LocaleCategory.GUI_GP;
            this._localeOverlays[LocaleCategory.TUTORIAL] = LocaleCategory.TUTORIAL_GP;
         }
         return this._localeOverlays[param1];
      }
      
      public function toString() : String
      {
         return this.name;
      }
      
      public function resetMapping() : void
      {
         this.mapping = new MappingInfo();
      }
      
      public function cacheMapping() : void
      {
         this.cachedMapping = this.mapping.clone();
      }
      
      public function uncacheMapping() : void
      {
         if(this.cachedMapping)
         {
            this.mapping = this.cachedMapping.clone();
         }
      }
      
      public function addControl(param1:String, param2:GpControlButton) : void
      {
         this.mapping.controlId2Button[param1] = param2;
         var _loc3_:Vector.<String> = this.mapping.button2ControlIds[param2];
         if(!_loc3_)
         {
            _loc3_ = new Vector.<String>();
            this.mapping.button2ControlIds[param2] = _loc3_;
         }
         if(_loc3_.indexOf(param1) < 0)
         {
            _loc3_.push(param1);
         }
      }
      
      public function setInverted(param1:GpControlButton, param2:Boolean = false) : void
      {
         if(param2)
         {
            this.mapping.button2Inverted[param1] = param2;
         }
         else
         {
            delete this.mapping.button2Inverted[param1];
         }
      }
      
      public function isControlInverted(param1:GpControlButton) : Boolean
      {
         return this.mapping.button2Inverted[param1];
      }
      
      public function getControl(param1:String) : GpControlButton
      {
         return this.mapping.controlId2Button[param1];
      }
      
      public function getControlIds(param1:GpControlButton) : Vector.<String>
      {
         return this.mapping.button2ControlIds[param1];
      }
      
      public function getControlId(param1:GpControlButton) : String
      {
         var _loc2_:Vector.<String> = this.mapping.button2ControlIds[param1];
         if(Boolean(_loc2_) && Boolean(_loc2_.length))
         {
            return _loc2_[0];
         }
         return null;
      }
      
      public function hasControlId(param1:GpControlButton, param2:String) : Boolean
      {
         var _loc3_:Vector.<String> = this.mapping.button2ControlIds[param1];
         if(_loc3_)
         {
            return _loc3_.indexOf(param2) >= 0;
         }
         return false;
      }
      
      public function addDeviceFeatures(param1:String, param2:String, param3:int, param4:ILogger) : Boolean
      {
         var _loc5_:Boolean = false;
         var _loc6_:String = getFeaturesString(param1,param2,param3);
         if(typesByFeatures[_loc6_] != null)
         {
            _loc5_ = true;
         }
         if(param4)
         {
            if(_loc5_)
            {
               param4.i("GP  ","GpDeviceType OVERRIDE [" + _loc6_ + "] with " + this);
            }
            else if(param4.isDebugEnabled)
            {
               param4.debug("GpDeviceType ADD      [" + _loc6_ + "] with " + this);
            }
         }
         typesByFeatures[_loc6_] = this;
         return _loc5_;
      }
   }
}

import engine.core.gp.GpControlButton;
import flash.utils.Dictionary;

class MappingInfo
{
    
   
   public var controlId2Button:Dictionary;
   
   public var button2ControlIds:Dictionary;
   
   public var button2Inverted:Dictionary;
   
   public function MappingInfo()
   {
      this.controlId2Button = new Dictionary();
      this.button2ControlIds = new Dictionary();
      this.button2Inverted = new Dictionary();
      super();
   }
   
   public function clone() : MappingInfo
   {
      var _loc1_:MappingInfo = new MappingInfo();
      this.cloneDict(_loc1_.controlId2Button,this.controlId2Button);
      this.cloneDict(_loc1_.button2ControlIds,this.button2ControlIds);
      this.cloneDict(_loc1_.button2Inverted,this.button2Inverted);
      return _loc1_;
   }
   
   private function cloneDict(param1:Dictionary, param2:Dictionary) : Dictionary
   {
      var _loc3_:Object = null;
      var _loc4_:Object = null;
      var _loc5_:Vector.<String> = null;
      for(_loc3_ in param2)
      {
         _loc4_ = param2[_loc3_];
         _loc5_ = _loc4_ as Vector.<String>;
         if(_loc5_)
         {
            _loc4_ = _loc5_.slice();
         }
         param1[_loc3_] = _loc4_;
      }
      return param1;
   }
   
   public function toJson(param1:Object) : Object
   {
      var _loc3_:Object = null;
      var _loc4_:Object = null;
      var _loc5_:Object = null;
      var _loc6_:GpControlButton = null;
      var _loc7_:GpControlButton = null;
      var _loc8_:Vector.<String> = null;
      var _loc9_:String = null;
      var _loc2_:Array = [];
      for(_loc3_ in this.button2Inverted)
      {
         _loc6_ = _loc3_ as GpControlButton;
         _loc2_.push(_loc6_.name);
      }
      _loc2_.sort();
      _loc4_ = {};
      for(_loc5_ in this.button2ControlIds)
      {
         _loc7_ = _loc5_ as GpControlButton;
         _loc8_ = this.button2ControlIds[_loc7_];
         if(_loc8_)
         {
            for each(_loc9_ in _loc8_)
            {
               _loc4_[_loc9_] = _loc7_.name;
            }
         }
      }
      param1["map"] = _loc4_;
      param1["inverts"] = _loc2_;
      return param1;
   }
}
