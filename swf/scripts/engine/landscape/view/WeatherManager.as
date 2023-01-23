package engine.landscape.view
{
   import com.greensock.TweenMax;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.landscape.model.Landscape;
   import engine.math.MathUtil;
   import engine.saga.Caravan;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.VariableEvent;
   import engine.saga.vars.VariableType;
   
   public class WeatherManager
   {
      
      public static var ENABLED:Boolean = true;
      
      public static var PAUSED:Boolean = false;
      
      public static var FRAMETIME_MIN:int = 35;
      
      public static var FRAMETIME_MAX:int = 50;
      
      public static var FRAMETIME_RANGE:int = FRAMETIME_MAX - FRAMETIME_MIN;
       
      
      public var snow:WeatherManager_Snow;
      
      public var fog:WeatherManager_Fog;
      
      public var rain:WeatherManager_Rain;
      
      public var gust:WeatherManager_Gust;
      
      public var spark:WeatherManager_Spark;
      
      public var spawn_ordinal:int = 1;
      
      public var wind:Number = 1;
      
      public var windMod:Number = 1;
      
      public var speedMod:Number = 1;
      
      public var minSpeed:Number = 1;
      
      private var layers:Vector.<WeatherLayer>;
      
      public var avgFrameTime:Number = 30;
      
      public var densityBias:Number = 1;
      
      public var lv:ILandscapeView;
      
      public var saga:Saga;
      
      private var caravan:Caravan;
      
      private var vars:IVariableBag;
      
      public var enabled:Boolean = true;
      
      public var shell:ShellCmdManager;
      
      public var logger:ILogger;
      
      public function WeatherManager(param1:ILandscapeView)
      {
         this.layers = new Vector.<WeatherLayer>();
         super();
         this.lv = param1;
         var _loc2_:Landscape = param1.landscape;
         this.logger = _loc2_.scene._context.logger;
         this.snow = new WeatherManager_Snow(this);
         this.fog = new WeatherManager_Fog(this);
         this.rain = new WeatherManager_Rain(this);
         this.gust = new WeatherManager_Gust(this);
         this.spark = new WeatherManager_Spark(this);
         this.shell = new ShellCmdManager(this.logger);
         this.enabled = ENABLED;
         this.shell.add("enable",this.cmdFuncEnable);
         this.shell.add("layer_list",this.cmdFuncLayers);
         this.shell.add("layer_enable",this.cmdFuncLayerEnable);
         this.shell.add("pause",this.cmdFuncPause);
         this.shell.add("scale",this.cmdFuncScale);
         this.shell.add("rainmarch",this.cmdFuncRainMarch);
         this.shell.add("rainstretch",this.cmdFuncRainStretch);
         this.shell.add("reset",this.cmdFuncReset);
         if(_loc2_.scene._def.weatherDisabled)
         {
            this.enabled = false;
         }
         if(!this.enabled)
         {
            return;
         }
         this.listenToSaga();
      }
      
      private function cmdFuncEnable(param1:CmdExec) : void
      {
         var _loc3_:WeatherLayer = null;
         WeatherManager.ENABLED = !WeatherManager.ENABLED;
         this.enabled = WeatherManager.ENABLED;
         this.logger.info("WeatherManager.ENABLED = " + WeatherManager.ENABLED);
         var _loc2_:int = 0;
         while(_loc2_ < this.layers.length)
         {
            _loc3_ = this.layers[_loc2_];
            _loc3_.visible = this.enabled;
            _loc2_++;
         }
      }
      
      private function cmdFuncLayers(param1:CmdExec) : void
      {
         var _loc3_:WeatherLayer = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.layers.length)
         {
            _loc3_ = this.layers[_loc2_];
            this.logger.info("Layer " + _loc2_ + " count " + _loc3_.snow.count + " visible " + _loc3_.visible);
            _loc2_++;
         }
      }
      
      private function cmdFuncLayerEnable(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:int = int(_loc2_[1]);
         var _loc4_:WeatherLayer = this.layers[_loc3_];
         _loc4_.visible = !_loc4_.visible;
      }
      
      private function cmdFuncPause(param1:CmdExec) : void
      {
         WeatherManager.PAUSED = !WeatherManager.PAUSED;
         this.logger.info("WeatherManager.PAUSED = " + WeatherManager.PAUSED);
      }
      
      private function cmdFuncScale(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:Number = Number(_loc2_[1]);
         WeatherLayer.LAYER_SCALE = _loc3_;
         this.logger.info("WeatherLayer.LAYER_SCALE = " + WeatherLayer.LAYER_SCALE);
      }
      
      private function cmdFuncRainMarch(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:Number = Number(_loc2_[1]);
         this.rain.horizontalMarch = _loc3_;
         this.logger.info("rain.horizontalMarch = " + this.rain.horizontalMarch);
      }
      
      private function cmdFuncReset(param1:CmdExec) : void
      {
         this.resetSnow();
      }
      
      private function cmdFuncRainStretch(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:Number = Number(_loc2_[1]);
         this.rain.stretch = _loc3_;
         this.logger.info("rain.stretch = " + this.rain.stretch);
      }
      
      private function listenToSaga() : void
      {
         var _loc1_:Landscape = this.lv.landscape;
         if(!_loc1_ || !_loc1_.scene || _loc1_.scene.cleanedup)
         {
            return;
         }
         this.saga = _loc1_.scene._context.saga as Saga;
         this.caravan = !!this.saga ? this.saga.caravan : null;
         this.vars = !!this.caravan ? this.caravan.vars : null;
         if(this.vars)
         {
            this.vars.addEventListener(VariableEvent.TYPE,this.variableHandler);
            this.wind = this.vars.fetch(SagaVar.VAR_WEATHER_WIND,VariableType.DECIMAL).asNumber;
         }
         if(Boolean(_loc1_.travel) && _loc1_.travel.def.points.length > 0)
         {
            if(_loc1_.travel.def.points[0].x < _loc1_.travel.def.points[1].x)
            {
               if(this.wind > 0)
               {
                  this.wind *= -1;
               }
            }
            else if(this.wind < 0)
            {
               this.wind *= -1;
            }
         }
         if(this.caravan)
         {
            this.vars.fetch(SagaVar.VAR_WEATHER_WIND,VariableType.DECIMAL).asNumber = this.wind;
         }
         this.snow.getVariables(this.vars);
         this.rain.getVariables(this.vars);
         this.fog.getVariables(this.vars);
         this.gust.getVariables(this.vars);
         this.spark.getVariables(this.vars);
      }
      
      private function variableHandler(param1:VariableEvent) : void
      {
         switch(param1.value.def.name)
         {
            case SagaVar.VAR_WEATHER_WIND:
               this.tweenWind(param1.value.asNumber);
               break;
            default:
               if(this.snow.variableHandler(param1))
               {
                  return;
               }
               if(this.rain.variableHandler(param1))
               {
                  return;
               }
               if(this.fog.variableHandler(param1))
               {
                  return;
               }
               if(this.gust.variableHandler(param1))
               {
                  return;
               }
               if(this.spark.variableHandler(param1))
               {
                  return;
               }
               break;
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:WeatherLayer = null;
         this.fog.cleanup();
         this.fog = null;
         this.rain.cleanup();
         this.rain = null;
         this.snow.cleanup();
         this.snow = null;
         this.gust.cleanup();
         this.gust = null;
         this.spark.cleanup();
         this.spark = null;
         if(this.vars)
         {
            this.vars.removeEventListener(VariableEvent.TYPE,this.variableHandler);
            this.vars = null;
         }
         this.caravan = null;
         this.saga = null;
         for each(_loc1_ in this.layers)
         {
            _loc1_.cleanup();
         }
         this.shell.cleanup();
         this.shell = null;
         this.layers = null;
         this.logger = null;
      }
      
      public function registerSnowLayer(param1:WeatherLayer) : void
      {
         var _loc2_:Number = this.snow.getSpeedForCategory(param1.category);
         this.minSpeed = Math.min(_loc2_,this.minSpeed);
         this.layers.push(param1);
      }
      
      public function update(param1:int) : void
      {
         var _loc3_:WeatherLayer = null;
         if(!ENABLED || !this.enabled || PAUSED)
         {
            return;
         }
         if(!this.lv.lookingForReady)
         {
            return;
         }
         this.avgFrameTime = (this.avgFrameTime * 100 + param1) / 101;
         var _loc2_:Number = Math.max(0,Math.min(1,(this.avgFrameTime - FRAMETIME_MIN) / FRAMETIME_RANGE));
         this.densityBias = MathUtil.lerp(1,0.1,_loc2_);
         this.fog.update(param1);
         for each(_loc3_ in this.layers)
         {
            _loc3_.update(param1);
         }
      }
      
      public function resetSnow() : void
      {
         ++this.spawn_ordinal;
      }
      
      public function computeTweenDuration(param1:Number) : Number
      {
         var _loc2_:Number = 200;
         var _loc3_:Number = Math.abs(this.wind * this.windMod * this.speedMod * _loc2_ * this.minSpeed);
         var _loc4_:Number = Math.abs(param1 * this.speedMod * _loc2_ * this.minSpeed);
         var _loc5_:Number = !!_loc3_ ? this.lv.camera.width / _loc3_ : 3;
         var _loc6_:Number = !!_loc4_ ? this.lv.camera.height / _loc4_ : 3;
         return Math.min(_loc5_,_loc6_);
      }
      
      public function getWindSpeed() : Number
      {
         var _loc1_:Number = 200;
         return Math.abs(this.wind * this.windMod * this.speedMod * _loc1_ * this.minSpeed);
      }
      
      public function tweenWind(param1:Number) : void
      {
         if(isNaN(param1))
         {
            return;
         }
         var _loc2_:Number = this.computeTweenDuration(0);
         TweenMax.to(this,_loc2_,{"wind":param1});
      }
   }
}
