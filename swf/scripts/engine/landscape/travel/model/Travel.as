package engine.landscape.travel.model
{
   import engine.core.BoxNumber;
   import engine.core.logging.ILogger;
   import engine.landscape.model.Landscape;
   import engine.landscape.travel.def.TravelDef;
   import engine.landscape.travel.def.TravelLocationDef;
   import engine.landscape.travel.def.TravelLocator;
   import engine.landscape.travel.def.TravelParamControlDef;
   import engine.saga.Caravan;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariable;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class Travel extends EventDispatcher
   {
      
      public static const EVENT_START_REACHED:String = "Travel.EVENT_START_REACHED";
      
      public static const SPEED_MULT_CLOSE:Number = 55;
      
      public static const SPEED_MULT_FAR:Number = 60;
      
      public static const DAY_LENGTH_CLOSE:Number = 0;
      
      public static const DAY_LENGTH_FAR:Number = 868;
      
      private static var ACCEL_RATE:Number = 1 / 1;
      
      private static var DECEL_RATE:Number = 1 / 1;
       
      
      public var def:TravelDef;
      
      public var landscape:Landscape;
      
      private var _position:Number = 0;
      
      private var _speed:Number = 1;
      
      public var forward:Boolean = true;
      
      public var moving:Boolean = true;
      
      public var nextLocationIndex:int = 0;
      
      private var cleanedup:Boolean;
      
      private var saga:Saga;
      
      public var caravan_pt:Point;
      
      public var audio:TravelAudio;
      
      private var haltingPosition:Number = 0;
      
      private var halting:Boolean;
      
      private var haltDistance:Number = 0;
      
      private var jump:Number = -1;
      
      public var speedFactor:Number = 0;
      
      private var currentMapSplineId:String;
      
      private var currentMapSplineKey:String;
      
      private var currentMapSplineT:Number = 0;
      
      private var currentMapKeyLocationIndex:int = -1;
      
      private var nextMapKeyLocationIndex:int = -1;
      
      public var allowCameraCaravanAnchor:Boolean = true;
      
      public var logger:ILogger;
      
      public var paramControlsById:Dictionary;
      
      public var fallData:Travel_FallData;
      
      public var caravan:Caravan;
      
      private var _remainingMovementThisUpdate:BoxNumber;
      
      private var _travelBlockedUnready:String;
      
      private var _travelBlockedHalting:String;
      
      public var speedSplineUnits:Number = 0;
      
      public function Travel(param1:Landscape, param2:TravelDef, param3:TravelLocator, param4:Travel_FallData)
      {
         var _loc5_:TravelParamControlDef = null;
         this.caravan_pt = new Point();
         super();
         this.landscape = param1;
         this.def = param2;
         this.logger = param1.context.logger;
         this.fallData = param4;
         this._remainingMovementThisUpdate = new BoxNumber();
         if(param1.scene._context.saga)
         {
            this.saga = param1.scene._context.saga as Saga;
            this.saga.waitForHalt = true;
         }
         this.audio = new TravelAudio(this);
         if(this.saga)
         {
            this.saga.travelLocator.travel_id = param2.id;
         }
         if(param3)
         {
            if(param3.travel_location)
            {
               this.gotoLocation(param3.travel_location);
            }
            else if(param3.travel_position >= 0)
            {
               this.gotoPosition(param3.travel_position);
            }
         }
         if(param2.paramControls)
         {
            this.paramControlsById = new Dictionary();
            for each(_loc5_ in param2.paramControls)
            {
               this.paramControlsById[_loc5_.id] = new TravelParamControl(this,_loc5_);
            }
         }
         this.caravan = !!this.saga ? this.saga.caravan : null;
      }
      
      public function getTravelParamControlById(param1:String) : TravelParamControl
      {
         return !!this.paramControlsById ? this.paramControlsById[param1] : null;
      }
      
      private function recomputeMapKeyLocationIndexes() : void
      {
         var _loc2_:TravelLocationDef = null;
         this.currentMapKeyLocationIndex = -1;
         this.nextMapKeyLocationIndex = -1;
         var _loc1_:int = 0;
         while(_loc1_ < this.def.locations.length)
         {
            _loc2_ = this.def.locations[_loc1_];
            if(_loc2_.mapkey)
            {
               if(_loc2_.position > this.position)
               {
                  this.nextMapKeyLocationIndex = _loc1_;
                  break;
               }
               this.currentMapKeyLocationIndex = _loc1_;
               this.currentMapSplineKey = _loc2_.id;
            }
            _loc1_++;
         }
      }
      
      private function recomputeMapKeySplineT() : void
      {
         var _loc1_:TravelLocationDef = this.currentMapKeyLocationIndex >= 0 ? this.def.locations[this.currentMapKeyLocationIndex] : null;
         var _loc2_:TravelLocationDef = this.nextMapKeyLocationIndex >= 0 ? this.def.locations[this.nextMapKeyLocationIndex] : null;
         var _loc3_:Number = !!_loc1_ ? _loc1_.position : 0;
         var _loc4_:Number = !!_loc2_ ? _loc2_.position : this.def.spline.totalLength;
         var _loc5_:Number = _loc4_ - _loc3_;
         this.currentMapSplineT = (this.position - _loc3_) / _loc5_;
         if(this.caravan)
         {
            this.caravan.setMapSpline(this.currentMapSplineId,this.currentMapSplineKey,this.currentMapSplineT);
         }
      }
      
      public function start() : void
      {
         if(this.saga)
         {
            if(!this.def.close)
            {
               this.currentMapSplineId = this.landscape.scene._def.id;
               this.recomputeMapKeyLocationIndexes();
               this.recomputeMapKeySplineT();
            }
         }
      }
      
      public function get speed() : Number
      {
         return this._speed;
      }
      
      public function set speed(param1:Number) : void
      {
         this._speed = Math.max(0,param1);
      }
      
      public function cleanup() : void
      {
         if(this.cleanedup)
         {
            throw new IllegalOperationError("double cleanup");
         }
         this.cleanedup = true;
         if(this.saga)
         {
            this.saga.waitForHalt = false;
         }
      }
      
      private function stepForward(param1:BoxNumber) : Boolean
      {
         var _loc3_:TravelLocationDef = null;
         var _loc4_:Number = NaN;
         if(this.position >= this.def.spline_end)
         {
            this.position = this.def.spline_end;
            return false;
         }
         if(!this.saga)
         {
            return false;
         }
         var _loc2_:Number = 0;
         if(this.nextLocationIndex < this.def.locations.length)
         {
            _loc3_ = this.def.locations[this.nextLocationIndex];
            _loc4_ = _loc3_._position - 1;
            if(!this.landscape.scene.ready && _loc3_._position >= this._position)
            {
               if(this._position + param1.value >= _loc4_)
               {
                  if(this._travelBlockedUnready != _loc3_.id)
                  {
                     this.logger.info("   TRAVEL UNREADY BLOCKED BY " + _loc3_.id);
                     this._travelBlockedUnready = _loc3_.id;
                  }
                  _loc2_ = _loc4_ - this._position;
                  this.position = _loc4_;
                  param1.value -= _loc2_;
                  return _loc2_ > 0 ? true : false;
               }
               this._travelBlockedUnready = null;
            }
            else if(this.halting)
            {
               if(this._position + param1.value >= _loc4_)
               {
                  if(this._travelBlockedHalting != _loc3_.id)
                  {
                     this.logger.info("   TRAVEL HALTING BLOCKED BY " + _loc3_.id);
                     this._travelBlockedHalting = _loc3_.id;
                  }
                  this.haltingPosition = _loc4_;
                  _loc2_ = _loc4_ - this.position;
                  this.position = _loc4_;
                  if(this.saga)
                  {
                     this.saga.halted = true;
                  }
                  param1.value -= _loc2_;
                  return _loc2_ > 0 ? true : false;
               }
               this._travelBlockedHalting = null;
            }
            else if(this._position + param1.value >= _loc3_._position)
            {
               this.logger.info("   TRAVEL REACHED [" + _loc3_ + "]");
               param1.value = this.position + param1.value - _loc3_.position;
               this.position = Math.max(this.def.spline_start,Math.min(this.def.spline_end,_loc3_.position));
               ++this.nextLocationIndex;
               if(this.saga)
               {
                  this.saga.triggerLocation(this,_loc3_.id);
               }
               return true;
            }
         }
         else if(this.halting && this.haltingPosition >= 0)
         {
            if(this.position + param1.value >= this.haltingPosition)
            {
               param1.value = this.position + param1.value - this.haltingPosition;
               this.position = this.haltingPosition;
               if(this.saga)
               {
                  this.saga.halted = true;
               }
               return true;
            }
         }
         this.position += param1.value;
         this.position = Math.max(this.def.spline_start,Math.min(this.def.spline_end,this.position));
         param1.value = 0;
         return true;
      }
      
      public function update(param1:int) : void
      {
         var _loc6_:TravelLocationDef = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:IVariable = null;
         var _loc11_:int = 0;
         var _loc12_:IVariable = null;
         this.speedSplineUnits = 0;
         if(!this.landscape.scene.lookingForReady && !this.landscape.scene.ready)
         {
            return;
         }
         if(!this.moving)
         {
            return;
         }
         this.audio.update();
         if(!this.saga || this.saga.halted)
         {
            this.speedFactor = 0;
            return;
         }
         if(this.saga.paused)
         {
            return;
         }
         if(this.saga.caravan != this.caravan)
         {
            if(this.saga.halting)
            {
               if(!this.saga.halted)
               {
                  this.saga.halted = true;
               }
            }
            return;
         }
         var _loc2_:Number = 0;
         if(this.saga.halting)
         {
            if(!this.halting)
            {
               if(this.saga.haltLocation)
               {
                  _loc6_ = this.def.findLocationById(this.saga.haltLocation);
                  if(_loc6_)
                  {
                     this.haltingPosition = _loc6_.position;
                  }
                  else
                  {
                     _loc7_ = 10;
                     this.haltingPosition = Math.min(this.def.spline_end,this.position + _loc7_);
                  }
                  this.haltDistance = Math.max(0,this.haltingPosition - this.position);
               }
               else
               {
                  this.haltingPosition = -1;
               }
               this.halting = true;
            }
            if(this.saga.haltLocation)
            {
               if(this.haltDistance > 0)
               {
                  this.speedFactor = (this.haltingPosition - this.position) / this.haltDistance;
                  this.speedFactor = Math.min(1,Math.max(0.1,this.speedFactor));
               }
               else
               {
                  this.speedFactor = 0;
               }
            }
            else
            {
               this.speedFactor = Math.max(0,this.speedFactor - param1 * DECEL_RATE / 1000);
            }
            if(this.speedFactor == 0)
            {
               this.saga.halted = true;
               this.halting = false;
            }
         }
         else
         {
            if(this.halting)
            {
               this.halting = false;
            }
            if(this.def.close)
            {
               this.speedFactor = this.saga.travelDrivingSpeed;
            }
            else
            {
               _loc8_ = this.saga.travelDrivingSpeed;
               if(this.speedFactor < _loc8_)
               {
                  this.speedFactor = Math.min(_loc8_,this.speedFactor + param1 * ACCEL_RATE / 1000);
                  this.speedFactor = Math.max(0 * _loc8_,this.speedFactor);
               }
               else
               {
                  this.speedFactor = Math.max(_loc8_,this.speedFactor - param1 * ACCEL_RATE / 1000);
               }
            }
         }
         var _loc3_:TravelLocationDef = null;
         var _loc4_:Number = this.speed * (this.def.speed > 0 ? this.def.speed : (this.def.close ? SPEED_MULT_CLOSE : SPEED_MULT_FAR));
         this.speedSplineUnits = _loc4_;
         var _loc5_:Number = this.speedFactor * (_loc4_ * param1 / 1000);
         if(this.jump >= 0)
         {
            _loc5_ = this.jump - this.position;
            this.jump = -1;
         }
         if(this.forward)
         {
            if(this.position < this.def.spline_end)
            {
               this._remainingMovementThisUpdate.value = _loc5_;
               while(_loc5_ > 0)
               {
                  if(!this.stepForward(this._remainingMovementThisUpdate))
                  {
                     break;
                  }
                  _loc2_ += _loc5_ - this._remainingMovementThisUpdate.value;
                  _loc5_ = this._remainingMovementThisUpdate.value;
                  if(!this.moving || this.saga.halted)
                  {
                     break;
                  }
               }
               if(!this.def.close)
               {
                  _loc9_ = _loc2_ / DAY_LENGTH_FAR;
                  _loc10_ = this.saga.getVar(SagaVar.VAR_DAY,null);
                  _loc10_.asAny = _loc10_.asNumber + _loc9_;
                  _loc11_ = this.saga.getVarInt(SagaVar.VAR_TRAVEL_HUD_APPEARANCE);
                  if(_loc11_ == SagaVar.TRAVEL_HUD_APPEARANCE_LIGHT_SHATTERED || _loc11_ == SagaVar.TRAVEL_HUD_APPEARANCE_DARK_SHATTERED)
                  {
                     _loc12_ = this.saga.getVar(SagaVar.VAR_DAYS_REMAINING,null);
                     _loc12_.asAny = _loc12_.asNumber - _loc9_;
                  }
               }
               if(this.position >= this.def.spline_end)
               {
                  if(this.saga)
                  {
                     this.saga.triggerLocation(this,"end");
                  }
               }
            }
         }
         else if(this.position > this.def.spline_start)
         {
            this.position -= _loc5_;
            this.position = Math.min(this.def.spline_end,Math.max(this.def.spline_start,this.position));
            dispatchEvent(new Event(EVENT_START_REACHED));
         }
         else if(this.position < this.def.spline_start)
         {
            this.position = this.def.spline_start;
         }
      }
      
      public function computeSpeedMult() : Number
      {
         return this.def.speed > 0 ? this.def.speed : (this.def.close ? SPEED_MULT_CLOSE : SPEED_MULT_FAR);
      }
      
      public function gotoPosition(param1:Number) : void
      {
         var _loc2_:TravelLocationDef = null;
         this.logger.info("   TRAVEL GOTO POS " + param1);
         this.position = param1;
         this.nextLocationIndex = 0;
         while(this.nextLocationIndex < this.def.locations.length)
         {
            _loc2_ = this.def.locations[this.nextLocationIndex];
            if(_loc2_.position > this.position)
            {
               break;
            }
            ++this.nextLocationIndex;
         }
      }
      
      public function gotoLocation(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:TravelLocationDef = this.def.findLocationById(param1);
         if(_loc2_)
         {
            this.logger.info("   TRAVEL GOTO LOC " + _loc2_);
            this.gotoPosition(_loc2_.position);
         }
         else
         {
            this.logger.error("   TRAVEL GOTO not found " + param1);
         }
      }
      
      public function jumpForward() : Boolean
      {
         var _loc1_:TravelLocationDef = null;
         if(this.saga)
         {
            this.saga.terminateWaits();
         }
         if(Boolean(this.saga.convo) && Boolean(this.saga.convo.cursor))
         {
            this.saga.convo.cursor.ff();
            return true;
         }
         if(this.saga.halted || this.saga.camped)
         {
            return false;
         }
         if(this.nextLocationIndex < this.def.locations.length)
         {
            _loc1_ = this.def.locations[this.nextLocationIndex];
            if(this.jump != _loc1_.position)
            {
               this.jump = _loc1_.position;
               return true;
            }
         }
         else if(this.jump != this.def.spline.totalLength)
         {
            this.jump = this.def.spline.totalLength;
            return true;
         }
         return false;
      }
      
      public function jumpBack() : void
      {
         this.nextLocationIndex = 0;
         this.position = 0;
      }
      
      public function get position() : Number
      {
         return this._position;
      }
      
      public function set position(param1:Number) : void
      {
         var _loc3_:TravelLocationDef = null;
         var _loc4_:TravelLocationDef = null;
         var _loc5_:TravelParamControl = null;
         var _loc2_:* = this._position != param1;
         this._position = param1;
         if(this.saga)
         {
            this.saga.travelLocator.travel_position = this._position;
         }
         if(this.currentMapSplineId)
         {
            _loc3_ = this.currentMapKeyLocationIndex >= 0 ? this.def.locations[this.currentMapKeyLocationIndex] : null;
            _loc4_ = this.nextMapKeyLocationIndex >= 0 ? this.def.locations[this.nextMapKeyLocationIndex] : null;
            if(Boolean(_loc4_) && this._position >= _loc4_.position)
            {
               this.recomputeMapKeyLocationIndexes();
            }
            else if(Boolean(_loc3_) && this._position < _loc3_.position)
            {
               this.recomputeMapKeyLocationIndexes();
            }
            this.recomputeMapKeySplineT();
         }
         if(_loc2_)
         {
            if(this.paramControlsById)
            {
               for each(_loc5_ in this.paramControlsById)
               {
                  _loc5_.update();
               }
            }
         }
      }
   }
}
