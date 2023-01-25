package engine.landscape.def
{
   import engine.anim.def.AnimLibrary;
   import engine.landscape.travel.def.ITravelDef;
   import engine.landscape.travel.def.TravelDef;
   import engine.landscape.travel.def.TravelLocator;
   import engine.scene.def.ISceneDef;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class LandscapeDef extends EventDispatcher implements ILandscapeDef
   {
      
      public static const EVENT_BOUNDARY_CHANGED:String = "LandscapeDef.EVENT_BOUNDARY_CHANGED";
      
      public static var EVENT_LAYERS:String = "LandscapeDef.EVENT_LAYERS";
      
      public static var EVENT_LAYERS_EDITOR_HIDDEN:String = "LandscapeDef.EVENT_LAYERS_EDITOR_HIDDEN";
       
      
      public var layers:Vector.<LandscapeLayerDef>;
      
      public var maxSpeed:Number;
      
      private var _boundary:Rectangle;
      
      public var anims:AnimLibrary;
      
      public var labelFontFace:String = "Vinque";
      
      public var labelFontSize:int = 30;
      
      public var labelFontColor:uint = 2561808;
      
      public var hasFog:Boolean = false;
      
      public var fogColor:uint = 0;
      
      public var fogAlpha:Number = 0;
      
      private var layerName2Layer:Dictionary;
      
      public var clickables:Vector.<LandscapeSpriteDef>;
      
      public var helps:Vector.<LandscapeSpriteDef>;
      
      public var travels:Vector.<ITravelDef>;
      
      public var highQuality:Boolean = false;
      
      public var _sceneDef:ISceneDef;
      
      public var hasTooltips:Boolean;
      
      public function LandscapeDef(param1:ISceneDef)
      {
         this.layers = new Vector.<LandscapeLayerDef>();
         this.clickables = new Vector.<LandscapeSpriteDef>();
         this.helps = new Vector.<LandscapeSpriteDef>();
         super();
         this._sceneDef = param1;
      }
      
      public function cleanup() : void
      {
         var _loc1_:LandscapeLayerDef = null;
         for each(_loc1_ in this.layers)
         {
            _loc1_.cleanup();
         }
         this.layers = null;
         this.clickables = null;
         this.helps = null;
         this.travels = null;
      }
      
      public function getTravelDef(param1:int) : ITravelDef
      {
         return this.travels[param1];
      }
      
      public function get firstTravelDef() : ITravelDef
      {
         return Boolean(this.travels) && Boolean(this.travels.length) ? this.travels[0] : null;
      }
      
      public function getTravelDefById(param1:String) : ITravelDef
      {
         var _loc2_:ITravelDef = null;
         for each(_loc2_ in this.travels)
         {
            if(_loc2_.getId() == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getTravelDefForLocator(param1:TravelLocator) : ITravelDef
      {
         var _loc2_:TravelDef = null;
         if(this.travels)
         {
            if(param1.travel_id)
            {
               return this.getTravelDefById(param1.travel_id);
            }
            if(!param1.travel_location)
            {
               return Boolean(this.travels) && Boolean(this.travels.length) ? this.travels[0] : null;
            }
            for each(_loc2_ in this.travels)
            {
               if(_loc2_.findLocationById(param1.travel_location))
               {
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      public function get numTravelDefs() : int
      {
         return !!this.travels ? int(this.travels.length) : 0;
      }
      
      public function getSplineDef(param1:String) : LandscapeSplineDef
      {
         var _loc2_:LandscapeLayerDef = null;
         var _loc3_:LandscapeSplineDef = null;
         for each(_loc2_ in this.layers)
         {
            _loc3_ = _loc2_.getSplineDef(param1);
            if(_loc3_)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function get numLayerDefs() : int
      {
         return this.layers.length;
      }
      
      public function getLayerDef(param1:int) : ILandscapeLayerDef
      {
         return this.layers[param1];
      }
      
      public function createNewLayerDef(param1:int, param2:String) : LandscapeLayerDef
      {
         var _loc3_:LandscapeLayerDef = new LandscapeLayerDef(this);
         _loc3_.nameId = param2;
         if(param1 < 0)
         {
            this.layers.push(_loc3_);
         }
         else
         {
            this.layers.splice(param1,0,_loc3_);
         }
         dispatchEvent(new Event(EVENT_LAYERS));
         return _loc3_;
      }
      
      public function deleteLayerDef(param1:int) : LandscapeLayerDef
      {
         var _loc2_:LandscapeLayerDef = this.layers[param1];
         this.layers.splice(param1,1);
         dispatchEvent(new Event(EVENT_LAYERS));
         return _loc2_;
      }
      
      public function resolveLandscapeDef() : void
      {
         this.cacheLayerNames();
         this.cacheClickables();
         this.cacheHelps();
      }
      
      private function cacheLayerNames() : void
      {
         var _loc1_:LandscapeLayerDef = null;
         if(!this.layerName2Layer)
         {
            this.layerName2Layer = new Dictionary();
            for each(_loc1_ in this.layers)
            {
               this.layerName2Layer[_loc1_.nameId] = _loc1_;
            }
         }
      }
      
      private function cacheClickables() : void
      {
         var _loc1_:LandscapeLayerDef = null;
         var _loc2_:LandscapeSpriteDef = null;
         for each(_loc1_ in this.layers)
         {
            for each(_loc2_ in _loc1_.layerSprites)
            {
               if(_loc2_.clickable)
               {
                  this.clickables.push(_loc2_);
               }
            }
         }
      }
      
      private function cacheHelps() : void
      {
         var _loc1_:LandscapeLayerDef = null;
         var _loc2_:LandscapeSpriteDef = null;
         for each(_loc1_ in this.layers)
         {
            for each(_loc2_ in _loc1_.layerSprites)
            {
               if(_loc2_.help)
               {
                  this.helps.push(_loc2_);
               }
            }
         }
      }
      
      public function findClickable(param1:String) : ILandscapeSpriteDef
      {
         var _loc2_:LandscapeSpriteDef = null;
         for each(_loc2_ in this.clickables)
         {
            if(_loc2_.nameId == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getLayer(param1:String) : ILandscapeLayerDef
      {
         if(!this.layerName2Layer)
         {
            this.cacheLayerNames();
         }
         return this.layerName2Layer[param1];
      }
      
      public function getSpriteDef(param1:String) : ILandscapeSpriteDef
      {
         var _loc2_:int = param1.indexOf(".");
         var _loc3_:String = param1.substring(0,_loc2_);
         var _loc4_:String = param1.substring(_loc2_ + 1);
         var _loc5_:ILandscapeLayerDef = this.getLayer(_loc3_);
         return _loc5_.getSprite(_loc4_);
      }
      
      public function get boundary() : Rectangle
      {
         return this._boundary;
      }
      
      public function set boundary(param1:Rectangle) : void
      {
         if(this._boundary == param1)
         {
            return;
         }
         this._boundary = param1;
         dispatchEvent(new Event(EVENT_BOUNDARY_CHANGED));
      }
      
      public function promoteLayer(param1:LandscapeLayerDef) : void
      {
         var _loc2_:int = this.layers.indexOf(param1);
         if(_loc2_ > 0)
         {
            this.layers.splice(_loc2_,1);
            this.layers.splice(_loc2_ - 1,0,param1);
         }
      }
      
      public function demoteLayer(param1:LandscapeLayerDef) : void
      {
         var _loc2_:int = this.layers.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this.layers.length - 1)
         {
            this.layers.splice(_loc2_,1);
            this.layers.splice(_loc2_ + 1,0,param1);
         }
      }
      
      public function getWalkLayerDef() : LandscapeLayerDef
      {
         var _loc1_:LandscapeLayerDef = null;
         for each(_loc1_ in this.layers)
         {
            if(_loc1_.speed == 1)
            {
               return _loc1_;
            }
         }
         return null;
      }
      
      public function notifyLayersEditorHidden() : void
      {
         dispatchEvent(new Event(EVENT_LAYERS_EDITOR_HIDDEN));
      }
      
      public function notifySpriteChanged_tooltip(param1:LandscapeSpriteDef) : void
      {
         dispatchEvent(new LandscapeDefEvent(LandscapeDefEvent.SPRITE_TOOLTIP,param1));
      }
      
      public function cropToBoundary(param1:String, param2:Number, param3:Number, param4:Number, param5:Number) : Dictionary
      {
         var _loc19_:LandscapeLayerDef = null;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Rectangle = null;
         var _loc6_:Dictionary = new Dictionary();
         var _loc7_:Number = param2 / 2;
         var _loc8_:Number = param3 / 2;
         var _loc9_:Number = param4 / 2;
         var _loc10_:Number = param5 / 2;
         var _loc11_:Number = this.boundary.left + _loc7_;
         var _loc12_:Number = this.boundary.right - _loc7_;
         var _loc13_:Number = this.boundary.top + _loc8_;
         var _loc14_:Number = this.boundary.bottom - _loc8_;
         var _loc15_:Number = this.boundary.left + _loc9_;
         var _loc16_:Number = this.boundary.right - _loc9_;
         var _loc17_:Number = this.boundary.top + _loc10_;
         var _loc18_:Number = this.boundary.bottom - _loc10_;
         for each(_loc19_ in this.layers)
         {
            _loc20_ = _loc19_.speed;
            _loc21_ = _loc11_ * _loc20_ - _loc7_;
            _loc22_ = _loc12_ * _loc20_ + _loc7_;
            _loc23_ = _loc13_ * _loc20_ - _loc8_;
            _loc24_ = _loc14_ * _loc20_ + _loc8_;
            _loc21_ = Math.min(_loc21_,_loc15_ * _loc20_ - _loc9_);
            _loc22_ = Math.max(_loc22_,_loc16_ * _loc20_ + _loc9_);
            _loc23_ = Math.min(_loc23_,_loc17_ * _loc20_ - _loc10_);
            _loc24_ = Math.max(_loc24_,_loc18_ * _loc20_ + _loc10_);
            _loc25_ = new Rectangle(_loc21_,_loc23_,_loc22_ - _loc21_,_loc24_ - _loc23_);
            _loc25_.x -= _loc19_.offset.x;
            _loc25_.y -= _loc19_.offset.y;
            _loc19_.cropToBoundary(param1,_loc25_,_loc6_);
         }
         return _loc6_;
      }
      
      public function reduceTextures(param1:String, param2:Number) : Dictionary
      {
         var _loc4_:LandscapeLayerDef = null;
         var _loc3_:Dictionary = new Dictionary();
         for each(_loc4_ in this.layers)
         {
            _loc4_.reduceTextures(param1,param2,_loc3_);
         }
         return _loc3_;
      }
      
      public function tileLandscapeBitmaps(param1:String) : Array
      {
         var _loc3_:LandscapeLayerDef = null;
         var _loc2_:Array = new Array();
         for each(_loc3_ in this.layers)
         {
            _loc3_.tileLayerBitmaps(param1,_loc2_);
         }
         return _loc2_;
      }
      
      public function get sceneDef() : ISceneDef
      {
         return this._sceneDef;
      }
      
      public function getTravels() : Vector.<ITravelDef>
      {
         return this.travels;
      }
      
      public function get numClickables() : int
      {
         return this.clickables.length;
      }
      
      public function getClickableAt(param1:int) : ILandscapeSpriteDef
      {
         return this.clickables[param1];
      }
      
      public function visitClickables(param1:Function) : void
      {
         var _loc2_:ILandscapeSpriteDef = null;
         for each(_loc2_ in this.clickables)
         {
            param1(_loc2_);
         }
      }
      
      public function resolveLayers() : void
      {
         var _loc1_:LandscapeLayerDef = null;
         for each(_loc1_ in this.layers)
         {
            _loc1_.resolveLayer();
         }
      }
   }
}
