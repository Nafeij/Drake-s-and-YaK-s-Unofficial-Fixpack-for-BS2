package engine.landscape.view
{
   import engine.math.MathUtil;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.display.BlendMode;
   import starling.utils.VertexData;
   
   public class WeatherParticleBmpStarling implements IWeatherParticleBmp
   {
       
      
      public var _data:WeatherParticleBmp_Data;
      
      private var _provider:IWeatherParticleProvider;
      
      private var _particleSystem:WeatherManager_Particle;
      
      private var _layer:WeatherLayer;
      
      private var _manager:WeatherManager;
      
      private var _orients:Boolean;
      
      private var _stretch:Number = 1;
      
      private var _vx:Number = 0;
      
      private var _vy:Number = 0;
      
      private var _cachedColor:uint = 0;
      
      private var size:Point;
      
      private var raw:Vector.<Number>;
      
      private var matrix:Matrix;
      
      private var _x:Number = 0;
      
      private var _y:Number = 0;
      
      private var _blendMode:String = "normal";
      
      public var mVertexData:VertexData;
      
      public var verts:Array;
      
      private var _sx:Number = 1;
      
      private var _sy:Number = 1;
      
      private var _rotation:Number = 0;
      
      private var _alpha:Number = 1;
      
      public function WeatherParticleBmpStarling(param1:IWeatherParticleProvider, param2:int, param3:Number, param4:Number, param5:String = "normal")
      {
         this.matrix = new Matrix();
         this.mVertexData = new VertexData(4);
         this.verts = [new Point(),new Point(),new Point(),new Point()];
         super();
         this._data = new WeatherParticleBmp_Data(param3);
         this._provider = param1;
         this.mVertexData.setPremultipliedAlpha(true);
         this.raw = this.mVertexData.rawData;
         this._setupTexture(param1,param2,param5);
         this._setupData(param4);
      }
      
      public function cleanup() : void
      {
         this.mVertexData = null;
         this.matrix = null;
         this._data = null;
         this._provider = null;
         this._particleSystem = null;
         this._layer = null;
         this._manager = null;
         this.verts = null;
         this.raw = null;
      }
      
      private function _setupTexture(param1:IWeatherParticleProvider, param2:int, param3:String = "normal") : void
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
         this._layer = this._provider.layer;
         this._manager = this._particleSystem.manager;
         this._blendMode = param3;
         var _loc4_:IWeatherParticleProviderStarling = this._provider as IWeatherParticleProviderStarling;
         var _loc5_:WeatherLayerStarling = _loc4_.layer as WeatherLayerStarling;
         var _loc6_:Rectangle = _loc4_.getParticleUvs(param2);
         this.size = _loc4_.getParticleSize(param2);
         var _loc7_:int = this.size.x;
         var _loc8_:int = this.size.y;
         this.verts[0].setTo(0,0);
         this.verts[1].setTo(_loc7_,0);
         this.verts[2].setTo(0,_loc8_);
         this.verts[3].setTo(_loc7_,_loc8_);
         var _loc9_:int = 0;
         while(_loc9_ < 4)
         {
            this.mVertexData.setPosition(_loc9_,this.verts[_loc9_].x,this.verts[_loc9_].y);
            _loc9_++;
         }
         this.mVertexData.setTexCoords(0,_loc6_.x,_loc6_.y);
         this.mVertexData.setTexCoords(1,_loc6_.right,_loc6_.y);
         this.mVertexData.setTexCoords(2,_loc6_.x,_loc6_.bottom);
         this.mVertexData.setTexCoords(3,_loc6_.right,_loc6_.bottom);
      }
      
      public function setup(param1:IWeatherParticleProvider, param2:int, param3:Number, param4:String) : void
      {
         this._setupTexture(param1,param2,param4);
         this._setupData(param3);
      }
      
      public function _setupData(param1:Number) : void
      {
         this._orients = this._provider.particleSystem.orients;
         this._stretch = this._provider.particleSystem.stretch;
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
         this._data.setup(param1);
         this.reorient();
      }
      
      public function reorient() : void
      {
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Point = null;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         if(this._cachedColor != this._particleSystem.color)
         {
            this._cachedColor = this._particleSystem.color;
            this.mVertexData.setUniformColor(this._cachedColor);
         }
         var _loc1_:Number = this._particleSystem.alpha;
         _loc1_ *= this._particleSystem.getAlphaForCategory(this._layer.category);
         if(this._layer.category >= 2)
         {
            _loc1_ *= 1 - this._manager.fog.getDensity() * 0.9;
         }
         if(_loc1_ != this._alpha || this._cachedColor != this._particleSystem.color)
         {
            this._alpha = _loc1_;
            this.mVertexData.setUniformAlpha(this._alpha);
         }
         if(this._orients)
         {
            _loc11_ = this._manager.speedMod;
            _loc12_ = this._manager.wind * this._manager.windMod * _loc11_;
            _loc13_ = this._particleSystem.gravity * _loc11_;
            _loc14_ = this._particleSystem.variance;
            this._vx = _loc12_ + this._data.rw * _loc12_ * _loc14_;
            this._vy = _loc13_ + this._data.rg * _loc13_ * _loc14_;
            this._rotation = -Math.atan2(this._vx,this._vy);
         }
         else
         {
            this._rotation = 0;
            this._vx = this._vy = 0;
         }
         if(this._rotation == 0)
         {
            this.matrix.setTo(this._sx,0,0,this._sy,this._x,this._y);
         }
         else
         {
            this.matrix.identity();
            this.matrix.scale(this._sx,this._sy);
            this.matrix.rotate(this._rotation);
            this.matrix.translate(this._x,this._y);
         }
         var _loc2_:Number = this.matrix.a;
         var _loc3_:Number = this.matrix.b;
         var _loc4_:Number = this.matrix.c;
         var _loc5_:Number = this.matrix.d;
         var _loc6_:Number = Number.MAX_VALUE;
         var _loc7_:Number = -Number.MAX_VALUE;
         var _loc8_:Number = Number.MAX_VALUE;
         var _loc9_:Number = -Number.MAX_VALUE;
         var _loc10_:int = 0;
         while(_loc10_ < 4)
         {
            _loc15_ = this.verts[_loc10_];
            _loc16_ = _loc2_ * _loc15_.x + _loc4_ * _loc15_.y + this._x;
            _loc17_ = _loc5_ * _loc15_.y + _loc3_ * _loc15_.x + this._y;
            _loc6_ = Math.min(_loc6_,_loc16_);
            _loc7_ = Math.max(_loc7_,_loc16_);
            _loc8_ = Math.min(_loc8_,_loc17_);
            _loc9_ = Math.max(_loc9_,_loc17_);
            this.mVertexData.setPosition(_loc10_,_loc16_,_loc17_);
            _loc10_++;
         }
         this._data.setBounds(_loc6_ - this._x,_loc8_ - this._y,_loc7_ - this._x,_loc9_ - this.y);
      }
      
      public function get x() : Number
      {
         return this._x;
      }
      
      public function set x(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:Number = param1 - this._x;
         if(_loc2_)
         {
            _loc3_ = 0;
            while(_loc3_ < 4)
            {
               _loc4_ = _loc3_ * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
               this.raw[_loc4_] += _loc2_;
               _loc3_++;
            }
            this._x = param1;
         }
      }
      
      public function get y() : Number
      {
         return this._y;
      }
      
      public function set y(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:Number = param1 - this._y;
         if(_loc2_)
         {
            _loc3_ = 0;
            while(_loc3_ < 4)
            {
               _loc4_ = _loc3_ * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
               this.raw[int(_loc4_ + 1)] = this.raw[int(_loc4_ + 1)] + _loc2_;
               _loc3_++;
            }
         }
         this._y = param1;
      }
      
      public function get data() : WeatherParticleBmp_Data
      {
         return this._data;
      }
      
      public function update(param1:int, param2:Number, param3:Number) : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(this._orients)
         {
            _loc4_ = param1 * this._data.speedMod;
            if(Boolean(_loc4_) || Boolean(param2) || Boolean(param3))
            {
               _loc5_ = this._vx * _loc4_ * this._provider.particleSystem.horizontalMarch;
               _loc6_ = this._vy * _loc4_;
               _loc5_ += param2;
               _loc6_ += param3;
               _loc7_ = 0;
               while(_loc7_ < 4)
               {
                  _loc8_ = _loc7_ * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
                  this.raw[_loc8_] += _loc5_;
                  this.raw[int(_loc8_ + 1)] = this.raw[int(_loc8_ + 1)] + _loc6_;
                  _loc7_++;
               }
               this._x += _loc5_;
               this._y += _loc6_;
            }
            return true;
         }
         return false;
      }
      
      public function set blendMode(param1:String) : void
      {
         switch(param1)
         {
            case BlendMode.ADD:
            case BlendMode.NORMAL:
               this._blendMode = param1;
               return;
            default:
               throw new ArgumentError("unsupported blend mode [" + param1 + "] for weather particle ");
         }
      }
      
      public function get blendMode() : String
      {
         return this._blendMode;
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         if(param1 != this._alpha)
         {
            this._alpha = MathUtil.clampValue(param1,0,1);
            this.mVertexData.setUniformAlpha(this._alpha);
         }
      }
   }
}
