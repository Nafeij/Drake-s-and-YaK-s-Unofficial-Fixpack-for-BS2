package engine.landscape.view
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import com.greensock.easing.Quad;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.gui.IGuiGpNavButton;
   import engine.gui.tooltip.SimpleTooltip;
   import engine.gui.tooltip.SimpleTooltipStyle;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.saga.Saga;
   import engine.scene.ITextBitmapGenerator;
   import engine.scene.SceneContext;
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class ClickablePair implements IGuiGpNavButton
   {
      
      public static var ALLOW_TOOLTIPS_EN:Boolean = false;
      
      public static var ALLOW_FOLLOW_MOUSE:Boolean = true;
      
      private static var PULSE_ALPHA:Number = 0.3;
      
      private static var CLICK_ALPHA:Number = 0.6;
       
      
      public var container:DisplayObjectWrapper;
      
      public var def:LandscapeSpriteDef;
      
      public var sprite:DisplayObjectWrapper;
      
      public var hoverSprite:DisplayObjectWrapper;
      
      private var _enabled:Boolean = true;
      
      private var _paused:Boolean = false;
      
      private var _hovering:Boolean = false;
      
      private var _clicking:Boolean = false;
      
      private var _id:String;
      
      private var logger:ILogger;
      
      private var saga:Saga;
      
      public var tooltip:SimpleTooltip;
      
      public var lv:LandscapeViewBase;
      
      private var _visibleHoverSprite:Boolean;
      
      private var _hoverStagePositionEnabled:Boolean;
      
      private var _hoverStagePosition:Point;
      
      private var _hoverContainerPosition:Point;
      
      private var _tooltipPosDirty:Boolean = true;
      
      private var pulsing:Boolean;
      
      private var scratch:Point;
      
      public function ClickablePair(param1:String, param2:ILogger, param3:LandscapeSpriteDef, param4:DisplayObjectWrapper, param5:DisplayObjectWrapper, param6:DisplayObjectWrapper, param7:Saga, param8:LandscapeViewBase)
      {
         this._hoverStagePosition = new Point();
         this._hoverContainerPosition = new Point();
         this.scratch = new Point();
         this._id = param1;
         this.logger = param2;
         this.container = param4;
         this.def = param3;
         this.sprite = param5;
         this.hoverSprite = param6;
         this.saga = param7;
         this.lv = param8;
         if(param5)
         {
            param4.addChild(param5);
            param5.alpha = 0;
         }
         this.paused = Boolean(param7) && param7.paused;
         this.updateClicking();
         this._visibleHoverSprite = false;
         if(param6)
         {
            param6.visible = false;
            param4.addChild(param6);
         }
         this.updateHoveringPosition();
         super();
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function toString() : String
      {
         return this.id;
      }
      
      public function get shouldTooltip() : Boolean
      {
         var _loc1_:SceneContext = null;
         var _loc2_:Locale = null;
         if(!this.def || !this.def.tooltip || !this.def.tooltip.text)
         {
            return false;
         }
         if(!ALLOW_TOOLTIPS_EN)
         {
            _loc1_ = this.lv.sceneView.scene._context;
            _loc2_ = _loc1_.locale;
            if(Boolean(_loc2_) && _loc2_.isEn)
            {
               return false;
            }
         }
         return true;
      }
      
      private function createTooltip() : void
      {
         if(!this.shouldTooltip)
         {
            return;
         }
         if(this.tooltip)
         {
            this.tooltip.cleanup();
            this.tooltip = null;
         }
         this._tooltipPosDirty = true;
         var _loc1_:SimpleTooltipStyle = this.lv.getTooltipStyle(this.def.tooltip.style);
         var _loc2_:SceneContext = this.lv.sceneView.scene._context;
         var _loc3_:ITextBitmapGenerator = _loc2_.textBitmapGenerator;
         var _loc4_:Locale = _loc2_.locale;
         this.tooltip = new SimpleTooltip(this.def.nameId,_loc1_,_loc3_,this.lv,this.lv.simpleTooltipsLayer);
         this.tooltip.setText(_loc4_,this.def.tooltip.text);
      }
      
      public function cleanup() : void
      {
         TweenMax.killTweensOf(this.sprite);
         this.def = null;
         if(this.sprite)
         {
            this.sprite.cleanup();
            this.sprite = null;
         }
         if(this.hoverSprite)
         {
            this.hoverSprite.cleanup();
            this.hoverSprite = null;
         }
         if(this.tooltip)
         {
            this.tooltip.cleanup();
            this.tooltip = null;
         }
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(this._enabled == param1)
         {
         }
         this._enabled = param1;
         var _loc2_:Boolean = this._enabled && !this._paused;
         this._visibleHoverSprite = _loc2_ && this._hovering;
         if(this.hoverSprite)
         {
            this.hoverSprite.visible = this._visibleHoverSprite;
         }
         if(this.sprite)
         {
            this.sprite.visible = _loc2_;
         }
      }
      
      public function get visible() : Boolean
      {
         return Boolean(this.sprite) && this.sprite.visible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         if(this.sprite)
         {
            this.sprite.visible = param1;
         }
      }
      
      public function localToGlobal(param1:Point) : Point
      {
         this.logger.error("Probably shouldn\'t be doing this...");
         return !!this.sprite ? this.sprite.localToGlobal(param1) : param1;
      }
      
      public function get paused() : Boolean
      {
         return this._paused;
      }
      
      public function set paused(param1:Boolean) : void
      {
         if(this._paused == param1)
         {
            return;
         }
         this._paused = param1;
         var _loc2_:Boolean = this._enabled && !this._paused;
         this._visibleHoverSprite = _loc2_ && this._hovering;
         if(this.hoverSprite)
         {
            this.hoverSprite.visible = this._visibleHoverSprite;
         }
         if(this.sprite)
         {
            this.sprite.visible = _loc2_;
         }
         if(this._paused)
         {
            TweenMax.killTweensOf(this.sprite);
         }
      }
      
      public function get hovering() : Boolean
      {
         return this._hovering;
      }
      
      public function set hovering(param1:Boolean) : void
      {
         if(this._hovering == param1)
         {
            return;
         }
         this._hovering = param1;
         this.updateHovering();
      }
      
      private function updateHoveringPosition() : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(!this.tooltip)
         {
            return;
         }
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         if(ALLOW_FOLLOW_MOUSE && this._hoverStagePositionEnabled && this._hovering)
         {
            if(!this.lv.showTooltips || this.tooltip.suppressedByPrereq)
            {
               this._tooltipPosDirty = true;
               _loc1_ += this._hoverContainerPosition.x;
               _loc2_ += this._hoverContainerPosition.y;
               _loc3_ = this.lv.camera.zoom;
               _loc4_ = 0;
               _loc5_ = 30;
               _loc1_ += _loc4_ / _loc3_;
               _loc2_ += _loc5_ / _loc3_;
               this.tooltip.setPos(this.container.x,this.container.y,_loc1_,_loc2_);
               this.tooltip.glowing = false;
               return;
            }
         }
         if(this._tooltipPosDirty)
         {
            this._tooltipPosDirty = false;
            if(Boolean(this.def.tooltip) && Boolean(this.def.tooltip.center))
            {
               _loc1_ += this.def.tooltip.center.x;
               _loc2_ += this.def.tooltip.center.y;
            }
            this.tooltip.setPos(this.container.x,this.container.y,_loc1_,_loc2_);
         }
      }
      
      public function setHoverStagePosition(param1:Number, param2:Number) : void
      {
         if(this._hoverStagePosition.x == param1 && this._hoverStagePosition.x == param2)
         {
            return;
         }
         this._hoverStagePosition.setTo(param1,param2);
         this._hoverContainerPosition = this.container.globalToLocal(this._hoverStagePosition);
         this.updateHoveringPosition();
      }
      
      public function setHoverStagePositionEnabled(param1:Boolean) : void
      {
         if(this._hoverStagePositionEnabled == param1)
         {
            return;
         }
         this._hoverStagePositionEnabled = param1;
         this.updateHoveringPosition();
      }
      
      public function updateHovering() : void
      {
         var _loc1_:Boolean = false;
         if(!this.hoverSprite)
         {
            return;
         }
         if(!this._hovering)
         {
            this._visibleHoverSprite = false;
            this.hoverSprite.visible = false;
            this.clicking = false;
         }
         else
         {
            _loc1_ = this._enabled && !this._paused;
            this._visibleHoverSprite = _loc1_;
            this.hoverSprite.visible = this._visibleHoverSprite;
         }
         this.updateTooltip();
      }
      
      public function bringTooltipToFront() : void
      {
         if(this.tooltip)
         {
            this.tooltip.bringToFront();
         }
      }
      
      public function updateTooltip() : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:SimpleTooltipStyle = null;
         var _loc4_:String = null;
         var _loc5_:SceneContext = null;
         var _loc6_:Locale = null;
         if(!this.shouldTooltip)
         {
            if(this.tooltip)
            {
               this.tooltip.cleanup();
               this.tooltip = null;
            }
            return;
         }
         if(this.tooltip)
         {
            _loc3_ = this.tooltip.style;
            _loc4_ = this.def.tooltip.style;
            if(!_loc4_)
            {
               _loc4_ = this.lv.defaultTooltipStyleId;
            }
            if(_loc3_.def.id != _loc4_)
            {
               this.tooltip.cleanup();
               this.tooltip = null;
            }
         }
         if(!this.tooltip)
         {
            this.createTooltip();
         }
         else
         {
            _loc5_ = this.lv.sceneView.scene._context;
            _loc6_ = _loc5_.locale;
            this.tooltip.setText(_loc6_,this.def.tooltip.text);
         }
         var _loc1_:Boolean = this._visibleHoverSprite;
         if(this.def.tooltip.prereq_showall)
         {
            if(!this.saga.expression.evaluate(this.def.tooltip.prereq_showall,true))
            {
               _loc2_ = true;
            }
         }
         if(!_loc1_)
         {
            if(this.lv.showTooltips || !this.sprite)
            {
               if(!_loc2_)
               {
                  _loc1_ = true;
               }
            }
         }
         this.tooltip.suppressedByPrereq = _loc2_;
         this.tooltip.visible = _loc1_;
         if(this.tooltip.visible)
         {
            this._tooltipPosDirty = true;
            this.tooltip.glowing = this._hovering;
            this.updateHoveringPosition();
         }
      }
      
      public function get clicking() : Boolean
      {
         return this._clicking;
      }
      
      public function set clicking(param1:Boolean) : void
      {
         if(this._clicking != param1)
         {
            this._clicking = param1;
         }
         this.updateClicking();
      }
      
      public function pulseGpPress() : void
      {
         TweenMax.killTweensOf(this.sprite);
         if(this._paused || !this._enabled)
         {
            return;
         }
         this.sprite.visible = true;
         this.sprite.alpha = CLICK_ALPHA;
         this.pulsing = true;
         TweenMax.to(this.sprite,0.3,{
            "alpha":0,
            "ease":Linear.easeNone,
            "onComplete":this.tweenCompleteHandler
         });
      }
      
      public function pulse() : void
      {
         if(this._paused || !this._enabled || !this.sprite)
         {
            return;
         }
         if(!this.pulsing && !this.clicking && !this.hovering)
         {
            this.sprite.visible = true;
            this.sprite.alpha = 0;
            this.pulsing = true;
            TweenMax.to(this.sprite,1.3,{
               "alpha":PULSE_ALPHA,
               "repeat":1,
               "yoyo":true,
               "ease":Quad.easeInOut,
               "onComplete":this.tweenCompleteHandler
            });
         }
      }
      
      public function updateClicking() : void
      {
         if(!this.sprite)
         {
            return;
         }
         TweenMax.killTweensOf(this.sprite);
         this.pulsing = false;
         if(!this._enabled || this._paused || LandscapeViewConfig.disableClickables)
         {
            this.sprite.visible = false;
            this.sprite.alpha = 0;
            this._visibleHoverSprite = false;
            if(this.hoverSprite)
            {
               this.hoverSprite.visible = false;
            }
            return;
         }
         if(this.clicking || LandscapeViewConfig.showClickables)
         {
            this.sprite.visible = true;
            this.sprite.alpha = CLICK_ALPHA;
         }
         else
         {
            this.sprite.alpha = 0;
            this.sprite.visible = false;
         }
         this._visibleHoverSprite = this._hovering;
         if(this.hoverSprite)
         {
            this.hoverSprite.visible = this._visibleHoverSprite;
         }
      }
      
      private function tweenCompleteHandler() : void
      {
         this.updateClicking();
      }
      
      public function getCenterPointGlobal() : Point
      {
         if(this.def.clickMask)
         {
            this.scratch.setTo(this.def.offsetX + this.def.scaleX * this.def.localrect.width / 2,this.def.offsetY + this.def.scaleY * this.def.localrect.height / 2);
            return this.container.localToGlobal(this.scratch);
         }
         return null;
      }
      
      public function getRectGlobal() : Rectangle
      {
         return this.getRectRelative(null);
      }
      
      public function getRectRelative(param1:DisplayObject) : Rectangle
      {
         var _loc2_:Point = null;
         var _loc3_:Point = null;
         if(this.def.clickMask)
         {
            this.scratch.setTo(this.def.offsetX + this.def.localrect.left,this.def.offsetY + this.def.localrect.top);
            _loc2_ = this.container.localToGlobal(this.scratch);
            this.scratch.setTo(this.def.offsetX + this.def.localrect.right,this.def.offsetY + this.def.localrect.bottom);
            _loc3_ = this.container.localToGlobal(this.scratch);
            if(param1)
            {
               _loc3_ = param1.globalToLocal(_loc3_);
               _loc2_ = param1.globalToLocal(_loc2_);
            }
            return new Rectangle(_loc2_.x,_loc2_.y,_loc3_.x - _loc2_.x,_loc3_.y - _loc2_.y);
         }
         return null;
      }
      
      public function getBottomPointGlobal() : Point
      {
         if(this.def.clickMask)
         {
            this.scratch.setTo(this.def.offsetX + this.def.scaleX * this.def.clickMask.width / 2,this.def.offsetY + this.def.scaleY * this.def.clickMask.height);
            return this.container.localToGlobal(this.scratch);
         }
         return null;
      }
      
      public function getCenterPointLocal() : Point
      {
         if(this.def.clickMask)
         {
            this.scratch.setTo(this.def.offsetX + this.def.scaleX * this.def.clickMask.width / 2,this.def.offsetY + this.def.scaleY * this.def.clickMask.height / 2);
            return this.scratch;
         }
         return null;
      }
      
      public function isUnderMouse(param1:Number, param2:Number) : Boolean
      {
         var _loc4_:Point = null;
         if(!this.enabled || !this.sprite)
         {
            return false;
         }
         var _loc3_:Point = new Point(param1,param2);
         if(this.def.clickMask)
         {
            if(this.sprite)
            {
               _loc4_ = this.sprite.globalToLocal(_loc3_);
               _loc4_.x *= this.sprite.scaleX;
               _loc4_.y *= this.sprite.scaleY;
            }
            else
            {
               _loc4_ = this.container.globalToLocal(_loc3_);
               _loc4_.x -= this.def.offsetX;
               _loc4_.y -= this.def.offsetY;
            }
            return this.def.testClickMask(_loc4_.x,_loc4_.y);
         }
         if(this.sprite.hasParent)
         {
            return this.sprite.hitTestPoint(param1,param2);
         }
         _loc4_ = this.container.globalToLocal(_loc3_);
         return this.sprite.hitTestPoint(_loc4_.x,_loc4_.y);
      }
      
      public function press() : void
      {
         this.logger.error("can\'t press this way");
      }
      
      public function setHovering(param1:Boolean) : void
      {
         this.hovering = param1;
      }
      
      public function getNavRectangle(param1:DisplayObject) : Rectangle
      {
         return this.getRectGlobal();
      }
   }
}
