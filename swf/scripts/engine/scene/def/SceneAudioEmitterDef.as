package engine.scene.def
{
   import engine.core.logging.ILogger;
   import engine.core.render.Camera;
   import engine.landscape.model.Landscape;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableBag;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class SceneAudioEmitterDef extends EventDispatcher
   {
      
      public static var EVENT_EVENT:String = "SceneAudioEmitterDef.EVENT_EVENT";
      
      public static var EVENT_SKU:String = "SceneAudioEmitterDef.EVENT_SKU";
      
      public static var EVENT_PARAMS:String = "SceneAudioEmitterDef.EVENT_PARAMS";
      
      public static var EVENT_LIMIT:String = "SceneAudioEmitterDef.EVENT_LIMIT";
      
      public static var EVENT_ATTENUATION:String = "SceneAudioEmitterDef.EVENT_ATTENUATION";
      
      public static var EVENT_VOLUME:String = "SceneAudioEmitterDef.EVENT_VOLUME";
      
      public static var EVENT_LAYER:String = "SceneAudioEmitterDef.EVENT_LAYER";
       
      
      public var source:Rectangle;
      
      protected var _limit:Rectangle;
      
      protected var _attenuation_left:Number = 1;
      
      protected var _attenuation_right:Number = 1;
      
      protected var _volume:Number = 1;
      
      protected var _layer:String;
      
      public var condition_if:String;
      
      public var condition_not:String;
      
      public var paramNames:Array;
      
      public var paramValues:Array;
      
      protected var _event:String = "event";
      
      protected var _sku:String = "";
      
      private var _enabled:Boolean = true;
      
      private var offset:Point;
      
      public var dirty:Boolean;
      
      public function SceneAudioEmitterDef()
      {
         this.source = new Rectangle();
         this.paramNames = [];
         this.paramValues = [];
         this.offset = new Point();
         super();
      }
      
      public function get layer() : String
      {
         return this._layer;
      }
      
      override public function toString() : String
      {
         return this._event;
      }
      
      public function set layer(param1:String) : void
      {
         this._layer = param1;
         dispatchEvent(new Event(EVENT_LAYER));
      }
      
      public function setOffset(param1:Number, param2:Number) : void
      {
         if(param1 == this.offset.x && param2 == this.offset.y)
         {
            return;
         }
         this.offset.setTo(param1,param2);
         this.dirty = true;
      }
      
      public function checkConditions(param1:IVariableBag) : Boolean
      {
         var _loc2_:IVariable = null;
         if(!param1)
         {
            return false;
         }
         if(this.condition_if)
         {
            _loc2_ = param1.fetch(this.condition_if,null);
            if(!_loc2_ || !_loc2_.asBoolean)
            {
               return false;
            }
         }
         if(this.condition_not)
         {
            _loc2_ = param1.fetch(this.condition_not,null);
            if(Boolean(_loc2_) && _loc2_.asBoolean)
            {
               return false;
            }
         }
         return true;
      }
      
      public function checkAudibilityForListener(param1:Camera, param2:SceneAudioEmitterDefAudibility, param3:Landscape) : SceneAudioEmitterDefAudibility
      {
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc4_:ILogger = param3.context.logger;
         this.dirty = false;
         if(!this.enabled)
         {
            if(param2)
            {
               param2.volume = 0;
               param2.audible = false;
            }
            return param2;
         }
         var _loc5_:Number = this.source.left + this.offset.x;
         var _loc6_:Number = this.source.right + this.offset.x;
         var _loc7_:Number = 1;
         var _loc8_:Number = -param1.x;
         var _loc9_:Number = -param1.y;
         param2.resolveLayer();
         if(param2.layer)
         {
            _loc8_ = param2.layer.offset.x;
            _loc9_ = param2.layer.offset.y;
            if(param2.layer.def.speed)
            {
               _loc7_ /= param2.layer.def.speed;
            }
         }
         else if(param2.emitter.layer)
         {
            if(param2)
            {
               param2.volume = 0;
               param2.audible = false;
            }
            return param2;
         }
         _loc5_ += _loc8_;
         _loc6_ += _loc8_;
         var _loc10_:Number = param1.width * 8 * _loc7_;
         var _loc11_:Number = _loc5_ - _loc10_;
         var _loc12_:Number = _loc6_ + _loc10_;
         var _loc13_:Number = param1.width * 0.5;
         if(_loc7_ < 1)
         {
            _loc13_ /= _loc7_;
         }
         var _loc14_:Number = _loc5_ - _loc13_;
         var _loc15_:Number = _loc6_ + _loc13_;
         if(param2)
         {
            param2.audible = false;
         }
         if(0 >= _loc14_ && 0 <= _loc15_)
         {
            if(!param2)
            {
               param2 = new SceneAudioEmitterDefAudibility(this,param3);
            }
            param2.audible = true;
            if(0 < _loc5_)
            {
               _loc16_ = _loc5_ - _loc11_;
               param2.panX = -_loc5_ / _loc16_;
               _loc17_ = _loc5_ - _loc14_;
               param2.volume = 1 - _loc5_ / _loc17_;
            }
            else if(0 > _loc6_)
            {
               _loc18_ = _loc12_ - _loc6_;
               param2.panX = -_loc6_ / _loc18_;
               _loc19_ = _loc15_ - _loc6_;
               param2.volume = 1 + _loc6_ / _loc19_;
            }
            else
            {
               param2.panX = 0;
               param2.volume = 1;
            }
            if(this.limit)
            {
               _loc20_ = this.limit.left + this.offset.x;
               _loc21_ = this.limit.right + this.offset.x;
               _loc20_ += _loc8_;
               _loc21_ += _loc8_;
               if(0 >= _loc20_ && 0 <= _loc21_)
               {
                  if(0 < _loc5_)
                  {
                     _loc22_ = _loc5_ - _loc20_;
                     param2.volume = Math.min(param2.volume,1 - this._attenuation_left * (_loc5_ - 0) / _loc22_);
                  }
                  else if(0 > _loc6_)
                  {
                     _loc23_ = _loc21_ - _loc6_;
                     param2.volume = Math.min(param2.volume,1 - this._attenuation_right * (0 - _loc6_) / _loc23_);
                  }
               }
               else
               {
                  param2.audible = false;
               }
            }
            param2.volume *= this.volume;
         }
         return param2;
      }
      
      public function get labelString() : String
      {
         return this.event;
      }
      
      public function addParam(param1:String) : void
      {
         this.paramNames.push(param1);
         this.paramValues.push(0);
         dispatchEvent(new Event(EVENT_PARAMS));
      }
      
      public function removeParam(param1:int) : void
      {
         this.paramNames.splice(param1,1);
         this.paramValues.splice(param1,1);
         dispatchEvent(new Event(EVENT_PARAMS));
      }
      
      public function setParamName(param1:int, param2:String) : void
      {
         this.paramNames[param1] = param2;
         dispatchEvent(new Event(EVENT_PARAMS));
      }
      
      public function setParamValue(param1:int, param2:Number) : void
      {
         this.paramValues[param1] = param2;
         dispatchEvent(new Event(EVENT_PARAMS));
      }
      
      public function clone() : SceneAudioEmitterDef
      {
         var _loc1_:SceneAudioEmitterDef = new SceneAudioEmitterDef();
         _loc1_.event = this.event;
         _loc1_.source.copyFrom(this.source);
         if(this.limit)
         {
            _loc1_.limit = this.limit.clone();
         }
         return _loc1_;
      }
      
      public function get event() : String
      {
         return this._event;
      }
      
      public function set event(param1:String) : void
      {
         this._event = param1;
         dispatchEvent(new Event(EVENT_EVENT));
      }
      
      public function get sku() : String
      {
         return this._sku;
      }
      
      public function set sku(param1:String) : void
      {
         this._sku = param1;
         dispatchEvent(new Event(EVENT_SKU));
      }
      
      public function get limit() : Rectangle
      {
         return this._limit;
      }
      
      public function set limit(param1:Rectangle) : void
      {
         this._limit = param1;
         dispatchEvent(new Event(EVENT_LIMIT));
      }
      
      public function get attenuation_right() : Number
      {
         return this._attenuation_right;
      }
      
      public function set attenuation_right(param1:Number) : void
      {
         this._attenuation_right = param1;
         dispatchEvent(new Event(EVENT_ATTENUATION));
      }
      
      public function get attenuation_left() : Number
      {
         return this._attenuation_left;
      }
      
      public function set attenuation_left(param1:Number) : void
      {
         this._attenuation_left = param1;
         dispatchEvent(new Event(EVENT_ATTENUATION));
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
         this.dirty = true;
      }
      
      public function get volume() : Number
      {
         return this._volume;
      }
      
      public function set volume(param1:Number) : void
      {
         if(this._volume == param1)
         {
            return;
         }
         this.dirty = true;
         this._volume = param1;
         dispatchEvent(new Event(EVENT_VOLUME));
      }
   }
}
