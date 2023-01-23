package engine.landscape.travel.view
{
   import as3isolib.utils.IsoUtil;
   import engine.core.logging.ILogger;
   import engine.landscape.travel.def.TravelReactorDef;
   import engine.landscape.travel.model.Travel;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.math.MathUtil;
   import engine.resource.BitmapResource;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariable;
   import engine.scene.SceneContext;
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.SoundDef;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getTimer;
   
   public class TravelReactorView implements ISoundDefBundleListener
   {
      
      public static var ENABLED:Boolean = true;
       
      
      public var view:TravelView;
      
      public var travel:Travel;
      
      public var def:TravelReactorDef;
      
      public var nextTick:int;
      
      public var _nextSpawnRect:Rectangle = null;
      
      public var _nextSpawnIndex:int;
      
      public var logger:ILogger;
      
      public var dow:DisplayObjectWrapper;
      
      public var context:SceneContext;
      
      private var sprites:Vector.<TravelReactorSpriteBase>;
      
      private var started:Boolean;
      
      private var atlas:BitmapResource;
      
      private var saga:Saga;
      
      private var scratchPt_0:Point;
      
      private var scratchPt_1:Point;
      
      private var bundle:ISoundDefBundle;
      
      public var lastCaravanLengthT:Number = 0;
      
      public var populationVar:IVariable;
      
      public var suppliesVar:IVariable;
      
      private var wasPaused:Boolean;
      
      public var lastCaravanPopulation:int = 0;
      
      public var lastCaravanSupplies:int = 0;
      
      public var currentLocationCaravanStart:Number = 0;
      
      public var currentLocationCaravanEnd:Number = 0;
      
      private var _riserRectCounts:Vector.<RiserCounter>;
      
      private var _riserRectCountsSorted:Array;
      
      private var wasSceneReady:Boolean;
      
      private var frontScratch_0:Point;
      
      public function TravelReactorView(param1:TravelView, param2:TravelReactorDef)
      {
         var _loc3_:* = undefined;
         var _loc4_:RiserCounter = null;
         this.sprites = new Vector.<TravelReactorSpriteBase>();
         this.scratchPt_0 = new Point();
         this.scratchPt_1 = new Point();
         this._riserRectCounts = new Vector.<RiserCounter>();
         this._riserRectCountsSorted = [];
         this.frontScratch_0 = new Point();
         super();
         this.view = param1;
         this.travel = param1.travel;
         this.logger = this.travel.logger;
         this.context = this.travel.landscape.scene._context;
         this.saga = this.context.saga as Saga;
         if(this.saga)
         {
            this.populationVar = this.saga.getVar(SagaVar.VAR_NUM_POPULATION,null);
            this.suppliesVar = this.saga.getVar(SagaVar.VAR_SUPPLIES,null);
         }
         this.def = param2;
         param2.splineStart_t = param2.splineStart * this.travel.def.spline.ooTotalLength;
         this.dow = IsoUtil.createDisplayObjectWrapper();
         this.atlas = this.context.resman.getResource(param2.spawnUrl,BitmapResource) as BitmapResource;
         for each(_loc3_ in param2.riserRects)
         {
            _loc4_ = new RiserCounter(this._riserRectCounts.length);
            this._riserRectCounts.push(_loc4_);
            this._riserRectCountsSorted.push(_loc4_);
         }
         this.preload();
      }
      
      private static function makeSoundDef(param1:String, param2:Vector.<ISoundDef>) : void
      {
         var _loc3_:SoundDef = null;
         if(!param1)
         {
            return;
         }
         _loc3_ = new SoundDef().setup("common",param1,param1);
         param2.push(_loc3_);
      }
      
      public function preload() : void
      {
         var _loc2_:SoundDef = null;
         var _loc1_:Vector.<ISoundDef> = new Vector.<ISoundDef>();
         makeSoundDef(this.def.reachSoundEvent,_loc1_);
         makeSoundDef(this.def.fallSoundEvent,_loc1_);
         makeSoundDef(this.def.landSoundEvent,_loc1_);
         var _loc3_:String = this.travel.landscape.scene._def.url;
         var _loc4_:String = "travel-reactor-view:" + _loc3_ + ":" + this.travel.def.id + ":" + this.def.id;
         this.bundle = this.context.soundDriver.preloadSoundDefData(_loc4_,_loc1_);
         this.bundle.addListener(this);
      }
      
      public function addSprite(param1:TravelReactorSpriteBase) : void
      {
         this.sprites.push(param1);
         this.dow.addChild(param1.dow);
      }
      
      public function cleanup() : void
      {
         var _loc1_:TravelReactorSpriteBase = null;
         if(this.atlas)
         {
            this.atlas.release();
            this.atlas = null;
         }
         for each(_loc1_ in this.sprites)
         {
            _loc1_.cleanup();
         }
         this.sprites = null;
      }
      
      private function updatePopulation() : void
      {
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Rectangle = null;
         var _loc14_:TravelReactorTumbler = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:Point = null;
         var _loc19_:int = 0;
         var _loc1_:Number = this.view.caravan.caravan_start_t - this.view.caravan.caravan_end_t;
         var _loc2_:int = !!this.populationVar ? this.populationVar.asInteger : 0;
         var _loc3_:int = !!this.suppliesVar ? this.suppliesVar.asInteger : 0;
         var _loc4_:int = _loc2_ - this.lastCaravanPopulation;
         var _loc5_:Number = this.view.caravan.caravan_start_t;
         var _loc6_:Number = _loc5_ - _loc1_;
         var _loc7_:Number = _loc6_ - _loc5_;
         var _loc8_:Number = 0;
         if(_loc4_ < 0)
         {
            _loc9_ = _loc1_ - this.lastCaravanLengthT;
            if(_loc9_ < -0.0001)
            {
               _loc5_ = this.view.caravan.caravan_end_t;
               _loc6_ = _loc5_ + _loc9_;
            }
            _loc6_ = Math.max(this.def.splineStart_t,_loc6_);
            if(_loc6_ < _loc5_)
            {
               _loc7_ = _loc6_ - _loc5_;
               _loc10_ = 10;
               if(Boolean(this.def.fallPeople) && Boolean(this.def.fallPeople.length))
               {
                  _loc11_ = 0;
                  while(_loc11_ < -_loc4_)
                  {
                     _loc8_ = _loc5_ + _loc7_ * Math.random();
                     this.travel.def.spline.sample(_loc8_,this.scratchPt_0);
                     _loc12_ = MathUtil.randomInt(0,this.def.fallPeople.length - 1);
                     _loc13_ = this.def.fallPeople[_loc12_];
                     _loc14_ = new TravelReactorTumbler(this.atlas,this,_loc13_,this.scratchPt_0,this.def.spawnOffsetY,1);
                     this.addSprite(_loc14_);
                     _loc11_ += _loc10_;
                  }
               }
            }
         }
         if(Boolean(this.def.fallCarts) && Boolean(this.def.fallCarts.length))
         {
            _loc15_ = _loc3_ - this.lastCaravanSupplies;
            this.lastCaravanSupplies = _loc3_;
            _loc16_ = 100;
            _loc17_ = Math.max(0,-_loc15_ / _loc16_);
            if(Boolean(this.view.caravan.truncatedCarts) && Boolean(this.view.caravan.truncatedCarts.length))
            {
               for each(_loc18_ in this.view.caravan.truncatedCarts)
               {
                  this.createSupplyTumbler(_loc18_);
                  _loc17_--;
               }
               this.view.caravan.resetTruncatedCarts();
            }
            if(_loc7_ < 0)
            {
               _loc19_ = 0;
               while(_loc19_ < _loc17_)
               {
                  _loc8_ = _loc5_ + _loc7_ * Math.random();
                  this.travel.def.spline.sample(_loc8_,this.scratchPt_0);
                  this.createSupplyTumbler(this.scratchPt_0);
                  _loc19_++;
               }
            }
         }
         this.lastCaravanLengthT = _loc1_;
         this.lastCaravanPopulation = _loc2_;
      }
      
      private function createSupplyTumbler(param1:Point) : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:TravelReactorTumbler = null;
         for each(_loc2_ in this.def.fallCarts)
         {
            _loc3_ = new TravelReactorTumbler(this.atlas,this,_loc2_,param1,this.def.spawnOffsetY,0.5);
            this.addSprite(_loc3_);
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:TravelReactorSpriteBase = null;
         if(!this.started)
         {
            this.startFill();
         }
         if(!this.travel.landscape.scene.ready)
         {
            return;
         }
         if(!this.saga.paused || !this.wasPaused)
         {
            _loc2_ = this.travel.def.spline.totalLength;
            _loc3_ = this.view.caravan.caravan_end_t * _loc2_;
            _loc4_ = this.view.caravan.caravan_start_t * _loc2_;
            this.currentLocationCaravanStart = _loc4_;
            this.currentLocationCaravanEnd = _loc3_;
            this.updatePopulation();
            _loc5_ = 0;
            while(_loc5_ < this.sprites.length)
            {
               _loc6_ = this.sprites[_loc5_];
               if(_loc6_.terminated)
               {
                  _loc6_.cleanup();
                  this.sprites.splice(_loc5_,1);
               }
               else
               {
                  _loc6_.update(param1);
                  _loc5_++;
               }
            }
         }
         this.wasPaused = this.saga.paused;
         this.updateTicks();
      }
      
      private function startFill() : void
      {
         if(this.started)
         {
            return;
         }
         var _loc1_:Number = this.travel.def.spline.totalLength;
         var _loc2_:int = Math.min(this.def.splineEnd,this.view.caravan.caravan_start_t * _loc1_ + this.def.spawnLead + 200);
         var _loc3_:Number = this.travel.computeSpeedMult() / 1000;
         this.nextTick = this.def.splineStart;
         var _loc4_:int = Math.max(this.def.splineStart,this.view.caravan.caravan_end_t * _loc1_);
         while(_loc2_ > this.nextTick)
         {
            this.tickOne(_loc3_);
         }
         this.started = true;
      }
      
      private function updateTicks() : void
      {
         var _loc1_:Number = this.travel.def.spline.totalLength;
         var _loc2_:int = this.view.caravan.caravan_start_t * _loc1_;
         var _loc3_:Number = this.travel.speedSplineUnits / 1000;
         var _loc4_:int = this.def.spawnDurationMs * _loc3_;
         var _loc5_:int = _loc2_ + this.def.spawnLead + _loc4_;
         while(this.nextTick < this.def.splineEnd && _loc5_ > this.nextTick)
         {
            this.tickOne(_loc3_);
         }
      }
      
      public function tickOne(param1:Number) : void
      {
         var _loc8_:Number = NaN;
         var _loc2_:Number = this.nextTick * this.travel.def.spline.ooTotalLength;
         this.travel.def.spline.sample(_loc2_,this.scratchPt_0);
         this.scratchPt_0.y += this.def.splineHeightDelta;
         this.scratchPt_1.copyFrom(this.scratchPt_0);
         this.scratchPt_1.y = this.def.spawnOffsetY;
         var _loc3_:Number = this.travel.def.spline.totalLength;
         var _loc4_:int = this.view.caravan.caravan_start_t * _loc3_ + this.def.spawnLead;
         var _loc5_:int = _loc4_ + this.def.spawnLead;
         var _loc6_:Number = this.def.spawnDurationMs;
         if(!this.started || _loc5_ >= this.nextTick)
         {
            _loc6_ = 0;
         }
         else if(param1 > 0)
         {
            _loc8_ = (this.nextTick - _loc5_) / param1;
            if(_loc8_ < _loc6_)
            {
               _loc6_ = _loc8_;
            }
         }
         var _loc7_:TravelReactorRiser = this.createSprite(this.nextTick,this.scratchPt_1,this.scratchPt_0,_loc6_);
         this.scheduleNextTick(this.nextTick);
      }
      
      private function scheduleNextTick(param1:int) : void
      {
         this.nextTick = param1;
         var _loc2_:int = 0;
         if(this._nextSpawnRect)
         {
            this.nextTick += this._nextSpawnRect.width - this.def.spawnMargin - this._nextSpawnRect.width * this.def.spawnMarginPercent;
         }
         this._nextSpawnIndex = this.calculateNextRiserRectIndex();
         this._nextSpawnRect = this.def.riserRects[this._nextSpawnIndex];
         if(this._nextSpawnRect)
         {
            this.nextTick += -this.def.spawnMargin - this._nextSpawnRect.width * this.def.spawnMarginPercent;
         }
      }
      
      private function calculateNextRiserRectIndex() : int
      {
         var _loc7_:RiserCounter = null;
         this._riserRectCountsSorted.sortOn("lastUsedTime",Array.NUMERIC);
         this._riserRectCountsSorted.sortOn("count",Array.NUMERIC);
         var _loc1_:int = -1;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._riserRectCountsSorted.length)
         {
            _loc7_ = this._riserRectCountsSorted[_loc3_];
            if(_loc1_ < 0)
            {
               _loc1_ = _loc7_.count;
            }
            else if(_loc7_.count > _loc1_)
            {
               break;
            }
            _loc2_ = _loc3_;
            _loc3_++;
         }
         var _loc4_:Number = Math.random();
         _loc4_ *= _loc4_ * _loc4_;
         if(_loc1_ > 0)
         {
            _loc4_ /= _loc1_ + 1;
         }
         var _loc5_:int = Math.round(_loc4_ * _loc2_);
         return int(this._riserRectCountsSorted[_loc5_].index);
      }
      
      public function createSprite(param1:Number, param2:Point, param3:Point, param4:int) : TravelReactorRiser
      {
         var _loc7_:Rectangle = null;
         var _loc17_:int = 0;
         if(!this._nextSpawnRect)
         {
            return null;
         }
         var _loc5_:Number = 0;
         var _loc6_:Rectangle = this.def.fallDebris[this._nextSpawnIndex];
         if(Boolean(this.def.crashDust) && Boolean(this.def.crashDust.length))
         {
            _loc7_ = this.def.crashDust[MathUtil.randomInt(0,this.def.crashDust.length - 1)];
         }
         var _loc8_:Number = (this.nextTick + this._nextSpawnRect.width) * this.travel.def.spline.ooTotalLength;
         this.travel.def.spline.sample(_loc8_,this.frontScratch_0);
         this.frontScratch_0.y += this.def.splineHeightDelta;
         var _loc9_:Number = 1;
         var _loc10_:Number = this.frontScratch_0.y - param3.y;
         var _loc11_:Number = this.frontScratch_0.x - param3.x;
         if(!this.travel.def.leftToRight)
         {
            _loc11_ = -_loc11_;
            _loc10_ = -_loc10_;
         }
         var _loc12_:Number = Math.atan2(_loc10_,_loc11_);
         _loc5_ = MathUtil.radians2Degrees(_loc12_);
         param3.x = (param3.x + this.frontScratch_0.x) / 2;
         param3.y = (param3.y + this.frontScratch_0.y) / 2;
         var _loc13_:int = 3000;
         var _loc14_:int = 8000;
         var _loc15_:RiserCounter = this._riserRectCounts[this._nextSpawnIndex];
         var _loc16_:TravelReactorRiser = new TravelReactorRiser(this._nextSpawnIndex,param1,this.atlas,this._nextSpawnRect,param2,param3,_loc5_,param4,this,_loc6_,_loc13_,_loc15_.reverse);
         if(Boolean(this.sprites.length) && this.sprites[this.sprites.length - 1].dow.width > _loc16_.dow.width)
         {
            this.dow.addChild(_loc16_.dow);
         }
         else
         {
            _loc17_ = MathUtil.randomInt(0,this.dow.numChildren);
            this.dow.addChildAt(_loc16_.dow,_loc17_);
         }
         _loc15_.reverse = !_loc15_.reverse;
         ++_loc15_.count;
         _loc15_.lastUsedTime = getTimer();
         _loc15_.bias += this._nextSpawnRect.width * 10;
         this.sprites.push(_loc16_);
         return _loc16_;
      }
      
      public function uncountRiser(param1:TravelReactorRiser) : void
      {
         --this._riserRectCounts[param1.index].count;
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
      }
   }
}

class RiserCounter
{
    
   
   public var index:int;
   
   public var count:int;
   
   public var lastUsedTime:int;
   
   public var bias:int;
   
   public var reverse:Boolean;
   
   public function RiserCounter(param1:int)
   {
      super();
      this.index = param1;
   }
}
