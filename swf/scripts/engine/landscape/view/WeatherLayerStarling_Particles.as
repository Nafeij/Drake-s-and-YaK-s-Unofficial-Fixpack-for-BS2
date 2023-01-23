package engine.landscape.view
{
   import engine.resource.BitmapResource;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.textures.Texture;
   
   public class WeatherLayerStarling_Particles implements IWeatherParticleProviderStarling
   {
       
      
      private var _layer:WeatherLayerStarling;
      
      private var manager:WeatherManager;
      
      private var particles:WeatherLayer_Particles;
      
      public var _uvs:Vector.<Rectangle>;
      
      public var _sizes:Vector.<Point>;
      
      public function WeatherLayerStarling_Particles()
      {
         this._uvs = new Vector.<Rectangle>();
         this._sizes = new Vector.<Point>();
         super();
      }
      
      public function toString() : String
      {
         return "[WeatherLayerStarling_Particles " + this._layer + " " + this.particles + "]";
      }
      
      public function setup(param1:WeatherLayerStarling, param2:WeatherLayer_Particles) : void
      {
         this._layer = param1;
         this.particles = param2;
         this.manager = param1.manager;
      }
      
      public function getParticleUvs(param1:int) : Rectangle
      {
         if(param1 >= this._uvs.length)
         {
            throw new ArgumentError("Not enough uvs on " + this + " for index " + param1);
         }
         return this._uvs[param1];
      }
      
      public function getParticleSize(param1:int) : Point
      {
         if(param1 >= this._sizes.length)
         {
            throw new ArgumentError("Not enough sizes on " + this + " for index " + param1);
         }
         return this._sizes[param1];
      }
      
      public function get layer() : WeatherLayer
      {
         return this._layer;
      }
      
      public function cleanup() : void
      {
         this._uvs = null;
      }
      
      public function getRequiredTextureSize() : Point
      {
         var _loc4_:BitmapResource = null;
         var _loc5_:BitmapData = null;
         var _loc1_:int = 1;
         var _loc2_:int = 0;
         var _loc3_:Vector.<BitmapResource> = this.particles.bmprs;
         var _loc6_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc3_.length)
         {
            _loc4_ = _loc3_[_loc6_];
            _loc5_ = _loc3_[_loc6_].bitmapData;
            _loc1_ += _loc5_.width;
            _loc1_++;
            _loc2_ = Math.max(_loc2_,_loc5_.height);
            _loc6_++;
         }
         return new Point(_loc1_,_loc2_);
      }
      
      public function initTextureAtlas(param1:BitmapData, param2:int, param3:int) : void
      {
         var _loc6_:BitmapResource = null;
         var _loc7_:BitmapData = null;
         var _loc4_:Vector.<BitmapResource> = this.particles.bmprs;
         param2++;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc6_ = _loc4_[_loc5_];
            _loc7_ = _loc4_[_loc5_].bitmapData;
            param1.copyPixels(_loc7_,_loc7_.rect,new Point(param2,0));
            param2 += _loc7_.width;
            param2++;
            _loc5_++;
         }
      }
      
      public function finishTextureAtlas(param1:Texture, param2:int, param3:int) : void
      {
         var _loc8_:BitmapResource = null;
         var _loc9_:BitmapData = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Rectangle = null;
         if(!this._uvs)
         {
            return;
         }
         var _loc4_:Vector.<BitmapResource> = this.particles.bmprs;
         var _loc5_:Number = param1.width;
         var _loc6_:Number = param1.height;
         param2++;
         var _loc7_:int = 0;
         while(_loc7_ < _loc4_.length)
         {
            _loc8_ = _loc4_[_loc7_];
            _loc9_ = _loc4_[_loc7_].bitmapData;
            _loc10_ = _loc9_.width;
            _loc11_ = _loc9_.height;
            this._sizes.push(new Point(_loc10_,_loc11_));
            _loc12_ = new Rectangle(param2 / _loc5_,0,_loc10_ / _loc5_,_loc11_ / _loc6_);
            this._uvs.push(_loc12_);
            param2 += _loc9_.width;
            param2++;
            _loc7_++;
         }
      }
      
      public function get particleSystem() : WeatherManager_Particle
      {
         return this.particles._particleSystem;
      }
   }
}
