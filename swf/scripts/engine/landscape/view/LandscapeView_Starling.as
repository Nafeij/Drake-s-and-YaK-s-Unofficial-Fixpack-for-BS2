package engine.landscape.view
{
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.anim.view.AnimClip;
   import engine.anim.view.XAnimClipSpriteBase;
   import engine.anim.view.XAnimClipSpriteStarling;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.BattleBoardViewStarling;
   import engine.core.locale.LocaleCategory;
   import engine.gui.core.GuiLabel;
   import engine.landscape.def.LandscapeLayerDef;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.landscape.model.Landscape;
   import engine.landscape.model.LandscapeLayer;
   import engine.math.Rng;
   import engine.resource.BitmapResource;
   import engine.scene.view.SceneViewSprite;
   import flash.display.BitmapData;
   import flash.display3D.Context3DTextureFormat;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.display.BlendMode;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.RenderTexture;
   import starling.textures.Texture;
   
   public class LandscapeView_Starling extends LandscapeViewBase implements ILandscapeView
   {
       
      
      private var _guiSprite:Sprite;
      
      private var dirtyClipRect:Boolean = true;
      
      private var renderTexture:RenderTexture;
      
      private var renderImage:Image;
      
      private var lastRts:Number = 1;
      
      private var lastScale:Number = 1;
      
      private var renderMatrix:Matrix;
      
      private var _stoppedRendering:Boolean;
      
      public function LandscapeView_Starling(param1:SceneViewSprite, param2:Landscape, param3:Number, param4:Number, param5:Rng, param6:Boolean, param7:int, param8:Boolean = true)
      {
         this._guiSprite = new Sprite();
         this.renderMatrix = new Matrix();
         super(param1,param2,param3,param4,param5,param6,param7,param8);
         if(param6 == false)
         {
         }
         updateTravelView();
      }
      
      override public function handleSceneViewResize() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         super.handleSceneViewResize();
         if(this._stoppedRendering)
         {
            return;
         }
         var _loc1_:Number = Platform.drawQuality;
         if(_loc1_ < 1)
         {
            _loc2_ = sceneView.width;
            _loc3_ = sceneView.height;
            _loc4_ = _loc2_ * _loc1_;
            _loc5_ = _loc3_ * _loc1_;
            if(this.renderTexture)
            {
               if(this.renderTexture.width != _loc4_ || this.renderTexture.height != _loc5_)
               {
                  this.renderTexture.dispose();
                  this.renderTexture = null;
               }
            }
            if(!this.renderTexture)
            {
               if(_loc4_ > 0 && _loc5_ > 0)
               {
                  this.renderTexture = new RenderTexture(this,_loc4_,_loc5_,false,1);
               }
            }
            if(this.renderTexture)
            {
               if(!this.renderImage)
               {
                  this.renderImage = new Image(this.renderTexture);
               }
               else
               {
                  this.renderImage.texture = this.renderTexture;
                  this.renderImage.readjustSize();
               }
            }
            if(this.renderImage)
            {
               this.renderImage.scaleX = this.renderImage.scaleY = 1 / _loc1_;
            }
            if(this._guiSprite.parent)
            {
               this._guiSprite.parent.removeChild(this._guiSprite);
            }
            if(!this.renderImage.parent)
            {
               PlatformStarling.instance.game.addChild(this.renderImage);
            }
         }
         else
         {
            if(Boolean(this.renderImage) && Boolean(this.renderImage.parent))
            {
               this.renderImage.parent.removeChild(this.renderImage);
            }
            if(!this._guiSprite.parent)
            {
               PlatformStarling.instance.game.addChild(this._guiSprite);
            }
         }
         this.dirtyClipRect = true;
      }
      
      override protected function cameraMatteChanged(param1:Event) : void
      {
         this.dirtyClipRect = true;
      }
      
      override protected function cameraSizeChanged(param1:Event) : void
      {
         this.dirtyClipRect = true;
      }
      
      private function recalculateStageClipRect() : Rectangle
      {
         var _loc1_:Number = camera.vbar;
         var _loc2_:Number = camera.hbar;
         var _loc3_:Number = _loc1_;
         var _loc4_:Number = _loc2_ + 1;
         var _loc5_:Number = sceneView.width - _loc1_;
         var _loc6_:Number = sceneView.height - _loc2_ - 2;
         var _loc7_:Rectangle = new Rectangle(_loc3_,_loc4_,_loc5_ - _loc3_,_loc6_ - _loc4_);
         PlatformStarling.instance.game.clipRect = _loc7_;
         return _loc7_;
      }
      
      private function recalculateClipRect() : void
      {
         this.dirtyClipRect = false;
         if(!this.renderTexture)
         {
            this.recalculateStageClipRect();
            return;
         }
         var _loc1_:Number = Platform.drawQuality;
         PlatformStarling.instance.game.clipRect = null;
         var _loc2_:Number = camera.vbar;
         var _loc3_:Number = camera.hbar;
         var _loc4_:Number = this._guiSprite.scaleX;
         var _loc5_:Number = this._guiSprite.x;
         var _loc6_:Number = this._guiSprite.y;
         var _loc7_:Number = -_loc5_ / _loc4_;
         var _loc8_:Number = -_loc6_ / _loc4_ + 1;
         var _loc9_:Number = _loc5_ / _loc4_;
         var _loc10_:Number = _loc6_ / _loc4_ - 2;
         var _loc11_:Rectangle = new Rectangle(_loc7_,_loc8_,_loc9_ - _loc7_,_loc10_ - _loc8_);
         var _loc12_:Number = _loc1_ / _loc4_;
         _loc11_.x += _loc2_ * _loc12_;
         _loc11_.y += _loc3_ * _loc12_;
         _loc11_.height -= _loc3_ * 2 * _loc12_ * _loc1_;
         _loc11_.width -= _loc2_ * 2 * _loc12_ * _loc1_;
         this._guiSprite.clipRect = _loc11_;
         this.renderMatrix.identity();
         this.renderMatrix.scale(_loc4_,_loc4_);
         this.renderMatrix.translate(this._guiSprite.x,this._guiSprite.y);
         this.renderMatrix.scale(_loc1_,_loc1_);
      }
      
      override public function createLandscapeViewWrapper() : DisplayObjectWrapper
      {
         var _loc1_:DisplayObjectWrapper = new DisplayObjectWrapperStarling(this._guiSprite);
         _loc1_.name = "landscape_view_starling";
         return _loc1_;
      }
      
      override public function setPosition(param1:Number, param2:Number) : void
      {
         if(this._guiSprite)
         {
            this._guiSprite.x = param1;
            this._guiSprite.y = param2;
         }
         super.setPosition(param1,param2);
      }
      
      public function set visible(param1:Boolean) : void
      {
         if(this._guiSprite)
         {
            this._guiSprite.visible = param1;
         }
      }
      
      public function get visible() : Boolean
      {
         return Boolean(this._guiSprite) && this._guiSprite.visible;
      }
      
      override protected function handleUpdate(param1:int) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc2_:Number = Platform.drawQuality;
         if(this.lastRts != _loc2_)
         {
            this.lastRts = _loc2_;
            if(this.renderTexture)
            {
               this.renderTexture.dispose();
               this.renderTexture = null;
            }
            this.handleSceneViewResize();
         }
         else if(this.lastScale != this._guiSprite.scaleX)
         {
            this.lastScale = this._guiSprite.scaleX;
            this.dirtyClipRect = true;
         }
         if(this.dirtyClipRect)
         {
            this.recalculateClipRect();
         }
         if(Boolean(this._guiSprite) && Boolean(this.renderTexture))
         {
            _loc3_ = 1;
            _loc4_ = 0;
            this.renderTexture.draw(this._guiSprite,this.renderMatrix,_loc3_,_loc4_);
         }
      }
      
      override protected function handleCleanup() : void
      {
         if(this.renderTexture)
         {
            if(!Platform.suspended)
            {
               this.renderTexture.dispose();
            }
            this.renderTexture = null;
         }
         if(this.renderImage)
         {
            if(this.renderImage.parent)
            {
               this.renderImage.parent.removeChild(this.renderImage);
            }
            this.renderImage.dispose();
            this.renderImage = null;
         }
         if(this._guiSprite)
         {
            if(this._guiSprite.parent)
            {
               this._guiSprite.parent.removeChild(this._guiSprite);
            }
            this._guiSprite.dispose();
            this._guiSprite = null;
         }
      }
      
      override public function stopRendering() : void
      {
         this._stoppedRendering = true;
         if(this.renderImage)
         {
            if(this.renderImage.parent)
            {
               this.renderImage.parent.removeChild(this.renderImage);
            }
         }
         if(this._guiSprite)
         {
            if(this._guiSprite.parent)
            {
               this._guiSprite.parent.removeChild(this._guiSprite);
            }
         }
      }
      
      override protected function handleCreateLayerSprite(param1:LandscapeLayerDef) : DisplayObjectWrapper
      {
         return new DisplayObjectWrapperStarling(new Sprite());
      }
      
      override public function handleCreateWeatherManager() : WeatherManager
      {
         return new WeatherManager(this);
      }
      
      override protected function handleCreateSnowLayer(param1:int, param2:LandscapeLayer) : WeatherLayer
      {
         var _loc3_:WeatherLayerStarling = new WeatherLayerStarling(_weather,this,param1,param2);
         landscapeViewWrapper.addChild(_loc3_.present);
         return _loc3_;
      }
      
      override protected function handleCreateSimpleTooltipsLayer() : ISimpleTooltipsLayer
      {
         var _loc1_:SimpleTooltipsLayer_Starling = new SimpleTooltipsLayer_Starling(this,logger);
         landscapeViewWrapper.addChild(_loc1_.dow);
         return _loc1_;
      }
      
      override protected function handleGenerateAnchor(param1:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         return null;
      }
      
      override protected function handleCheckDisplayObjectWrapper(param1:DisplayObjectWrapper) : Boolean
      {
         return param1 is DisplayObjectWrapperStarling;
      }
      
      override public function createDisplayObjectWrapperForBitmapData(param1:Object, param2:BitmapData) : DisplayObjectWrapper
      {
         return this.createBitmapDataWrapper(param1,param2);
      }
      
      override public function createDisplayObjectWrapper() : DisplayObjectWrapper
      {
         return new DisplayObjectWrapperStarling(new Sprite());
      }
      
      override public function createBitmapDataWrapper(param1:Object, param2:BitmapData) : DisplayObjectWrapper
      {
         var _loc3_:Texture = Texture.fromBitmapData(param1,param2,false);
         var _loc4_:Image = new Image(_loc3_);
         _loc4_.touchable = false;
         return new DisplayObjectWrapperStarling(_loc4_);
      }
      
      override public function destroyBitmapDataWrapper(param1:DisplayObjectWrapper) : void
      {
         var _loc2_:DisplayObjectWrapperStarling = param1 as DisplayObjectWrapperStarling;
         var _loc3_:Image = _loc2_.d as Image;
         if(_loc3_)
         {
            _loc3_.texture.dispose();
            _loc3_.dispose();
         }
         _loc2_.release();
      }
      
      override protected function handleGenerateBitmap(param1:BitmapResource, param2:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         var _loc3_:DisplayObject = null;
         if(!param1)
         {
            return null;
         }
         var _loc4_:Texture = null;
         _loc4_ = param1.getTexture();
         if(_loc4_)
         {
            _loc3_ = new Image(_loc4_);
            if(!param1.transparent)
            {
               _loc3_.blendMode = BlendMode.NONE;
            }
            param2.reductionScaleX = param1.scaleX;
            param2.reductionScaleY = param1.scaleY;
            return new DisplayObjectWrapperStarling(_loc3_);
         }
         logger.error("Unable to create bitmap texture for " + param1.url);
         return null;
      }
      
      override protected function handleGenerateAnimClipDisplay(param1:AnimClip, param2:Boolean) : XAnimClipSpriteBase
      {
         return new XAnimClipSpriteStarling(null,param1,_logger,param2);
      }
      
      override protected function handleCreateSpriteLabelDisplay(param1:DisplayObjectWrapper, param2:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         return null;
      }
      
      override protected function handleUpdateSpriteLabelDisplay(param1:DisplayObjectWrapper, param2:LandscapeSpriteDef) : void
      {
         var _loc5_:DisplayObject = null;
         var _loc3_:DisplayObjectWrapperStarling = param1 as DisplayObjectWrapperStarling;
         var _loc4_:GuiLabel = param1 as DisplayObjectWrapperStarling as GuiLabel;
         if(!_loc4_)
         {
            if(Boolean(_loc3_.doc) && _loc3_.doc.numChildren > 1)
            {
               _loc5_ = _loc3_.doc.getChildAt(1);
               if(_loc5_)
               {
                  _loc4_ = _loc5_ as GuiLabel;
               }
            }
         }
         if(_loc4_)
         {
            _loc4_.text = _landscape.context.locale.translate(LocaleCategory.GUI,param2.label);
            _loc4_.sizeToContent();
            _loc4_.center();
            if(param2.labelOffset)
            {
               _loc4_.setPosition(_loc4_.x + param2.labelOffset.x,_loc4_.y + param2.labelOffset.y);
            }
         }
      }
      
      override public function localToGlobal(param1:Point) : Point
      {
         if(this._guiSprite)
         {
            return this._guiSprite.localToGlobal(param1);
         }
         return param1;
      }
      
      override public function globalToLocal(param1:Point) : Point
      {
         if(this._guiSprite)
         {
            return this._guiSprite.globalToLocal(param1);
         }
         return param1;
      }
      
      override protected function handeAddHeraldryBitmapDataToAnchor(param1:LandscapeSpriteDef, param2:BitmapData) : DisplayObjectWrapper
      {
         var _loc3_:DisplayObjectWrapper = null;
         var _loc4_:Texture = null;
         var _loc5_:DisplayObject = null;
         var _loc6_:DisplayObjectWrapperStarling = null;
         if(param2)
         {
            _loc3_ = getLayerSprite(null,param1.layer);
            if(_loc3_)
            {
               _loc4_ = Texture.fromBitmapData(this,param2,false,false,1,Context3DTextureFormat.BGRA);
               _loc5_ = new Image(_loc4_);
               _loc6_ = new DisplayObjectWrapperStarling(_loc5_);
               _loc3_.addChild(_loc6_);
               _loc6_.x = param1.offsetX - _loc6_.width / 2;
               _loc6_.y = param1.offsetY;
               _loc6_.scaleX = param1.scaleX;
               _loc6_.scaleY = param1.scaleY;
               _loc6_.rotationDegrees = param1.rotation;
               if(param1.blendMode)
               {
                  _loc6_.blendMode = param1.blendMode;
               }
               return _loc6_;
            }
         }
         return null;
      }
      
      override public function createBattleBoardView(param1:BattleBoard) : BattleBoardView
      {
         return new BattleBoardViewStarling(param1,this,landscape.scene._context.soundDriver);
      }
      
      override public function getClickableUnderMouse(param1:Number, param2:Number) : LandscapeSpriteDef
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(!this._guiSprite.parent)
         {
            _loc3_ = this._guiSprite.scaleX;
            _loc4_ = this._guiSprite.x;
            _loc5_ = this._guiSprite.y;
            param1 -= _loc4_;
            param2 -= _loc5_;
            param1 /= _loc3_;
            param2 /= _loc3_;
         }
         return super.getClickableUnderMouse(param1,param2);
      }
   }
}
