package engine.landscape.view
{
   import com.stoicstudio.platform.Platform;
   import engine.core.render.BoundedCamera;
   import engine.core.render.Camera;
   import engine.math.MathUtil;
   import engine.resource.BitmapResource;
   import engine.resource.ResourceManager;
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   
   public class WeatherLayer_Particles implements IWeatherParticleProviderFlash
   {
      
      private static var DESPAWN_MARGIN:int = 4;
       
      
      private var _layer:WeatherLayer;
      
      private var manager:WeatherManager;
      
      public var lv:ILandscapeView;
      
      public var _particleSystem:WeatherManager_Particle;
      
      public var count:int = 0;
      
      private var _bmps:Vector.<IWeatherParticleBmp>;
      
      public var bmprs:Vector.<BitmapResource>;
      
      private var _blendMode:String = "normal";
      
      public function WeatherLayer_Particles(param1:WeatherLayer, param2:WeatherManager_Particle, param3:String = "normal")
      {
         var _loc6_:String = null;
         var _loc7_:BitmapResource = null;
         this._bmps = new Vector.<IWeatherParticleBmp>();
         this.bmprs = new Vector.<BitmapResource>();
         super();
         this._layer = param1;
         this.manager = param1.manager;
         this._particleSystem = param2;
         this.lv = this.manager.lv;
         this._blendMode = param3;
         var _loc4_:ResourceManager = this.lv.resman;
         var _loc5_:Array = param2.getUrlsForCategory(param1.category);
         for each(_loc6_ in _loc5_)
         {
            _loc7_ = _loc4_.getResource(_loc6_,BitmapResource,param1.group) as BitmapResource;
            this.bmprs.push(_loc7_);
         }
      }
      
      public function toString() : String
      {
         return this.particleSystem.toString();
      }
      
      public function cleanup() : void
      {
         this.bmprs = null;
      }
      
      public function getBitmapData(param1:int) : BitmapData
      {
         return this.bmprs[param1].bitmapData;
      }
      
      public function get layer() : WeatherLayer
      {
         return this._layer;
      }
      
      public function applySpecialModifiers(param1:int, param2:IWeatherParticleBmp) : Boolean
      {
         return false;
      }
      
      final public function update(param1:int, param2:Number, param3:Number) : void
      {
         var _loc15_:IWeatherParticleBmp = null;
         var _loc16_:WeatherParticleBmp_Data = null;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         this.computeDensity();
         var _loc4_:DisplayObjectWrapper = this._layer.present;
         var _loc5_:Number = this.manager.wind * this.manager.windMod * this.manager.speedMod;
         var _loc6_:Number = this._particleSystem.gravity * this.manager.speedMod;
         var _loc7_:Number = param1 / 10;
         var _loc8_:Number = _loc5_ * _loc7_;
         var _loc9_:Number = _loc6_ * _loc7_;
         var _loc10_:Number = _loc8_ * this._particleSystem.variance;
         var _loc11_:Number = _loc9_ * this._particleSystem.variance;
         var _loc12_:Number = 0;
         var _loc13_:Number = 0;
         var _loc14_:int = 0;
         while(_loc14_ < this._bmps.length)
         {
            _loc15_ = this._bmps[_loc14_];
            _loc16_ = _loc15_.data;
            _loc17_ = param2 * _loc16_.nearness;
            _loc18_ = param3 * _loc16_.nearness;
            if(_loc15_.update(_loc7_,_loc17_,_loc18_))
            {
               _loc12_ = _loc15_.x;
               _loc13_ = _loc15_.y;
            }
            else
            {
               _loc12_ = _loc15_.x;
               _loc13_ = _loc15_.y;
               _loc21_ = _loc15_.data.speedMod;
               _loc12_ += (_loc8_ + _loc16_.rw * _loc10_) * _loc21_;
               _loc13_ += (_loc9_ + _loc16_.rg * _loc11_) * _loc21_;
               _loc12_ += _loc17_;
               _loc13_ += _loc18_;
               _loc15_.x = _loc12_;
               _loc15_.y = _loc13_;
            }
            _loc19_ = _loc4_.x + _loc12_;
            _loc20_ = _loc4_.y + _loc13_;
            if(this.applySpecialModifiers(param1,_loc15_) || _loc19_ + _loc16_.left > this._layer.right + DESPAWN_MARGIN || _loc19_ + _loc16_.right < this._layer.left - DESPAWN_MARGIN || _loc20_ + _loc16_.top > this._layer.bottom + DESPAWN_MARGIN || _loc20_ + _loc16_.bottom < this._layer.top - DESPAWN_MARGIN)
            {
               if(this._bmps.length > this.count)
               {
                  this._bmps.splice(_loc14_,1);
                  this._layer.handleRemoveWeatherParticleBmp(_loc15_);
                  _loc15_.cleanup();
                  _loc14_--;
               }
               else
               {
                  this.respawnOne(_loc15_,_loc8_,_loc9_,param2,param3);
               }
            }
            _loc14_++;
         }
         while(_loc14_ < this.count)
         {
            _loc15_ = this.createOne();
            this.respawnOne(_loc15_,_loc8_,_loc9_,param2,param3);
            _loc14_++;
         }
      }
      
      final public function computeDensity() : void
      {
         if(!this._layer || !this.lv)
         {
            return;
         }
         var _loc1_:BoundedCamera = this.lv.camera;
         var _loc2_:int = 0;
         var _loc3_:int = Math.max(_loc1_.minWidth,Math.min(_loc1_.maxWidth,_loc1_.width / _loc1_.scale));
         var _loc4_:int = Math.max(_loc1_.minHeight,Math.min(_loc1_.maxHeight,_loc1_.height / _loc1_.scale));
         _loc2_ = this.manager.densityBias * this._particleSystem.densityMod * this._particleSystem.density * _loc3_ * _loc4_ / 40000;
         var _loc5_:Number = this._particleSystem.getCountForCategory(this._layer.category);
         if(Platform.optimizeForConsole)
         {
            _loc5_ *= 0.1;
         }
         _loc2_ *= _loc5_;
         this.count = _loc2_;
         if(this._particleSystem.alpha <= 0.01)
         {
            this.count = 0;
         }
      }
      
      final public function resetParticles() : void
      {
         var _loc2_:IWeatherParticleBmp = null;
         var _loc3_:BoundedCamera = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Rectangle = null;
         var _loc7_:int = 0;
         var _loc8_:IWeatherParticleBmp = null;
         var _loc9_:WeatherParticleBmp_Data = null;
         if(!this._layer || !this.lv || !this._layer.present || !this._layer.group)
         {
            return;
         }
         if(!this._layer.group.complete)
         {
            return;
         }
         var _loc1_:DisplayObjectWrapper = this._layer.present;
         for each(_loc2_ in this._bmps)
         {
            this._layer.handleRemoveWeatherParticleBmp(_loc2_);
            _loc2_.cleanup();
         }
         this._bmps.splice(0,this._bmps.length);
         _loc3_ = this.lv.camera;
         _loc4_ = Math.max(_loc3_.minWidth,Math.min(_loc3_.maxWidth,_loc3_.width / _loc3_.scale));
         _loc5_ = Math.max(_loc3_.minHeight,Math.min(_loc3_.maxHeight,_loc3_.height / _loc3_.scale));
         _loc6_ = new Rectangle(-_loc1_.x - _loc4_ / 2,-_loc1_.y - _loc5_ / 2,_loc4_,_loc5_);
         _loc7_ = 0;
         while(_loc7_ < this.count)
         {
            _loc8_ = this.createOne();
            _loc9_ = _loc8_.data;
            _loc8_.x = MathUtil.randomInt(_loc6_.left - _loc9_.right + 1,_loc6_.right - 1);
            _loc8_.y = MathUtil.randomInt(_loc6_.top - _loc9_.bottom + 1,_loc6_.bottom - 1);
            _loc7_++;
         }
      }
      
      final private function createOne() : IWeatherParticleBmp
      {
         if(!this._layer)
         {
            return null;
         }
         var _loc1_:Number = Math.random();
         var _loc2_:int = this.getRandomBmpdIndex(_loc1_);
         var _loc3_:Number = this._particleSystem.getSpeedForCategory(this._layer.category);
         var _loc4_:IWeatherParticleBmp = this._layer.handleCreateOneWeatherParticleBmp(this,_loc2_,_loc3_,_loc1_,this._blendMode);
         this._layer.handleAddWeatherParticleBmp(_loc4_);
         this._bmps.push(_loc4_);
         return _loc4_;
      }
      
      final private function _getRandomBmpd(param1:Number) : BitmapData
      {
         var _loc2_:int = this.getRandomBmpdIndex(param1);
         var _loc3_:BitmapResource = this.bmprs[_loc2_];
         return _loc3_.bitmapData;
      }
      
      final private function getRandomBmpdIndex(param1:Number) : int
      {
         var _loc2_:int = Math.max(0,Math.min(this.bmprs.length - 1,Math.round(param1 * (this.bmprs.length - 1))));
         var _loc3_:int = this.bmprs.length / 2;
         var _loc4_:int = Math.max(0,_loc2_ - _loc3_);
         var _loc5_:int = Math.min(this.bmprs.length - 1,_loc2_ + _loc3_);
         return _loc2_;
      }
      
      public function respawnOne(param1:IWeatherParticleBmp, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc6_:BoundedCamera = this.lv.camera;
         var _loc7_:int = this.layer.right - this.layer.left;
         var _loc8_:int = this.layer.bottom - this.layer.top;
         var _loc9_:Number = _loc7_ / 2;
         var _loc10_:Number = _loc8_ / 2;
         var _loc11_:WeatherParticleBmp_Data = param1.data;
         ++_loc11_.lifespan;
         if(param1.data.lifespan > this.count / 2)
         {
            this.reRandomize(param1);
         }
         else
         {
            param1.reorient();
         }
         var _loc12_:Number = 0;
         var _loc13_:Number = 0;
         if(param4)
         {
            _loc15_ = Math.abs(param4) * _loc8_ / 2;
            _loc12_ = _loc15_ / (_loc15_ + _loc7_ + _loc8_);
         }
         if(param5)
         {
            _loc16_ = Math.abs(param5) * _loc7_ / 2;
            _loc13_ = _loc16_ / (_loc16_ + _loc7_ + _loc8_);
         }
         if(Boolean(param4) && Math.random() < _loc12_)
         {
            if(param4 > 0)
            {
               param1.x = -_loc9_ - _loc11_.right + 1 + Math.random() * param4;
            }
            else
            {
               param1.x = _loc9_ - _loc11_.left + Math.random() * param4 - 1;
            }
            param1.y = -_loc10_ + Math.random() * _loc8_ - param1.data.bottom + 1;
         }
         else if(Boolean(param5) && Math.random() < _loc13_)
         {
            if(param5 > 0)
            {
               param1.y = -_loc10_ - _loc11_.bottom + 1 + Math.random() * param5;
            }
            else
            {
               param1.y = _loc10_ - _loc11_.top + Math.random() * param5 - 1;
            }
            param1.x = -_loc9_ + Math.random() * _loc7_ - _loc11_.right + 1;
         }
         else
         {
            _loc17_ = Math.abs(param2);
            _loc18_ = Math.abs(param3);
            _loc19_ = _loc17_ + _loc18_;
            _loc20_ = !!_loc19_ ? _loc17_ / _loc19_ : 1;
            _loc21_ = !!_loc19_ ? _loc18_ / _loc19_ : 1;
            _loc20_ *= _loc8_;
            _loc21_ *= _loc7_;
            _loc22_ = _loc20_ + _loc21_;
            _loc23_ = Math.random() * _loc22_;
            if(_loc23_ < _loc20_)
            {
               _loc23_ = (_loc8_ + _loc11_.height) * _loc23_ / _loc20_;
               param1.y = -_loc10_ - _loc11_.bottom + _loc23_;
               if(param2 > 0)
               {
                  param1.x = -_loc9_ - _loc11_.right + 1;
               }
               else
               {
                  param1.x = _loc9_ - _loc11_.left - 1;
               }
            }
            else
            {
               _loc23_ = (_loc7_ + _loc11_.width) * (_loc23_ - _loc20_) / _loc21_;
               param1.x = -_loc9_ - _loc11_.right + _loc23_;
               if(param3 > 0)
               {
                  param1.y = -_loc10_ - _loc11_.bottom + 1;
               }
               else
               {
                  param1.y = _loc10_ - _loc11_.top - 1;
               }
            }
         }
         var _loc14_:DisplayObjectWrapper = this._layer.present;
         param1.x -= _loc14_.x;
         param1.y -= _loc14_.y;
         param1.x += param2 * Math.random();
         param1.y += param3 * Math.random();
      }
      
      final private function bmprComparator(param1:BitmapResource, param2:BitmapResource) : int
      {
         return param1 && param2 && param1.bitmapData && Boolean(param2.bitmapData) ? param1.bitmapData.width - param2.bitmapData.width : 0;
      }
      
      public function handleLoaded() : void
      {
         this.bmprs.sort(this.bmprComparator);
      }
      
      final protected function reRandomize(param1:IWeatherParticleBmp) : void
      {
         var _loc2_:Number = Math.random();
         var _loc3_:int = this.getRandomBmpdIndex(_loc2_);
         param1.setup(null,_loc3_,_loc2_,this._blendMode);
      }
      
      final private function fillGaps(param1:Number, param2:Number) : void
      {
         var _loc3_:Camera = this.lv.camera;
         var _loc4_:int = this.count - this._bmps.length;
         if(_loc4_ <= 0)
         {
            return;
         }
         var _loc5_:Number = _loc3_.height;
         var _loc6_:Number = _loc3_.width;
         if(param1 > 0)
         {
            this.spawnIntoCameraRect(_loc4_,-_loc6_ / 2,-_loc5_ / 2,-_loc6_ / 2 + param1,_loc5_ / 2);
         }
         else if(param1 < 0)
         {
            this.spawnIntoCameraRect(_loc4_,_loc6_ / 2 + param1,-_loc5_ / 2,_loc6_ / 2,_loc5_ / 2);
         }
      }
      
      final private function spawnIntoCameraRect(param1:int, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc8_:IWeatherParticleBmp = null;
         var _loc9_:WeatherParticleBmp_Data = null;
         var _loc6_:DisplayObjectWrapper = this._layer.present;
         param2 -= _loc6_.x;
         param4 -= _loc6_.x;
         param3 -= _loc6_.y;
         param5 -= _loc6_.y;
         var _loc7_:int = 0;
         while(_loc7_ < this.count)
         {
            _loc8_ = this.createOne();
            _loc9_ = _loc8_.data;
            _loc8_.x = MathUtil.randomInt(param2 - _loc9_.right + 1,param4 - 1);
            _loc8_.y = MathUtil.randomInt(param3 - _loc9_.bottom + 1,param5 - 1);
            _loc7_++;
         }
      }
      
      public function get particleSystem() : WeatherManager_Particle
      {
         return this._particleSystem;
      }
   }
}
