package engine.landscape.view
{
   import engine.math.MathUtil;
   import flash.display.Bitmap;
   import flash.geom.ColorTransform;
   
   public class WeatherParticleBmpFlash extends Bitmap implements IWeatherParticleBmp
   {
       
      
      public var _data:WeatherParticleBmp_Data;
      
      private var _provider:IWeatherParticleProvider;
      
      private var _orients:Boolean;
      
      private var _stretch:Number = 1;
      
      private var _sx:Number = 1;
      
      private var _sy:Number = 1;
      
      private var _rotation:Number = 0;
      
      private var _vx:Number = 0;
      
      private var _vy:Number = 0;
      
      private var _manager:WeatherManager;
      
      private var _particleSystem:WeatherManager_Particle;
      
      private var _cachedColor:uint = 0;
      
      public function WeatherParticleBmpFlash(param1:IWeatherParticleProviderFlash, param2:int, param3:Number, param4:Number, param5:String = "normal")
      {
         super(null);
         this._data = new WeatherParticleBmp_Data(param3);
         this.setup(param1,param2,param4,param5);
      }
      
      public function setup(param1:IWeatherParticleProvider, param2:int, param3:Number, param4:String) : void
      {
         if(param1)
         {
            this._provider = param1;
         }
         if(!this._provider)
         {
            throw new ArgumentError("Can\'t have null provider");
         }
         this._particleSystem = this._provider.particleSystem;
         this._manager = this._particleSystem.manager;
         this.blendMode = param4;
         this._orients = this._particleSystem.orients;
         this._stretch = this._particleSystem.stretch;
         if(this._stretch != 1)
         {
            this._sx = Math.random() + 0.5;
            if(Math.random() > 0.5)
            {
            }
            this._sy = this._stretch;
         }
         else
         {
            this._sx = this._sy = 1;
         }
         var _loc5_:IWeatherParticleProviderFlash = this._provider as IWeatherParticleProviderFlash;
         this.bitmapData = _loc5_.getBitmapData(param2);
         this.smoothing = false;
         this._data.setup(param3);
         this._data.setBounds(0,0,bitmapData.width,bitmapData.height);
         this.reorient();
      }
      
      public function get data() : WeatherParticleBmp_Data
      {
         return this._data;
      }
      
      public function cleanup() : void
      {
         this.bitmapData = null;
      }
      
      public function update(param1:int, param2:Number, param3:Number) : Boolean
      {
         return false;
      }
      
      public function reorient() : void
      {
         var _loc1_:ColorTransform = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(this._cachedColor != this._particleSystem.color)
         {
            this._cachedColor = this._particleSystem.color;
            _loc1_ = new ColorTransform();
            _loc1_.color = this._cachedColor;
            bitmapData.colorTransform(bitmapData.rect,_loc1_);
         }
         if(this._orients)
         {
            _loc2_ = this._manager.speedMod;
            _loc3_ = this._manager.wind * this._manager.windMod * _loc2_;
            _loc4_ = this._particleSystem.gravity * _loc2_;
            _loc5_ = this._particleSystem.variance;
            this._vx = _loc3_ + this._data.rw * _loc3_ * _loc5_;
            this._vy = _loc4_ + this._data.rg * _loc4_ * _loc5_;
            _loc6_ = -Math.atan2(this._vx,this._vy);
            this._rotation = MathUtil.radians2Degrees(_loc6_);
         }
         else
         {
            this._rotation = 0;
            this._vx = this._vy = 0;
         }
         this.rotation = this._rotation;
         this.scaleX = this._sx;
         this.scaleY = this._sy;
      }
   }
}
