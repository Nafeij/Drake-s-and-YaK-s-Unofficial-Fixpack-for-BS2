package engine.landscape.view
{
   import engine.landscape.model.LandscapeLayer;
   import flash.display.Sprite;
   
   public class WeatherLayerFlash extends WeatherLayer
   {
       
      
      private var _sprite:Sprite;
      
      public function WeatherLayerFlash(param1:WeatherManager, param2:ILandscapeView, param3:int, param4:LandscapeLayer)
      {
         super(param1,param2,param3,param4);
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      override protected function handleBitmapsLoaded() : void
      {
      }
      
      override protected function handleCreatePresent() : DisplayObjectWrapper
      {
         this._sprite = new Sprite();
         return new DisplayObjectWrapperFlash(this._sprite);
      }
      
      override public function handleRemoveWeatherParticleBmp(param1:IWeatherParticleBmp) : void
      {
         this._sprite.removeChild(param1 as WeatherParticleBmpFlash);
      }
      
      override public function handleAddWeatherParticleBmp(param1:IWeatherParticleBmp) : void
      {
         this._sprite.addChild(param1 as WeatherParticleBmpFlash);
      }
      
      override public function handleCreateOneWeatherParticleBmp(param1:WeatherLayer_Particles, param2:int, param3:Number, param4:Number, param5:String) : IWeatherParticleBmp
      {
         return new WeatherParticleBmpFlash(param1,param2,param3,param4,param5);
      }
   }
}
