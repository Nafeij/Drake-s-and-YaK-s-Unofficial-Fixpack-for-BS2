package engine.landscape.view
{
   import engine.math.MathUtil;
   
   public class WeatherLayer_Blinkers extends WeatherLayer_Particles
   {
       
      
      private var _layer:WeatherLayer;
      
      private var _particleSystemManager:WeatherManager_Blinker;
      
      public function WeatherLayer_Blinkers(param1:WeatherLayer, param2:WeatherManager_Blinker, param3:String = "normal")
      {
         super(param1,param2,param3);
         this._layer = param1;
         this._particleSystemManager = param2;
      }
      
      override public function applySpecialModifiers(param1:int, param2:IWeatherParticleBmp) : Boolean
      {
         param2.alpha += this._particleSystemManager.blinkRate * (param1 / 1000) * param2.data.alphaMod;
         if(param2.alpha <= 0)
         {
            param2.data.alphaMod *= -1;
            return true;
         }
         if(param2.alpha >= 1)
         {
            param2.data.alphaMod *= -1;
         }
         return false;
      }
      
      override public function respawnOne(param1:IWeatherParticleBmp, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc6_:int = layer.right - layer.left;
         var _loc7_:int = layer.bottom - layer.top;
         var _loc8_:Number = _loc6_ / 2;
         var _loc9_:Number = _loc7_ / 2;
         if(++param1.data.lifespan > count / 2)
         {
            reRandomize(param1);
         }
         else
         {
            param1.reorient();
         }
         var _loc10_:DisplayObjectWrapper = this._layer.present;
         param1.x = -_loc8_ + Math.random() * _loc6_ - _loc10_.x;
         param1.y = -_loc9_ + Math.random() * _loc7_ - _loc10_.y;
         param1.alpha = 0;
         param1.data.alphaMod = 1 * MathUtil.clampValue(Math.random(),0.5,1);
      }
   }
}
