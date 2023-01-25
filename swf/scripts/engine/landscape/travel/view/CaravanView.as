package engine.landscape.travel.view
{
   import as3isolib.utils.IsoUtil;
   import engine.anim.view.BannerSprite;
   import engine.core.logging.ILogger;
   import engine.core.math.spline.CatmullRomSpline2d;
   import engine.core.render.BoundedCamera;
   import engine.landscape.travel.def.TravelDef;
   import engine.landscape.travel.model.Travel;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.math.MathUtil;
   import engine.resource.AnimClipResource;
   import engine.resource.AnimClipSpritePool;
   import engine.saga.CaravanViewDef;
   import engine.saga.CaravanViewSpriteDef;
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import engine.saga.SagaVar;
   import engine.saga.SpeakEvent;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.Variable;
   import engine.saga.vars.VariableEvent;
   import flash.display.BitmapData;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class CaravanView
   {
      
      public static var SHOW_ORIGIN_MARKER:Boolean;
      
      public static var originPixel:BitmapData;
       
      
      public var caravan_end_t:Number = 0;
      
      public var caravan_start_t:Number = 0;
      
      protected var travelView:TravelView;
      
      protected var spline:CatmullRomSpline2d;
      
      public var travel:Travel;
      
      public var caravanVars:IVariableBag;
      
      private var last_position:Number;
      
      private var last_direction:int = 0;
      
      private var last_camera_x:Number = 1.7976931348623157e+308;
      
      private var drawn:Boolean;
      
      private const FAR_CARAVAN_LEN:Number = 200;
      
      private const FAR_BANNER_HEIGHT:Number = 20;
      
      protected var apool:AnimClipSpritePool;
      
      private var TYPE_INFOS:Dictionary;
      
      protected var population_index:int = 0;
      
      protected var animTypes:Vector.<Ati>;
      
      protected var anims:Vector.<DisplayObjectWrapper>;
      
      protected var animSplineTs:Vector.<Number>;
      
      protected var caravan_t:Number;
      
      private var caravan_pt:Point;
      
      private var bubbles:CaravanBubbles;
      
      private var render_start_t_delta:Number = 0;
      
      protected var num_heroes:int = 0;
      
      private var last_speedMult:Number = -1;
      
      private var caravan_speedMult:Number = 1;
      
      protected var backLayer:int = 2;
      
      protected var rightward:Boolean;
      
      private var layeringDirty:Boolean;
      
      protected var saga:Saga;
      
      protected var banner:BannerSprite;
      
      protected var bannerUrl:String;
      
      protected var def:CaravanViewDef;
      
      protected var currents:Dictionary;
      
      private var baseUrl:String = "baseUrlUnset";
      
      public var displayObjectWrapper:DisplayObjectWrapper;
      
      private var br:AnimClipResource;
      
      public var originPixelDow:DisplayObjectWrapper;
      
      protected var cleanedup:Boolean;
      
      private var populationDirty:Boolean = true;
      
      private var _wasHalted:Boolean;
      
      private var _faller:CaravanView_Faller;
      
      private var _fallerDirty:Boolean;
      
      public var truncatedCarts:Vector.<Point>;
      
      public var glow:CaravanViewGlow;
      
      private var front_pt:Point;
      
      private var back_pt:Point;
      
      private var mid_pt:Point;
      
      private var _cameraSet:Boolean;
      
      public var glow_pt:Point;
      
      public function CaravanView(param1:TravelView)
      {
         this.TYPE_INFOS = new Dictionary();
         this.animTypes = new Vector.<Ati>();
         this.anims = new Vector.<DisplayObjectWrapper>();
         this.animSplineTs = new Vector.<Number>();
         this.caravan_pt = new Point();
         this.currents = new Dictionary();
         this.truncatedCarts = new Vector.<Point>();
         this.front_pt = new Point();
         this.back_pt = new Point();
         this.mid_pt = new Point();
         this.glow_pt = new Point();
         super();
         this.displayObjectWrapper = IsoUtil.createDisplayObjectWrapper();
         this.apool = new AnimClipSpritePool(param1.travel.landscape.scene._context.resman,1,10);
         this.apool.randomStart = true;
         this.apool.autoDriving = false;
         this.travelView = param1;
         this.travel = param1.travel;
         this.spline = this.travel.def.spline;
         if(this.spline.points.length > 1)
         {
            this.rightward = this.spline.points[1].x > this.spline.points[0].x;
         }
         this.saga = this.travel.landscape.scene._context.saga as Saga;
         if(this.saga)
         {
            this.saga.addEventListener(SagaEvent.EVENT_SHOW_CARAVAN,this.sagaShowCaravanHandler);
            this.sagaShowCaravanHandler(null);
            this.caravanVars = !!this.saga.caravan ? this.saga.caravan.vars : null;
            if(this.saga.caravan)
            {
               this.baseUrl = this.saga.caravan.animBaseUrl;
            }
            if(this.caravanVars)
            {
               this.caravanVars.addEventListener(VariableEvent.TYPE,this.caravanVarHandler);
            }
         }
         this.bubbles = new CaravanBubbles(this);
         if(this.travel.fallData)
         {
            this._faller = new CaravanView_Faller(this);
         }
      }
      
      private function getUrl(param1:String, param2:int, param3:Boolean) : String
      {
         var _loc4_:CaravanViewTypeInfo = this.getTypeInfo(param1);
         var _loc5_:String = ".clip";
         if(param3)
         {
            if(!this.travel.def.close)
            {
               throw new ArgumentError("No idling anims for world travel");
            }
            _loc5_ = "_idle.clip";
         }
         if(param2)
         {
            return this.baseUrl + _loc4_.animid + param2.toString() + _loc5_;
         }
         return this.baseUrl + _loc4_.animid + _loc5_;
      }
      
      public function addPool(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc2_:CaravanViewTypeInfo = this.TYPE_INFOS[param1];
         if(_loc2_.rands > 0)
         {
            _loc3_ = 1;
            while(_loc3_ <= _loc2_.rands)
            {
               this.apool.addPool(this.getUrl(param1,_loc3_,false),1,30);
               if(this.travel.def.close)
               {
                  this.apool.addPool(this.getUrl(param1,_loc3_,_loc2_.has_idle),1,30);
               }
               _loc3_++;
            }
         }
         else
         {
            this.apool.addPool(this.getUrl(param1,0,false),1,10);
            if(this.travel.def.close)
            {
               this.apool.addPool(this.getUrl(param1,0,_loc2_.has_idle),1,10);
            }
         }
      }
      
      public function get logger() : ILogger
      {
         return this.travel.landscape.scene._context.logger;
      }
      
      final protected function createBanner(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc4_:TravelDef = this.travelView.travel.def;
         if(!_loc4_.showBanner)
         {
            return;
         }
         if(this.bannerUrl)
         {
            this.br = this.apool.resman.getResource(this.bannerUrl,AnimClipResource) as AnimClipResource;
         }
         if(!this.br)
         {
            return;
         }
         this.banner = new BannerSprite(this.br,param1,param2,this.logger,param3);
         if(!this.rightward)
         {
            this.banner.anim.displayObjectWrapper.scaleX = -1;
         }
         this.displayObjectWrapper.addChild(this.banner.anim.displayObjectWrapper);
         this.backLayer = 2;
      }
      
      protected function initType(param1:String, param2:String, param3:int, param4:Number, param5:Number, param6:Boolean = false, param7:int = -1, param8:Number = 1.7976931348623157e+308, param9:Number = 1.7976931348623157e+308) : void
      {
         this.TYPE_INFOS[param1] = new CaravanViewTypeInfo().init(param1,param2,param3,param4,param5,param6,param7,param8,param9);
         this.addPool(param1);
      }
      
      protected function initTypesFromDef() : void
      {
         var _loc1_:CaravanViewSpriteDef = null;
         for each(_loc1_ in this.def.sprites)
         {
            this.initTypeFromDef(_loc1_);
         }
      }
      
      protected function initTypeFromDef(param1:CaravanViewSpriteDef) : void
      {
         if(param1)
         {
            this.TYPE_INFOS[param1.type] = new CaravanViewTypeInfo().fromDef(param1);
            this.addPool(param1.type);
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:DisplayObjectWrapper = null;
         if(this.cleanedup)
         {
            throw new IllegalOperationError("already cleaned up");
         }
         this.cleanedup = true;
         if(this.originPixelDow)
         {
            this.originPixelDow.cleanup();
            this.originPixelDow = null;
         }
         if(this.glow)
         {
            this.glow.cleanup();
            this.glow = null;
         }
         this.bubbles.cleanup();
         this.bubbles = null;
         if(this.caravanVars)
         {
            this.caravanVars.removeEventListener(VariableEvent.TYPE,this.caravanVarHandler);
         }
         if(this.saga)
         {
            this.saga.removeEventListener(SagaEvent.EVENT_SHOW_CARAVAN,this.sagaShowCaravanHandler);
         }
         this.spline = null;
         this.travel = null;
         this.travelView = null;
         for each(_loc1_ in this.anims)
         {
            if(_loc1_)
            {
               _loc1_.removeFromParent();
               _loc1_.cleanup();
            }
         }
         this.anims = null;
         this.apool.cleanup();
         this.apool = null;
         if(this.banner)
         {
            this.banner.anim.displayObjectWrapper.removeFromParent();
            this.banner.cleanup();
            this.banner = null;
         }
         if(this.br)
         {
            this.br.release();
            this.br = null;
         }
      }
      
      private function caravanVarHandler(param1:VariableEvent) : void
      {
         var _loc2_:Variable = param1.value;
         if(_loc2_.def.name == SagaVar.VAR_NUM_PEASANTS || _loc2_.def.name == SagaVar.VAR_NUM_VARL || _loc2_.def.name == SagaVar.VAR_NUM_FIGHTERS)
         {
            this.populationDirty = true;
         }
      }
      
      private function sagaShowCaravanHandler(param1:Event) : void
      {
         if(this.saga)
         {
            this.displayObjectWrapper.visible = this.saga.showCaravan;
         }
         else
         {
            this.displayObjectWrapper.visible = true;
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:DisplayObjectWrapper = null;
         if(!this.saga || this.saga.cleanedup)
         {
            return;
         }
         if(this.cleanedup || !this.travel || !this.travel.landscape || !this.travel.landscape.scene || !this.travel.landscape.scene._context)
         {
            return;
         }
         if(this._faller)
         {
            this._faller.update(param1);
         }
         this.drawCaravan();
         if(this.glow)
         {
            this.glow.update(param1);
         }
         this._fallerDirty = false;
         if(Boolean(this._faller) && this._faller.complete)
         {
            this.logger.info("faller complete!!!");
            this._fallerDirty = true;
            this._faller.cleanup();
            this._faller = null;
            this.saga.triggerTravelFallComplete();
         }
         if(this.saga && this.saga.paused || Boolean(this._faller))
         {
            return;
         }
         for each(_loc2_ in this.anims)
         {
            if(_loc2_)
            {
               if(_loc2_.visible)
               {
                  _loc2_.update(param1);
               }
            }
         }
      }
      
      final protected function fillOutType(param1:int, param2:int, param3:String, param4:Array) : Array
      {
         var _loc5_:int = 0;
         if(param1 > param2)
         {
            if(!param4)
            {
               param4 = [];
            }
            _loc5_ = param2;
            while(_loc5_ < param1)
            {
               param4.push(param3);
               _loc5_++;
            }
         }
         else if(param1 < param2)
         {
            this.truncateType(param1,param2,param3);
         }
         return param4;
      }
      
      public function resetTruncatedCarts() : void
      {
         if(this.truncatedCarts.length)
         {
            this.truncatedCarts.splice(0,this.truncatedCarts.length);
         }
      }
      
      private function truncateType(param1:int, param2:int, param3:String) : void
      {
         var _loc7_:Ati = null;
         var _loc8_:String = null;
         if(param1 >= param2)
         {
            return;
         }
         var _loc4_:Vector.<Point> = "world_cart_pop" == param3 ? this.truncatedCarts : null;
         var _loc5_:int = param2;
         var _loc6_:int = int(this.animTypes.length - 1);
         while(_loc6_ >= this.population_index && _loc5_ > param1)
         {
            _loc7_ = this.animTypes[_loc6_];
            _loc8_ = !!_loc7_ ? _loc7_.type.type : null;
            if(_loc8_ == param3)
            {
               this.animTypes.splice(_loc6_,1);
               this.removeAnim(_loc6_,_loc4_);
               _loc5_--;
            }
            _loc6_--;
         }
      }
      
      protected function addTypeAt(param1:String, param2:int, param3:Boolean) : void
      {
         if(param2 > this.animTypes.length)
         {
            throw new ArgumentError("addTypeAt " + param2 + " on len " + this.animTypes.length);
         }
         var _loc4_:CaravanViewTypeInfo = this.getTypeInfo(param1);
         if(!_loc4_)
         {
            throw new ArgumentError("invalid caravan anim type: " + param1);
         }
         var _loc5_:Ati = new Ati(_loc4_);
         if(param2 == this.animTypes.length)
         {
            this.animTypes.push(_loc5_);
         }
         else
         {
            this.animTypes.splice(param2,0,_loc5_);
         }
         this.addAnimation(param2,param3);
      }
      
      protected function removeTypeAt(param1:int, param2:Vector.<Point>) : void
      {
         this.animTypes.splice(param1,1);
         this.removeAnim(param1,param2);
      }
      
      private function removeAnim(param1:int, param2:Vector.<Point>) : void
      {
         var _loc3_:DisplayObjectWrapper = null;
         if(param1 < this.anims.length)
         {
            _loc3_ = this.anims[param1];
            if(_loc3_ != null)
            {
               if(_loc3_.hasParent)
               {
                  if(param2)
                  {
                     param2.push(new Point(_loc3_.x,_loc3_.y));
                  }
                  _loc3_.removeFromParent();
                  this.apool.reclaim(_loc3_);
               }
            }
            this.anims.splice(param1,1);
         }
      }
      
      private function removeAllAnims() : void
      {
         var _loc1_:int = 0;
         var _loc2_:DisplayObjectWrapper = null;
         if(this.anims.length)
         {
            _loc1_ = 0;
            while(_loc1_ < this.anims.length)
            {
               _loc2_ = this.anims[_loc1_];
               if(_loc2_ != null)
               {
                  if(_loc2_.hasParent)
                  {
                     _loc2_.removeFromParent();
                     this.apool.reclaim(_loc2_);
                  }
               }
               _loc1_++;
            }
            this.anims.splice(0,this.anims.length);
         }
      }
      
      final public function getTypeInfo(param1:String) : CaravanViewTypeInfo
      {
         return this.TYPE_INFOS[param1];
      }
      
      private function getAnimClipSpriteForType(param1:Ati, param2:Boolean) : DisplayObjectWrapper
      {
         var _loc5_:String = null;
         var _loc3_:CaravanViewTypeInfo = param1.type;
         var _loc4_:String = _loc3_.type;
         if(!_loc3_)
         {
            return null;
         }
         _loc5_ = this.getUrl(_loc4_,param1.index,param2 && _loc3_.has_idle);
         return this.apool.pop(_loc5_);
      }
      
      private function createNewAnims(param1:Boolean) : void
      {
         var _loc2_:int = int(this.anims.length);
         while(_loc2_ < this.animTypes.length)
         {
            this.addAnimation(_loc2_,param1);
            _loc2_++;
         }
      }
      
      final protected function randomizeAddedTypes(param1:Array) : void
      {
         var _loc2_:String = null;
         var _loc3_:CaravanViewTypeInfo = null;
         if(!param1)
         {
            return;
         }
         MathUtil.shuffle(param1);
         for each(_loc2_ in param1)
         {
            _loc3_ = this.TYPE_INFOS[_loc2_];
            this.animTypes.push(new Ati(_loc3_));
         }
      }
      
      private function addAnimation(param1:int, param2:Boolean) : void
      {
         var _loc5_:DisplayObjectWrapper = null;
         if(param1 > this.anims.length)
         {
            return;
         }
         var _loc3_:Ati = this.animTypes[param1];
         var _loc4_:String = _loc3_.type.type;
         _loc5_ = this.getAnimClipSpriteForType(_loc3_,param2);
         if(_loc5_)
         {
            this.layeringDirty = true;
            this.displayObjectWrapper.addChild(_loc5_);
         }
         else
         {
            this.logger.error("Missing animation type: \'" + _loc4_ + "\' for position " + param1);
         }
         if(param1 < this.anims.length)
         {
            this.anims.splice(param1,0,_loc5_);
         }
         else
         {
            this.anims.push(_loc5_);
         }
      }
      
      private function addOriginMarker() : void
      {
         if(!originPixel)
         {
            originPixel = new BitmapData(2,1,false,4294901760);
         }
         if(!this.originPixelDow)
         {
            this.originPixelDow = this.travelView.landscapeView.createBitmapDataWrapper(this,originPixel);
            this.displayObjectWrapper.addChild(this.originPixelDow);
            this.originPixelDow.scaleY = 1000;
         }
      }
      
      protected function checkAnims(param1:Boolean) : void
      {
      }
      
      protected function postCheckAnims() : void
      {
      }
      
      private function drawAnimCaravan(param1:Boolean) : void
      {
         if(!this.saga)
         {
            return;
         }
         if(this.apool.waiting)
         {
            return;
         }
         if(this.cleanedup || !this.travel || !this.travel.landscape || !this.travel.landscape.scene || !this.travel.landscape.scene._context)
         {
            return;
         }
         if(SHOW_ORIGIN_MARKER)
         {
            if(!this.originPixelDow)
            {
               this.addOriginMarker();
            }
         }
         this.checkGlow();
         this.checkAnims(param1);
         this.createNewAnims(param1);
         this.checkAnimLayering();
         this.alignAnimsToSpline();
      }
      
      private function checkGlow() : void
      {
         if(this.glow)
         {
            return;
         }
         if(!this.def.glow)
         {
            return;
         }
         this.glow = new CaravanViewGlow(this.def.glow,this.apool.resman);
         this.displayObjectWrapper.addChild(this.glow.dow);
      }
      
      private function checkAnimLayering() : void
      {
         var _loc2_:Ati = null;
         var _loc3_:CaravanViewTypeInfo = null;
         var _loc4_:String = null;
         var _loc5_:DisplayObjectWrapper = null;
         var _loc6_:int = 0;
         if(!this.layeringDirty)
         {
            return;
         }
         this.drawn = false;
         this.layeringDirty = false;
         var _loc1_:int = 0;
         while(_loc1_ < this.animTypes.length && _loc1_ < this.anims.length)
         {
            _loc2_ = this.animTypes[_loc1_];
            _loc3_ = _loc2_.type;
            _loc4_ = _loc2_.type.type;
            _loc5_ = this.anims[_loc1_];
            if(_loc5_)
            {
               if(_loc3_.front)
               {
                  this.displayObjectWrapper.removeChild(_loc5_);
                  this.displayObjectWrapper.addChild(_loc5_);
               }
               else if(_loc3_.back >= 0)
               {
                  this.displayObjectWrapper.removeChild(_loc5_);
                  _loc6_ = Math.min(_loc3_.back + this.backLayer,this.displayObjectWrapper.numChildren);
                  this.displayObjectWrapper.addChildAt(_loc5_,_loc6_);
               }
            }
            _loc1_++;
         }
      }
      
      private function alignOriginToSpline() : void
      {
         if(!this.originPixelDow)
         {
            return;
         }
         var _loc1_:Number = this.caravan_t;
         this.mid_pt.setTo(0,0);
         this.spline.sample(_loc1_,this.mid_pt);
         this.originPixelDow.x = this.mid_pt.x;
         this.originPixelDow.y = this.mid_pt.y - 500;
      }
      
      private function alignAnimsToSpline() : void
      {
         var _loc6_:DisplayObjectWrapper = null;
         var _loc7_:Ati = null;
         var _loc8_:String = null;
         var _loc9_:CaravanViewTypeInfo = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Boolean = false;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         if(this.originPixelDow)
         {
            this.alignOriginToSpline();
         }
         this.caravan_end_t = 0;
         this.caravan_start_t = -1;
         this.front_pt.setTo(0,0);
         this.back_pt.setTo(0,0);
         this.mid_pt.setTo(0,0);
         var _loc1_:Number = this.caravan_t + this.render_start_t_delta;
         var _loc2_:BoundedCamera = this.travelView.travel.landscape.camera;
         var _loc3_:Number = _loc2_.x - _loc2_.width / 2;
         var _loc4_:Number = _loc2_.x + _loc2_.width / 2;
         var _loc5_:int = 0;
         while(_loc5_ < this.anims.length)
         {
            if(this.animSplineTs.length < _loc5_)
            {
               this.animSplineTs.push(0);
            }
            this.animSplineTs[_loc5_] = 0;
            _loc6_ = this.anims[_loc5_];
            if(_loc6_)
            {
               _loc7_ = this.animTypes[_loc5_];
               _loc8_ = _loc7_.type.type;
               _loc9_ = _loc7_.type;
               if(_loc9_)
               {
                  _loc1_ -= _loc9_.gap_lead * this.spline.ooTotalLength;
                  _loc10_ = _loc1_;
                  _loc1_ -= _loc9_.gap_tail * this.spline.ooTotalLength;
                  if(_loc6_.anim)
                  {
                     _loc11_ = _loc10_ + _loc9_.foot_lead * this.spline.ooTotalLength;
                     _loc12_ = _loc10_ - _loc9_.foot_tail * this.spline.ooTotalLength;
                     this.spline.sample(_loc11_,this.front_pt);
                     this.spline.sample(_loc12_,this.back_pt);
                     _loc13_ = false;
                     if(this.rightward)
                     {
                        _loc13_ = this.front_pt.x < _loc3_ || this.back_pt.x > _loc4_;
                     }
                     else
                     {
                        _loc13_ = this.back_pt.x < _loc3_ || this.front_pt.x > _loc4_;
                     }
                     if(this.caravan_start_t < 0)
                     {
                        this.caravan_start_t = _loc11_;
                     }
                     this.caravan_end_t = _loc12_;
                     if(_loc13_)
                     {
                        _loc6_.visible = false;
                     }
                     else
                     {
                        _loc6_.visible = true;
                        this.spline.sample(_loc10_,this.mid_pt);
                        this.animSplineTs[_loc5_] = _loc10_;
                        _loc6_.x = this.mid_pt.x;
                        _loc14_ = this.mid_pt.y;
                        if(this._faller)
                        {
                           _loc14_ -= this._faller.getFallDeltaY(_loc8_);
                        }
                        _loc6_.y = _loc14_;
                        if(this.glow)
                        {
                           if(_loc8_ == this.glow.def.center_anim)
                           {
                              this.glow_pt.setTo(_loc6_.x,_loc6_.y);
                           }
                        }
                        if(this.saga.halted && this.travel.def.close)
                        {
                           _loc6_.animSpeedFactor = 0.5;
                        }
                        else
                        {
                           _loc6_.animSpeedFactor = this.caravan_speedMult;
                        }
                        _loc15_ = this.front_pt.x - this.back_pt.x;
                        _loc16_ = this.front_pt.y - this.back_pt.y;
                        if(!this.rightward)
                        {
                           _loc15_ = -_loc15_;
                           _loc16_ = -_loc16_;
                           _loc6_.scaleX = -1;
                        }
                        else
                        {
                           _loc6_.scaleX = 1;
                        }
                        if(!this.def || this.def.allowRotation)
                        {
                           _loc17_ = Math.atan2(_loc16_,_loc15_);
                           if(this._faller)
                           {
                              if(!this.glow || _loc8_ != this.glow.def.center_anim)
                              {
                                 _loc17_ = this._faller.computeAngle(_loc17_,_loc8_);
                              }
                           }
                           _loc6_.rotationRadians = _loc17_;
                        }
                     }
                  }
               }
            }
            _loc5_++;
         }
      }
      
      final protected function computeStartT() : void
      {
         var _loc2_:Ati = null;
         var _loc3_:String = null;
         var _loc4_:CaravanViewTypeInfo = null;
         this.render_start_t_delta = 0;
         if(this.def.alignFrontWithTravelPosition)
         {
            return;
         }
         var _loc1_:int = 0;
         while(_loc1_ < this.animTypes.length && _loc1_ < this.num_heroes + 2)
         {
            _loc2_ = this.animTypes[_loc1_];
            _loc3_ = _loc2_.type.type;
            _loc4_ = _loc2_.type;
            if(_loc4_)
            {
               this.render_start_t_delta += _loc4_.gap_lead + _loc4_.gap_tail;
            }
            _loc1_++;
         }
         this.render_start_t_delta *= this.spline.ooTotalLength;
      }
      
      final private function drawCaravan() : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc1_:int = this.travel.forward ? 1 : -1;
         this.caravan_speedMult = this.travel.speedFactor * this.travel.speed;
         if(!this.saga)
         {
            return;
         }
         if(this.travel.position != this.last_position || this._faller || this._fallerDirty)
         {
            this.caravan_t = this.travel.position * this.spline.ooTotalLength;
            this.spline.sample(this.caravan_t,this.caravan_pt);
            this.travel.caravan_pt.setTo(this.caravan_pt.x,this.caravan_pt.y);
            this.glow_pt.setTo(this.caravan_pt.x,this.caravan_pt.y);
         }
         var _loc2_:BoundedCamera = this.travelView.landscapeView.camera;
         _loc2_.caravanCameraLocked = false;
         if(_loc2_.drift)
         {
            if(!this.travel.allowCameraCaravanAnchor)
            {
               if(_loc2_.caravanCameraLocked)
               {
                  _loc2_.caravanCameraLocked = false;
                  _loc2_.drift.anchor = null;
               }
            }
            else if(!this.saga.cameraPanning)
            {
               if(this.saga.caravanCameraLock && !this.saga.camped)
               {
                  _loc2_.caravanCameraLocked = true;
                  _loc2_.drift.anchor = null;
                  _loc2_.setPosition(this.caravan_pt.x,this.caravan_pt.y);
               }
               else
               {
                  if(!_loc2_.drift.anchor && !this._cameraSet)
                  {
                     _loc2_.setPosition(this.caravan_pt.x,this.caravan_pt.y);
                  }
                  _loc2_.caravanCameraLocked = false;
                  _loc2_.drift.anchor = this.caravan_pt;
               }
            }
            this._cameraSet = true;
         }
         if(this.saga.showCaravan)
         {
            _loc3_ = this.travel.def.close && this._wasHalted != this.saga.halted;
            _loc4_ = !this.drawn || this.populationDirty;
            _loc4_ = _loc4_ || _loc1_ != this.last_direction;
            _loc4_ = _loc4_ || this.travel.position != this.last_position;
            _loc4_ = _loc4_ || Boolean(this._faller) || this._fallerDirty;
            _loc4_ = _loc4_ || this.caravan_speedMult != this.last_speedMult;
            _loc4_ = _loc4_ || this.last_camera_x != this.travel.landscape.camera.x;
            _loc4_ = _loc4_ || _loc3_;
            if(_loc4_)
            {
               if(_loc3_)
               {
                  this.removeAllAnims();
               }
               this.drawAnimCaravan(this.travel.def.close && this.saga.halted);
            }
            this.populationDirty = false;
            this.drawn = true;
         }
         this._wasHalted = this.saga.halted;
         this.last_camera_x = this.travel.landscape.camera.x;
         this.last_direction = _loc1_;
         this.last_position = this.travel.position;
         this.last_speedMult = this.caravan_speedMult;
         this.drawGlow();
         this.postCheckAnims();
      }
      
      private function drawGlow() : void
      {
         if(this.glow)
         {
            this.displayObjectWrapper.setChildIndex(this.glow.dow,0);
            this.glow.setPos(this.glow_pt.x,this.glow_pt.y);
         }
      }
      
      protected function forceDrawAnimCaravan() : void
      {
         this.drawAnimCaravan(this.travel.def.close && this.saga.halted);
      }
      
      public function handleSpeak(param1:SpeakEvent, param2:String) : Boolean
      {
         if(this.bubbles)
         {
            return this.bubbles.handleSpeak(param1,param2);
         }
         return false;
      }
      
      public function getRelativeHeroPosition(param1:String) : Number
      {
         return 0;
      }
      
      public function isTravelFalling() : Boolean
      {
         return Boolean(this._faller) && !this._faller.complete;
      }
   }
}
