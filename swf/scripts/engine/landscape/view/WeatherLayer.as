package engine.landscape.view
{
   import engine.core.logging.ILogger;
   import engine.core.render.BoundedCamera;
   import engine.landscape.model.LandscapeLayer;
   import engine.resource.ResourceGroup;
   import flash.display.BlendMode;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class WeatherLayer
   {
      
      public static var LAYER_SCALE:Number = 1;
       
      
      public var fog:WeatherLayer_Fog;
      
      public var snow:WeatherLayer_Particles;
      
      public var rain:WeatherLayer_Particles;
      
      public var gust:WeatherLayer_Particles;
      
      public var spark:WeatherLayer_Blinkers;
      
      public var group:ResourceGroup;
      
      public var lv:ILandscapeView;
      
      public var manager:WeatherManager;
      
      public var category:int;
      
      public var layer:LandscapeLayer;
      
      public var present:DisplayObjectWrapper;
      
      private var spawn_ordinal:int;
      
      public var lastOffset:Point;
      
      public var logger:ILogger;
      
      public var providers:Dictionary;
      
      public var dstr:String;
      
      protected var _blendModes:Vector.<String>;
      
      public var _lastCameraWidth:Number = 0;
      
      public var _lastCameraHeight:Number = 0;
      
      public var left:Number = 0;
      
      public var right:Number = 0;
      
      public var top:Number = 0;
      
      public var bottom:Number = 0;
      
      public function WeatherLayer(param1:WeatherManager, param2:ILandscapeView, param3:int, param4:LandscapeLayer)
      {
         this.lastOffset = new Point();
         this.providers = new Dictionary();
         this._blendModes = new Vector.<String>();
         super();
         this.manager = param1;
         this.category = param3;
         this.layer = param4;
         this._blendModes.push(BlendMode.NORMAL);
         this._blendModes.push(BlendMode.ADD);
         var _loc5_:String = param4 && param4.def && param4.def.landscape && Boolean(param4.def.landscape._sceneDef) ? param4.def.landscape._sceneDef.url : "noscene";
         var _loc6_:String = Boolean(param4) && Boolean(param4.def) ? param4.def.nameId : "nolayer";
         this.dstr = _loc5_ + " " + _loc6_;
         this.logger = param1.logger;
         this.lv = param2;
         this.group = new ResourceGroup(this,param2.logger);
         this.fog = new WeatherLayer_Fog(this);
         this.snow = new WeatherLayer_Particles(this,param1.snow);
         this.rain = new WeatherLayer_Particles(this,param1.rain);
         this.gust = new WeatherLayer_Particles(this,param1.gust);
         this.spark = new WeatherLayer_Blinkers(this,param1.spark,BlendMode.ADD);
         this.present = this.handleCreatePresent();
         param1.registerSnowLayer(this);
         this.snow.computeDensity();
         this.group.addResourceGroupListener(this.groupHandler);
      }
      
      public function toString() : String
      {
         return "[WeatherLayer " + this.category + " " + this.dstr + "]";
      }
      
      public function cleanup() : void
      {
         this.snow.cleanup();
         this.rain.cleanup();
         this.fog.cleanup();
         this.gust.cleanup();
         this.spark.cleanup();
         this.snow = null;
         this.rain = null;
         this.fog = null;
         this.gust = null;
         this.spark = null;
         if(this.present)
         {
            this.present.release();
            this.present = null;
         }
         if(this.group)
         {
            this.group.removeResourceGroupListener(this.groupHandler);
            this.group.release();
            this.group = null;
         }
         this.layer = null;
         this.manager = null;
         this.layer = null;
         this._blendModes = null;
      }
      
      protected function handleCreatePresent() : DisplayObjectWrapper
      {
         return null;
      }
      
      public function handleRemoveWeatherParticleBmp(param1:IWeatherParticleBmp) : void
      {
      }
      
      public function handleAddWeatherParticleBmp(param1:IWeatherParticleBmp) : void
      {
      }
      
      protected function handleBitmapsLoaded() : void
      {
      }
      
      public function handleCreateOneWeatherParticleBmp(param1:WeatherLayer_Particles, param2:int, param3:Number, param4:Number, param5:String) : IWeatherParticleBmp
      {
         return null;
      }
      
      final private function groupHandler(param1:Event) : void
      {
         this.group.removeResourceGroupListener(this.groupHandler);
         this.snow.handleLoaded();
         this.rain.handleLoaded();
         this.gust.handleLoaded();
         this.spark.handleLoaded();
         this.handleBitmapsLoaded();
      }
      
      final public function get visible() : Boolean
      {
         return this.present.visible;
      }
      
      final public function set visible(param1:Boolean) : void
      {
         this.present.visible = param1;
      }
      
      final private function resetWeather() : void
      {
         if(!this.group.complete)
         {
            return;
         }
         if(this.layer)
         {
            this.present.x = this.layer.offset.x;
            this.present.y = this.layer.offset.y;
         }
         this.lastOffset.setTo(this.present.x,this.present.y);
         this.spawn_ordinal = this.manager.spawn_ordinal;
         this.snow.resetParticles();
         this.rain.resetParticles();
         this.gust.resetParticles();
         this.spark.resetParticles();
      }
      
      protected function handleCameraSizeChange() : void
      {
      }
      
      protected function handleCameraPositionChange() : void
      {
      }
      
      public function handleFogChange() : void
      {
      }
      
      public function update(param1:int) : void
      {
         param1 = Math.min(100,param1);
         var _loc2_:BoundedCamera = this.lv.camera;
         var _loc3_:int = Math.max(_loc2_.minWidth,Math.min(_loc2_.maxWidth,_loc2_.width / _loc2_.scale));
         var _loc4_:int = Math.max(_loc2_.minHeight,Math.min(_loc2_.maxHeight,_loc2_.height / _loc2_.scale));
         _loc3_ *= LAYER_SCALE;
         _loc4_ *= LAYER_SCALE;
         this.left = -_loc3_ / 2;
         this.right = _loc3_ / 2;
         this.top = -_loc4_ / 2;
         this.bottom = _loc4_ / 2;
         if(_loc3_ != this._lastCameraWidth || _loc4_ != this._lastCameraHeight)
         {
            this._lastCameraWidth = _loc3_;
            this._lastCameraHeight = _loc4_;
            this.handleCameraSizeChange();
         }
         if(this.layer)
         {
            this.present.x = this.layer.offset.x;
            this.present.y = this.layer.offset.y;
         }
         var _loc5_:Number = this.present.x - this.lastOffset.x;
         var _loc6_:Number = this.present.y - this.lastOffset.y;
         if(this.lastOffset.x != this.present.x || this.lastOffset.y != this.present.y)
         {
            this.handleCameraPositionChange();
         }
         this.lastOffset.setTo(this.present.x,this.present.y);
         if(this.spawn_ordinal != this.manager.spawn_ordinal)
         {
            this.resetWeather();
         }
         this.snow.update(param1,_loc5_,_loc6_);
         this.rain.update(param1,_loc5_,_loc6_);
         this.fog.update(param1);
         this.gust.update(param1,_loc5_,_loc6_);
         this.spark.update(param1,_loc5_,_loc6_);
      }
   }
}
