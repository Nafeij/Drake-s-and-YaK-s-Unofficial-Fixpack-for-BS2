package engine.landscape.model
{
   import engine.core.render.BoundedCamera;
   import engine.landscape.ILandscapeContext;
   import engine.landscape.def.ILandscapeDef;
   import engine.landscape.def.ILandscapeLayerDef;
   import engine.landscape.def.LandscapeDef;
   import engine.landscape.def.LandscapeLayerDef;
   import engine.landscape.travel.def.TravelDef;
   import engine.landscape.travel.def.TravelLocator;
   import engine.landscape.travel.model.LandscapeParamControl;
   import engine.landscape.travel.model.Travel;
   import engine.landscape.travel.model.Travel_FallData;
   import engine.scene.model.Scene;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class Landscape extends EventDispatcher
   {
      
      public static const EVENT_ENABLE_HOVER:String = "Landscape.EVENT_ENABLE_HOVER";
      
      public static var TRAVEL_ENABLED:Boolean = true;
      
      public static var EDITOR_MODE:Boolean = false;
       
      
      public var def:LandscapeDef;
      
      public var camera:BoundedCamera;
      
      public var context:ILandscapeContext;
      
      public var travel:Travel;
      
      public var scene:Scene;
      
      private var _enableHover:Boolean;
      
      public var layers:Dictionary;
      
      private var _layerVis:ILandscapeLayerVisibility;
      
      public var travelChangedViewCallback:Function;
      
      public var paramControlsById:Dictionary;
      
      private var _clampParallax:Boolean = true;
      
      private var _enableParallax:Boolean = true;
      
      private var parallax_dx:Number = 0;
      
      private var parallax_dy:Number = 0;
      
      private var unclamped_dx:Number = 0;
      
      private var unclamped_dy:Number = 0;
      
      public function Landscape(param1:Scene, param2:ILandscapeDef, param3:ILandscapeContext, param4:BoundedCamera, param5:TravelLocator, param6:Travel_FallData)
      {
         var _loc7_:TravelDef = null;
         this.layers = new Dictionary();
         super();
         if(!param2)
         {
            throw new ArgumentError("No def");
         }
         param2.addEventListener(LandscapeDef.EVENT_LAYERS,this.layersHandler);
         this.scene = param1;
         this.def = param2 as LandscapeDef;
         this.context = param3;
         this.camera = param4;
         if(param2.numTravelDefs && TRAVEL_ENABLED && Boolean(param5))
         {
            _loc7_ = this.def.getTravelDefForLocator(param5) as TravelDef;
            if(!_loc7_)
            {
               param3.logger.error("Failed to find traveldef for landscape [" + param1._def.url + "] locator [" + param5 + "]");
               this.def.getTravelDefForLocator(param5);
            }
            else
            {
               this.setTravelDef(_loc7_,param5,param6);
            }
         }
      }
      
      public function getLandscapeParamControlById(param1:String) : LandscapeParamControl
      {
         var _loc2_:LandscapeParamControl = null;
         if(this.travel)
         {
            _loc2_ = this.travel.getTravelParamControlById(param1);
            if(_loc2_)
            {
               return _loc2_;
            }
         }
         return !!this.paramControlsById ? this.paramControlsById[param1] : null;
      }
      
      public function setTravelDef(param1:TravelDef, param2:TravelLocator, param3:Travel_FallData) : void
      {
         if(Boolean(this.travel) && this.travel.def != param1)
         {
            this.travel.cleanup();
            this.travel = null;
         }
         if(param1)
         {
            this.travel = new Travel(this,param1,param2,param3);
         }
         if(this.travelChangedViewCallback != null)
         {
            this.travelChangedViewCallback(this);
         }
      }
      
      public function cleanup() : void
      {
         this.def.removeEventListener(LandscapeDef.EVENT_LAYERS,this.layersHandler);
         this.travelChangedViewCallback = null;
         this.def = null;
         this.context = null;
         this.camera = null;
         if(this.travel)
         {
            this.travel.cleanup();
            this.travel = null;
         }
      }
      
      private function layersHandler(param1:Event) : void
      {
         this.layers = new Dictionary();
         this.updateDelta();
      }
      
      public function update(param1:int) : void
      {
         this.updateDelta();
         if(this.travel)
         {
            this.travel.update(param1);
         }
      }
      
      public function suppressTravel() : void
      {
         if(this.travel)
         {
            this.travel.cleanup();
            this.travel = null;
         }
      }
      
      public function get enableHover() : Boolean
      {
         return this._enableHover;
      }
      
      public function set enableHover(param1:Boolean) : void
      {
         this._enableHover = param1;
         dispatchEvent(new Event(EVENT_ENABLE_HOVER));
      }
      
      public function get clampParallax() : Boolean
      {
         return this._clampParallax;
      }
      
      public function set clampParallax(param1:Boolean) : void
      {
         if(this._clampParallax == param1)
         {
            return;
         }
         this._clampParallax = param1;
         this.camera._clampParallax = param1;
         this.camera.boundsDisabled = !param1;
         this.updateDelta();
      }
      
      public function get enableParallax() : Boolean
      {
         return this._enableParallax;
      }
      
      public function set enableParallax(param1:Boolean) : void
      {
         if(this._enableParallax == param1)
         {
            return;
         }
         this._enableParallax = param1;
         this.updateDelta();
      }
      
      public function prepareUpdateDelta() : void
      {
         var _loc1_:BoundedCamera = this.camera;
         this.parallax_dx = _loc1_.panClamped.x;
         this.parallax_dy = _loc1_.panClamped.y;
         this.unclamped_dx = 0;
         this.unclamped_dy = 0;
         if(this._enableParallax)
         {
            if(this._clampParallax)
            {
               this.parallax_dx = _loc1_.clampX(this.parallax_dx,false);
               this.parallax_dy = _loc1_.clampY(this.parallax_dy,false);
            }
            if(EDITOR_MODE)
            {
               this.unclamped_dx = _loc1_.x - this.parallax_dx;
               this.unclamped_dy = _loc1_.y - this.parallax_dy;
            }
            else
            {
               this.unclamped_dx = _loc1_.panClamped.x - this.parallax_dx;
               this.unclamped_dy = _loc1_.panClamped.y - this.parallax_dy;
            }
         }
         else
         {
            this.parallax_dx = 0;
            this.parallax_dy = 0;
            this.unclamped_dx = _loc1_.x;
            this.unclamped_dy = _loc1_.y;
         }
      }
      
      public function modifyTransitoryLayer(param1:String, param2:Number, param3:Number) : void
      {
         var _loc4_:LandscapeLayerDef = this.def.getLayer(param1) as LandscapeLayerDef;
         if(_loc4_)
         {
            _loc4_.transitory.setTo(param2,param3);
            this.prepareUpdateDelta();
            this.updateDeltaLayer(_loc4_);
         }
      }
      
      public function getLayerByDef(param1:ILandscapeLayerDef) : LandscapeLayer
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:LandscapeLayer = this.layers[param1];
         if(!_loc2_)
         {
            _loc2_ = new LandscapeLayer(this,param1 as LandscapeLayerDef);
            this.layers[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      public function getLayerByName(param1:String) : LandscapeLayer
      {
         var _loc2_:ILandscapeLayerDef = this.def.getLayer(param1);
         return this.getLayerByDef(_loc2_);
      }
      
      public function updateDeltaLayer(param1:ILandscapeLayerDef) : void
      {
         var _loc2_:LandscapeLayerDef = param1 as LandscapeLayerDef;
         var _loc3_:Number = this._enableParallax ? _loc2_.speed : 1;
         var _loc4_:LandscapeLayer = this.getLayerByDef(_loc2_);
         _loc4_.offset.x = _loc2_.offset.x + _loc2_.transitory.x - _loc3_ * this.parallax_dx - this.unclamped_dx;
         _loc4_.offset.y = _loc2_.offset.y + _loc2_.transitory.y - _loc3_ * this.parallax_dy - this.unclamped_dy;
      }
      
      public function updateDelta() : void
      {
         var _loc2_:ILandscapeLayerDef = null;
         this.prepareUpdateDelta();
         var _loc1_:int = 0;
         while(_loc1_ < this.def.numLayerDefs)
         {
            _loc2_ = this.def.getLayerDef(_loc1_);
            this.updateDeltaLayer(_loc2_);
            _loc1_++;
         }
      }
      
      public function start() : void
      {
         if(this.travel)
         {
            this.travel.start();
         }
      }
      
      public function get layerVis() : ILandscapeLayerVisibility
      {
         return this._layerVis;
      }
      
      public function set layerVis(param1:ILandscapeLayerVisibility) : void
      {
         if(this._layerVis == param1)
         {
            return;
         }
         this._layerVis = param1;
         if(this.scene.audio)
         {
            this.scene.audio.makeDirty();
         }
      }
      
      public function centerOnLocation(param1:Number, param2:Number) : void
      {
         var _loc3_:BoundedCamera = this.camera;
         var _loc4_:Number = _loc3_.zoom;
         _loc4_ = 1;
         _loc3_.setPosition(param1,param2);
         _loc3_.enableDrift = true;
         _loc3_.drift.anchorSpeed = 2500 * _loc4_;
         _loc3_.drift.anchor = new Point(param1,param2);
      }
   }
}
