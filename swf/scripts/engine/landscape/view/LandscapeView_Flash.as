package engine.landscape.view
{
   import com.stoicstudio.platform.PlatformDisplay;
   import engine.anim.view.AnimClip;
   import engine.anim.view.XAnimClipSpriteBase;
   import engine.anim.view.XAnimClipSpriteFlash;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.BattleBoardViewFlash;
   import engine.core.locale.LocaleCategory;
   import engine.core.render.BoundedCamera;
   import engine.core.render.Camera;
   import engine.core.util.BitmapUtil;
   import engine.gui.core.GuiLabel;
   import engine.gui.core.GuiSprite;
   import engine.landscape.def.LandscapeLayerDef;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.landscape.model.Landscape;
   import engine.landscape.model.LandscapeLayer;
   import engine.math.Rng;
   import engine.resource.BitmapResource;
   import engine.scene.view.SceneViewSprite;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.PixelSnapping;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class LandscapeView_Flash extends LandscapeViewBase implements ILandscapeView
   {
       
      
      public var _renderable:DisplayObject;
      
      public var bmp:Bitmap;
      
      public var buffer:BitmapData;
      
      public var _guiSprite:GuiSprite;
      
      private var lastWidth:Number = 0;
      
      private var lastHeight:Number = 0;
      
      private var bufferQuality:String = "low";
      
      private var renderRect:Rectangle;
      
      private var bufferFrame:Shape;
      
      private var pixelizeMatrix:Matrix;
      
      private var pixelizeReverseMatrix:Matrix;
      
      public function LandscapeView_Flash(param1:SceneViewSprite, param2:Landscape, param3:Number, param4:Number, param5:Rng, param6:Boolean, param7:int, param8:Boolean = true)
      {
         var _loc9_:Camera = null;
         this.bmp = new Bitmap();
         this._guiSprite = new GuiSprite();
         this.renderRect = new Rectangle();
         this.bufferFrame = LandscapeViewConfig.DEBUG_RENDER_FRAME ? new Shape() : null;
         this.pixelizeMatrix = new Matrix();
         this.pixelizeReverseMatrix = new Matrix();
         super(param1,param2,param3,param4,param5,param6,param7,param8);
         if(LandscapeViewConfig.BUFFER_RENDER_ENABLED && param8 && !param2.def.highQuality)
         {
            this._renderable = this.bmp;
            _loc9_ = param1.scene._camera;
         }
         else
         {
            this._renderable = this._guiSprite;
            if(this.bufferFrame)
            {
               this._guiSprite.addChild(this.bufferFrame);
            }
         }
         if(param6 == false)
         {
            this._guiSprite.mouseEnabled = false;
            this._guiSprite.mouseChildren = false;
         }
         updateTravelView();
         finishedLoading();
      }
      
      override public function createLandscapeViewWrapper() : DisplayObjectWrapper
      {
         var _loc1_:DisplayObjectWrapper = new DisplayObjectWrapperFlash(this._guiSprite);
         _loc1_.name = "landscape_view_flash";
         PlatformDisplay.disableEdgeAAMode(this._guiSprite);
         return _loc1_;
      }
      
      override public function setPosition(param1:Number, param2:Number) : void
      {
         this._guiSprite.setPosition(param1,param2);
         super.setPosition(param1,param2);
      }
      
      public function get renderable() : DisplayObject
      {
         return this._renderable;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._guiSprite.visible = param1;
         this._renderable.visible = param1;
      }
      
      public function get visible() : Boolean
      {
         return this._guiSprite.visible;
      }
      
      override protected function handleUpdate(param1:int) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this.bmp == this._renderable)
         {
            this.doRenderLandscapeView();
         }
         else if(this.bufferFrame)
         {
            _loc2_ = sceneView.width / this._guiSprite.scaleX;
            _loc3_ = sceneView.height / this._guiSprite.scaleY;
            if(_loc2_ != this.lastWidth || _loc3_ != this.lastHeight)
            {
               this.lastWidth = _loc2_;
               this.lastHeight = _loc3_;
               this.bufferFrame.x = -_loc2_ / 2;
               this.bufferFrame.y = -_loc3_ / 2;
               this.bufferFrame.graphics.clear();
               this.bufferFrame.graphics.lineStyle(8,16776960,0.7);
               this.bufferFrame.graphics.drawRect(0,0,_loc2_,_loc3_);
               this.bufferFrame.graphics.moveTo(0,0);
               this.bufferFrame.graphics.lineTo(_loc2_,_loc3_);
               this.bufferFrame.graphics.moveTo(_loc2_,0);
               this.bufferFrame.graphics.lineTo(0,_loc3_);
            }
         }
      }
      
      override protected function handleCleanup() : void
      {
         if(this.buffer)
         {
            this.buffer.dispose();
            this.buffer = null;
         }
      }
      
      override protected function handleCreateLayerSprite(param1:LandscapeLayerDef) : DisplayObjectWrapper
      {
         return new DisplayObjectWrapperFlash(new Sprite());
      }
      
      override public function handleCreateWeatherManager() : WeatherManager
      {
         return new WeatherManager(this);
      }
      
      override protected function handleCreateSnowLayer(param1:int, param2:LandscapeLayer) : WeatherLayer
      {
         var _loc3_:WeatherLayerFlash = new WeatherLayerFlash(_weather,this,param1,param2);
         landscapeViewWrapper.addChild(_loc3_.present);
         return _loc3_;
      }
      
      override protected function handleCreateSimpleTooltipsLayer() : ISimpleTooltipsLayer
      {
         var _loc1_:SimpleTooltipsLayer_Flash = new SimpleTooltipsLayer_Flash(this,logger);
         landscapeViewWrapper.addChild(_loc1_.dow);
         return _loc1_;
      }
      
      override protected function handleGenerateAnchor(param1:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         var _loc2_:Sprite = new Sprite();
         var _loc3_:Graphics = _loc2_.graphics;
         _loc3_.lineStyle(2,16711680);
         _loc3_.beginFill(16776960,0.8);
         _loc3_.drawCircle(0,0,9);
         _loc3_.endFill();
         _loc3_.lineStyle(3,16711680,1);
         _loc3_.drawCircle(0,-53,3);
         _loc3_.moveTo(0,4);
         _loc3_.lineTo(0,-50);
         _loc3_.moveTo(0,0);
         _loc3_.lineTo(-20,-20);
         _loc3_.lineTo(-20,-30);
         _loc3_.lineTo(-16,-26);
         _loc3_.moveTo(0,0);
         _loc3_.lineTo(20,-20);
         _loc3_.lineTo(20,-30);
         _loc3_.lineTo(16,-26);
         return new DisplayObjectWrapperFlash(_loc2_);
      }
      
      override public function createDisplayObjectWrapperForBitmapData(param1:Object, param2:BitmapData) : DisplayObjectWrapper
      {
         return this.createBitmapDataWrapper(param1,param2);
      }
      
      override public function createDisplayObjectWrapper() : DisplayObjectWrapper
      {
         return new DisplayObjectWrapperFlash(new Sprite());
      }
      
      override public function createBitmapDataWrapper(param1:Object, param2:BitmapData) : DisplayObjectWrapper
      {
         var _loc3_:Bitmap = new Bitmap(param2);
         return new DisplayObjectWrapperFlash(_loc3_);
      }
      
      override public function destroyBitmapDataWrapper(param1:DisplayObjectWrapper) : void
      {
         var _loc2_:DisplayObjectWrapperFlash = param1 as DisplayObjectWrapperFlash;
         _loc2_.release();
      }
      
      override protected function handleGenerateBitmap(param1:BitmapResource, param2:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         if(!param1)
         {
            return null;
         }
         var _loc3_:Bitmap = param1.bmp;
         if(!_loc3_)
         {
            return null;
         }
         if(param2.layer.speed != 0 || param2.scaleX != 1 || param2.scaleY != 1 || param2.rotation != 0)
         {
         }
         var _loc4_:int = LandscapeViewConfig.pixelize;
         if(_loc4_)
         {
            this.pixelize(_loc3_,_loc4_);
         }
         _loc3_.pixelSnapping = PixelSnapping.NEVER;
         _loc3_.smoothing = true;
         return new DisplayObjectWrapperFlash(_loc3_);
      }
      
      override protected function handleGenerateAnimClipDisplay(param1:AnimClip, param2:Boolean) : XAnimClipSpriteBase
      {
         return new XAnimClipSpriteFlash(null,param1,_logger,param2);
      }
      
      override protected function handleCreateSpriteLabelDisplay(param1:DisplayObjectWrapper, param2:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         var _loc5_:DisplayObjectWrapper = null;
         var _loc3_:GuiLabel = new GuiLabel(_landscape.def.labelFontFace,_landscape.def.labelFontSize,_landscape.def.labelFontColor);
         var _loc4_:DisplayObjectWrapper = new DisplayObjectWrapperFlash(_loc3_);
         if(param1)
         {
            _loc5_ = new DisplayObjectWrapperFlash(new Sprite());
            _loc5_.addChild(param1);
            _loc5_.addChild(_loc4_);
            return _loc5_;
         }
         return _loc4_;
      }
      
      override protected function handleUpdateSpriteLabelDisplay(param1:DisplayObjectWrapper, param2:LandscapeSpriteDef) : void
      {
         var _loc5_:DisplayObject = null;
         var _loc3_:DisplayObjectWrapperFlash = param1 as DisplayObjectWrapperFlash;
         var _loc4_:GuiLabel = param1 as DisplayObjectWrapperFlash as GuiLabel;
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
         return this._guiSprite.localToGlobal(param1);
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
         var _loc4_:DisplayObjectWrapperFlash = null;
         if(param2)
         {
            _loc3_ = getLayerSprite(null,param1.layer);
            if(_loc3_)
            {
               _loc4_ = new DisplayObjectWrapperFlash(new Bitmap(param2));
               _loc3_.addChild(_loc4_);
               _loc4_.x = param1.offsetX - _loc4_.width / 2;
               _loc4_.y = param1.offsetY;
               _loc4_.scaleX = param1.scaleX;
               _loc4_.scaleY = param1.scaleY;
               _loc4_.rotationDegrees = param1.rotation;
               if(param1.blendMode)
               {
                  _loc4_.blendMode = param1.blendMode;
               }
               return _loc4_;
            }
         }
         return null;
      }
      
      override protected function handleCheckDisplayObjectWrapper(param1:DisplayObjectWrapper) : Boolean
      {
         return param1 is DisplayObjectWrapperFlash;
      }
      
      override public function createBattleBoardView(param1:BattleBoard) : BattleBoardView
      {
         return new BattleBoardViewFlash(param1,this,landscape.scene._context.soundDriver);
      }
      
      protected function doRenderLandscapeView() : void
      {
         var _loc1_:BoundedCamera = null;
         _loc1_ = _sceneView.scene._camera;
         this.bmp.scaleX = this.bmp.scaleY = _loc1_.scale;
         this.bmp.x = _loc1_.vbar;
         this.bmp.y = _loc1_.hbar;
         var _loc2_:int = (_loc1_.viewWidth - _loc1_.vbar * 2) * _loc1_.oo_scale;
         var _loc3_:int = (_loc1_.viewHeight - _loc1_.hbar * 2) * _loc1_.oo_scale;
         matrix.identity();
         matrix.translate(_loc2_ / 2,_loc3_ / 2);
         if(this.buffer)
         {
            if(this.buffer.width != _loc2_ || this.buffer.height != _loc3_)
            {
               this.buffer.dispose();
               this.buffer = null;
            }
         }
         if(!this.buffer)
         {
            this.buffer = new BitmapData(_loc2_,_loc3_,false,0);
            if(this.bufferFrame)
            {
               this.bufferFrame.graphics.clear();
               this.bufferFrame.graphics.lineStyle(8,16711680,0.7);
               this.bufferFrame.graphics.drawRect(0,0,_loc2_,_loc3_);
               this.bufferFrame.graphics.moveTo(0,0);
               this.bufferFrame.graphics.lineTo(_loc2_,_loc3_);
               this.bufferFrame.graphics.moveTo(_loc2_,0);
               this.bufferFrame.graphics.lineTo(0,_loc3_);
            }
         }
         this.buffer.draw(this._guiSprite,matrix,null,null,null,false);
         if(this.bufferFrame)
         {
            this.buffer.draw(this.bufferFrame);
         }
         this.bmp.bitmapData = this.buffer;
         this.bmp.smoothing = true;
      }
      
      private function pixelize(param1:Bitmap, param2:int) : void
      {
         var _loc3_:BitmapData = param1.bitmapData;
         var _loc4_:BitmapData = new BitmapData(Math.ceil(_loc3_.width / param2),Math.ceil(_loc3_.height / param2),true,0);
         this.pixelizeMatrix.identity();
         var _loc5_:Number = 1 / param2;
         this.pixelizeMatrix.scale(_loc5_,_loc5_);
         BitmapUtil.drawWithQuality(_loc4_,param1,this.pixelizeMatrix,null,null,_loc4_.rect,true,StageQuality.HIGH);
         param1.bitmapData = _loc4_;
         var _loc6_:BitmapData = new BitmapData(_loc3_.width,_loc3_.height,true,0);
         this.pixelizeReverseMatrix.identity();
         this.pixelizeReverseMatrix.scale(param2,param2);
         BitmapUtil.drawWithQuality(_loc6_,param1,this.pixelizeReverseMatrix,null,null,_loc6_.rect,false,StageQuality.LOW);
         param1.bitmapData = _loc6_;
         _loc4_.dispose();
      }
   }
}
