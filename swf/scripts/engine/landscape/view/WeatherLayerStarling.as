package engine.landscape.view
{
   import com.stoicstudio.platform.PlatformStarling;
   import engine.landscape.model.LandscapeLayer;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import starling.display.Sprite;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   
   public class WeatherLayerStarling extends WeatherLayer
   {
       
      
      public var _sprite:Sprite;
      
      private var _quadBatches:Dictionary;
      
      private var _bmpBatches:Dictionary;
      
      public var _atlas:Texture;
      
      public var fogStarling:WeatherLayerStarling_Fog;
      
      public var snowStarling:WeatherLayerStarling_Particles;
      
      public var rainStarling:WeatherLayerStarling_Particles;
      
      public var gustStarling:WeatherLayerStarling_Particles;
      
      public var sparkStarling:WeatherLayerStarling_Particles;
      
      private var _batlas:BitmapData;
      
      public function WeatherLayerStarling(param1:WeatherManager, param2:ILandscapeView, param3:int, param4:LandscapeLayer)
      {
         var _loc5_:String = null;
         this._quadBatches = new Dictionary();
         this._bmpBatches = new Dictionary();
         this.fogStarling = new WeatherLayerStarling_Fog();
         this.snowStarling = new WeatherLayerStarling_Particles();
         this.rainStarling = new WeatherLayerStarling_Particles();
         this.sparkStarling = new WeatherLayerStarling_Particles();
         this.gustStarling = new WeatherLayerStarling_Particles();
         super(param1,param2,param3,param4);
         for each(_loc5_ in _blendModes)
         {
            this._bmpBatches[_loc5_] = new Vector.<WeatherParticleBmpStarling>();
         }
      }
      
      override public function cleanup() : void
      {
         var _loc1_:WeatherQuadBatch = null;
         for each(_loc1_ in this._quadBatches)
         {
            _loc1_.removeFromParent(true);
         }
         this._quadBatches = null;
         this._bmpBatches = null;
         this.fogStarling.cleanup();
         this.fogStarling = null;
         this.snowStarling.cleanup();
         this.snowStarling = null;
         this.rainStarling.cleanup();
         this.rainStarling = null;
         this.sparkStarling.cleanup();
         this.sparkStarling = null;
         this.gustStarling.cleanup();
         this.gustStarling = null;
         if(PlatformStarling.isContextValid)
         {
            if(this._atlas)
            {
               this._atlas.dispose();
            }
         }
         this._atlas = null;
         if(this._batlas)
         {
            this._batlas.dispose();
            this._batlas = null;
         }
         if(this._sprite)
         {
            this._sprite.removeFromParent(true);
            this._sprite = null;
         }
         providers = null;
         super.cleanup();
      }
      
      override protected function handleCreatePresent() : DisplayObjectWrapper
      {
         var _loc1_:String = null;
         this._sprite = new Sprite();
         for each(_loc1_ in _blendModes)
         {
            this._quadBatches[_loc1_] = new WeatherQuadBatch();
            this._sprite.addChild(this._quadBatches[_loc1_]);
         }
         this.fogStarling.setup(this);
         this.snowStarling.setup(this,snow);
         this.rainStarling.setup(this,rain);
         this.sparkStarling.setup(this,spark);
         this.gustStarling.setup(this,gust);
         providers[snow] = this.snowStarling;
         providers[rain] = this.rainStarling;
         providers[spark] = this.sparkStarling;
         providers[gust] = this.gustStarling;
         return new DisplayObjectWrapperStarling(this._sprite);
      }
      
      public function repositionRenderable() : void
      {
         var _loc1_:String = null;
         var _loc2_:Vector.<WeatherParticleBmpStarling> = null;
         var _loc3_:WeatherQuadBatch = null;
         var _loc4_:int = 0;
         var _loc5_:WeatherParticleBmpStarling = null;
         for each(_loc1_ in _blendModes)
         {
            _loc2_ = this._bmpBatches[_loc1_];
            _loc3_ = this._quadBatches[_loc1_];
            if(!_loc2_)
            {
               logger.error("WeatherLayerStarling.repositionRenderable - Missing Bmp Vector for blend mode " + _loc1_);
            }
            else if(!_loc3_)
            {
               logger.error("WeatherLayerStarling.repositionRenderable - Missing Quad Batch for blend mode " + _loc1_);
            }
            else
            {
               if(_loc2_.length < _loc3_.numQuads && _loc3_.capacity > _loc2_.length)
               {
                  if(_loc2_.length == 0)
                  {
                     _loc3_.reset();
                     continue;
                  }
                  _loc3_.capacity = _loc2_.length;
               }
               _loc4_ = 0;
               while(_loc4_ < _loc2_.length)
               {
                  _loc5_ = _loc2_[_loc4_];
                  _loc3_.updateQuadVerts(_loc4_,_loc5_.mVertexData);
                  _loc4_++;
               }
               _loc3_.notifyChange();
            }
         }
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         this.repositionRenderable();
      }
      
      override public function handleRemoveWeatherParticleBmp(param1:IWeatherParticleBmp) : void
      {
         var _loc2_:WeatherParticleBmpStarling = param1 as WeatherParticleBmpStarling;
         var _loc3_:Vector.<WeatherParticleBmpStarling> = this._bmpBatches[_loc2_.blendMode];
         if(!_loc3_)
         {
            logger.error("WeatherLayerStarling.handleRemoveWeatherParticleBmp : Failed to find Bmp Batch for blend mode " + _loc2_.blendMode);
            return;
         }
         var _loc4_:int = _loc3_.indexOf(_loc2_);
         if(_loc4_ >= 0)
         {
            _loc3_.splice(_loc4_,1);
         }
      }
      
      override public function handleAddWeatherParticleBmp(param1:IWeatherParticleBmp) : void
      {
         var _loc2_:WeatherParticleBmpStarling = param1 as WeatherParticleBmpStarling;
         var _loc3_:WeatherQuadBatch = this._quadBatches[_loc2_.blendMode];
         var _loc4_:Vector.<WeatherParticleBmpStarling> = this._bmpBatches[_loc2_.blendMode];
         if(!_loc3_ || !_loc4_)
         {
            logger.error("WeatherLayerStarling.handleAddWeatherParticleBmp : No blendmode set up for " + _loc2_.blendMode);
            return;
         }
         _loc3_.addVertexData(_loc2_.mVertexData,1,this._atlas,TextureSmoothing.BILINEAR,_loc2_.blendMode);
         _loc4_.push(_loc2_);
      }
      
      override protected function handleBitmapsLoaded() : void
      {
         if(!this.snowStarling || !this.fogStarling || !this.sparkStarling || !this.gustStarling || Boolean(this._atlas))
         {
            return;
         }
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Point = this.snowStarling.getRequiredTextureSize();
         var _loc4_:Point = this.rainStarling.getRequiredTextureSize();
         var _loc5_:Point = this.fogStarling.getRequiredTextureSize();
         var _loc6_:Point = this.gustStarling.getRequiredTextureSize();
         var _loc7_:Point = this.sparkStarling.getRequiredTextureSize();
         _loc1_ = _loc3_.x + _loc4_.x + _loc5_.x + _loc7_.x + _loc6_.x;
         _loc2_ = Math.max(_loc3_.y,_loc5_.y);
         _loc2_ = Math.max(_loc4_.y,_loc2_);
         _loc2_ = Math.max(_loc7_.y,_loc2_);
         _loc2_ = Math.max(_loc6_.y,_loc2_);
         this._batlas = new BitmapData(_loc1_,_loc2_,true,0);
         var _loc8_:int = 0;
         this.snowStarling.initTextureAtlas(this._batlas,_loc8_,0);
         _loc8_ += _loc3_.x;
         this.rainStarling.initTextureAtlas(this._batlas,_loc8_,0);
         _loc8_ += _loc4_.x;
         this.fogStarling.initTextureAtlas(this._batlas,_loc8_,0);
         _loc8_ += _loc5_.x;
         this.sparkStarling.initTextureAtlas(this._batlas,_loc8_,0);
         _loc8_ += _loc7_.x;
         this.gustStarling.initTextureAtlas(this._batlas,_loc8_,0);
         _loc8_ += _loc6_.x;
         this._atlas = Texture.fromBitmapData(this,this._batlas,false);
         _loc8_ = 0;
         this.snowStarling.finishTextureAtlas(this._atlas,_loc8_,0);
         _loc8_ += _loc3_.x;
         this.rainStarling.finishTextureAtlas(this._atlas,_loc8_,0);
         _loc8_ += _loc4_.x;
         this.fogStarling.finishTextureAtlas(this._atlas,_loc8_,0);
         _loc8_ += _loc5_.x;
         this.sparkStarling.finishTextureAtlas(this._atlas,_loc8_,0);
         _loc8_ += _loc7_.x;
         this.gustStarling.finishTextureAtlas(this._atlas,_loc8_,0);
         _loc8_ += _loc6_.x;
      }
      
      override public function handleCreateOneWeatherParticleBmp(param1:WeatherLayer_Particles, param2:int, param3:Number, param4:Number, param5:String) : IWeatherParticleBmp
      {
         var _loc6_:IWeatherParticleProviderStarling = providers[param1];
         return new WeatherParticleBmpStarling(_loc6_,param2,param3,param4,param5);
      }
      
      override public function handleFogChange() : void
      {
         this.fogStarling.handleFogChange();
      }
      
      override protected function handleCameraSizeChange() : void
      {
         this.fogStarling.handleCameraSizeChange();
      }
      
      override protected function handleCameraPositionChange() : void
      {
         this.fogStarling.handleCameraPositionChange();
      }
   }
}
