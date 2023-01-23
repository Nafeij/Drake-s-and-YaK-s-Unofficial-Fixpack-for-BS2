package engine.landscape.view
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.display.Image;
   import starling.textures.Texture;
   
   public class WeatherLayerStarling_Fog
   {
      
      private static var _requiredTextureSize:Point = new Point(3,3);
       
      
      private var layer:WeatherLayerStarling;
      
      private var manager:WeatherManager;
      
      private var fog:WeatherLayer_Fog;
      
      private var _fogTex:Texture;
      
      private var _fogImage:Image;
      
      public function WeatherLayerStarling_Fog()
      {
         super();
      }
      
      public function toString() : String
      {
         return "[WeatherLayerStarling_Fog " + this.layer + "]";
      }
      
      public function setup(param1:WeatherLayerStarling) : void
      {
         this.layer = param1;
         this.fog = param1.fog;
         this.manager = param1.manager;
         this.handleFogChange();
      }
      
      public function cleanup() : void
      {
         if(this._fogImage)
         {
            this._fogImage.dispose();
            this._fogImage = null;
         }
         if(this._fogTex)
         {
            this._fogTex.dispose();
            this._fogTex = null;
         }
      }
      
      public function getRequiredTextureSize() : Point
      {
         return _requiredTextureSize;
      }
      
      public function initTextureAtlas(param1:BitmapData, param2:int, param3:int) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < 3)
         {
            _loc5_ = 0;
            while(_loc5_ < 3)
            {
               param1.setPixel32(param2 + _loc4_,param3 + _loc5_,4294967295);
               _loc5_++;
            }
            _loc4_++;
         }
      }
      
      public function finishTextureAtlas(param1:Texture, param2:int, param3:int) : void
      {
         if(this._fogTex)
         {
            this._fogTex.dispose();
         }
         this._fogTex = Texture.fromTexture(this,param1,new Rectangle(param2 + 1,param3 + 1,1,1));
         this.handleFogChange();
      }
      
      private function createFog() : void
      {
         if(this.layer && this.layer._sprite && this._fogTex && !this._fogImage)
         {
            this._fogImage = new Image(this._fogTex);
            this.layer._sprite.addChildAt(this._fogImage,0);
            this.handleCameraSizeChange();
            this.handleFogChange();
         }
      }
      
      private function destroyFog() : void
      {
         if(this._fogImage)
         {
            this._fogImage.removeFromParent(true);
            this._fogImage = null;
         }
      }
      
      public function handleFogChange() : void
      {
         var _loc1_:Number = NaN;
         if(!this.layer || !this.fog)
         {
            return;
         }
         if(this.fog.density > 0 && !this._fogImage)
         {
            this.createFog();
         }
         else if(this.fog.density == 0 && Boolean(this._fogImage))
         {
            this.destroyFog();
         }
         if(this._fogImage)
         {
            _loc1_ = 1;
            if(this.layer.category == 0)
            {
               _loc1_ = 0.25;
            }
            else if(this.layer.category == 1)
            {
               _loc1_ = 0.5;
            }
            this._fogImage.alpha = this.fog.density * _loc1_;
            this._fogImage.color = this.fog.color;
         }
      }
      
      public function handleCameraSizeChange() : void
      {
         if(this._fogImage)
         {
            this._fogImage.scaleX = this.layer._lastCameraWidth + 2;
            this._fogImage.scaleY = this.layer._lastCameraHeight + 2;
            this.handleCameraPositionChange();
         }
      }
      
      public function handleCameraPositionChange() : void
      {
         if(this._fogImage && this.layer && Boolean(this.layer.present))
         {
            this._fogImage.x = -this.layer.present.x - this._fogImage.width / 2;
            this._fogImage.y = -this.layer.present.y - this._fogImage.height / 2;
         }
      }
   }
}
