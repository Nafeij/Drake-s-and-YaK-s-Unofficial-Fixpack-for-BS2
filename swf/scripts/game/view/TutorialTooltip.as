package game.view
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import com.stoicstudio.platform.Platform;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBinder;
   import engine.core.fsm.Fsm;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.core.render.BoundedCamera;
   import engine.core.util.MovieClipAdapter;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpTextHelper;
   import engine.gui.IGuiButton;
   import engine.gui.core.GuiSprite;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.scene.model.Scene;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import game.gui.page.ScenePage;
   import game.session.states.SceneState;
   
   public class TutorialTooltip extends GuiSprite
   {
      
      public static const EVENT_BUTTON:String = "TutorialTooltip.EVENT_BUTTON";
      
      private static const MARGIN:int = 8;
      
      private static const SCREEN_MARGIN:int = 20;
      
      private static const UI_SAFE_ZONE_SCREEN_MARGIN:int = 90;
      
      private static var last_id:int;
       
      
      private var _text:String;
      
      private var tf:TextField;
      
      private var tt_align:TutorialTooltipAlign;
      
      private var tt_anchor:TutorialTooltipAnchor;
      
      private var tt_anchor_offset:Number = 0;
      
      private var path:String;
      
      public var layer:TutorialLayer;
      
      private var block:MovieClip;
      
      private var bg:MovieClip = null;
      
      private var arrow:MovieClip = null;
      
      private var eyeball:MovieClip = null;
      
      private var arrowAdapter:MovieClipAdapter;
      
      private var button:IGuiButton;
      
      private var ADJUST_THRESHOLD:Number = 0;
      
      private var attach:DisplayObject;
      
      private var attach_dow:DisplayObjectWrapper;
      
      private var attach_pt:Point;
      
      private var dpiScale:Number = 1;
      
      private var cmd_ok:Cmd;
      
      private var gp_ok:GuiGpBitmap;
      
      private var fsm:Fsm;
      
      public var id:int;
      
      public var canVisible:Boolean = true;
      
      private var tt_width:Number = 0;
      
      private var tt_height:Number = 0;
      
      public var autoclose:Boolean;
      
      private var _useButton:Boolean;
      
      private var _useArrow:Boolean;
      
      public var logger:ILogger;
      
      public var buttonCallback:Function;
      
      private var _neverClamp:Boolean;
      
      private var _w:int = -1;
      
      private var _h:int = -1;
      
      private var directionalIndicator:MovieClip = null;
      
      private var cleanedup:Boolean;
      
      private var gpTextHelper:GuiGpTextHelper = null;
      
      private var zero:Point;
      
      private var presentedTooltip:Boolean;
      
      private var _lastViewChange:int;
      
      private var pzero:Point;
      
      public function TutorialTooltip(param1:TutorialLayer, param2:String, param3:TutorialTooltipAlign, param4:TutorialTooltipAnchor, param5:Number, param6:String, param7:Boolean, param8:Boolean, param9:Number, param10:Function)
      {
         this.zero = new Point();
         this.pzero = new Point(0,0);
         super();
         this.id = ++last_id;
         this.ADJUST_THRESHOLD = param9;
         this.buttonCallback = param10;
         this._text = param6;
         this.layer = param1;
         this.path = param2;
         this.tt_align = param3;
         this.tt_anchor = param4;
         this.tt_anchor_offset = param5;
         this.mouseEnabled = false;
         this.mouseChildren = false;
         this.block = param1.block;
         this.block.mouseEnabled = false;
         this.block.mouseChildren = true;
         this.logger = param1.logger;
         this._useArrow = param7;
         this._useButton = param8;
         this.fsm = Boolean(param1.pm) && Boolean(param1.pm.config) ? param1.pm.config.fsm : null;
         if(!param1.block)
         {
            this.logger.error("No tutorial block");
         }
         this.setupTextField(param6);
         this.resizeToolTip();
         this.setupButtons();
         var _loc11_:Number = param1.width * BoundedCamera.UI_AUTHOR_WIDTH / this.width;
         var _loc12_:Number = param1.height * BoundedCamera.UI_AUTHOR_HEIGHT / this.height;
         this.dpiScale = Math.min(1.5,BoundedCamera.dpiFingerScale * Platform.textScale);
         this.tt_width = this.width;
         this.tt_height = this.height;
         this.checkScale();
         addChild(this.block);
      }
      
      public function get neverClamp() : Boolean
      {
         return this._neverClamp;
      }
      
      public function set neverClamp(param1:Boolean) : void
      {
         this._neverClamp = param1;
      }
      
      public function resetPath(param1:String) : void
      {
         this.path = param1;
         this.attach = null;
         this.attach_dow = null;
         this.attach_pt = null;
      }
      
      private function setupButtons() : void
      {
         if(this._useButton)
         {
            this.button = this.layer.button;
            this.button.movieClip.x = this.block.width - this.button.movieClip.width * 0.3;
            this.button.movieClip.y = this.block.height - this.button.movieClip.height * 0.3;
            this.block.addChild(this.button.movieClip);
            this.button.setDownFunction(this.buttonHandler);
            this.button.guiButtonContext = this.layer.context;
            this.width += this.button.movieClip.width * 0.7;
            this.height += this.button.movieClip.height * 0.7;
            this.gp_ok = GuiGp.ctorPrimaryBitmap(GpControlButton.A);
            this.block.addChild(this.gp_ok);
            this.gp_ok.x = this.button.movieClip.x + this.button.movieClip.width / 2;
            this.gp_ok.y = this.button.movieClip.y + (this.button.movieClip.height - this.gp_ok.height) / 2;
            this.cmd_ok = new Cmd("tut_tooltip_cmd_ok",this.cmdfunc_ok);
            GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_ok);
            KeyBinder.keybinder.bind(false,false,false,Keyboard.SPACE,this.cmd_ok,"");
            this.mouseChildren = true;
            this.button.movieClip.scaleX = this.button.movieClip.scaleY = 0;
            TweenMax.to(this.button.movieClip,0.3,{
               "delay":0.25,
               "scaleX":1,
               "scaleY":1,
               "ease":Quad.easeIn
            });
         }
         if(this._useArrow)
         {
            if(this._useButton)
            {
               this.eyeball = this.layer.eyeball;
            }
            else
            {
               this.arrow = this.layer.arrow;
            }
            if(this.directionalIndicator == null)
            {
               this.directionalIndicator = !!this.arrow ? this.arrow : this.eyeball;
               this.arrowAdapter = new MovieClipAdapter(this.directionalIndicator,30,null,false,this.layer.logger);
               this.arrowAdapter.playLooping();
            }
            this.directionalIndicator.mouseEnabled = false;
            this.directionalIndicator.mouseChildren = false;
            this.directionalIndicator.x = -Number.MAX_VALUE;
            this.directionalIndicator.y = -Number.MAX_VALUE;
            this.block.x = -Number.MAX_VALUE;
            this.block.y = -Number.MAX_VALUE;
            addChild(this.directionalIndicator);
         }
      }
      
      private function resizeToolTip() : void
      {
         var _loc1_:Point = new Point(0,0);
         _loc1_.x = this.tf.width + MARGIN * 2;
         _loc1_.y = this.tf.height + MARGIN * 2;
         this.tf.x = MARGIN;
         this.tf.y = MARGIN;
         if(!this.bg)
         {
            this.bg = this.block.getChildByName("bg") as MovieClip;
            this.bg.mouseEnabled = false;
         }
         if(this._w < 0)
         {
            this._w = this.bg.width;
            this._h = this.bg.height;
         }
         this.bg.scaleX = _loc1_.x / (this.bg.width / this.bg.scaleX);
         this.bg.scaleY = _loc1_.y / (this.bg.height / this.bg.scaleY);
         this.width = _loc1_.x;
         this.height = _loc1_.y;
      }
      
      override public function toString() : String
      {
         return this.id.toString() + " [" + (!!this._text ? this._text.substr(0,20) + "..." : "") + "]";
      }
      
      public function pulseButton() : void
      {
         if(this.button)
         {
            this.button.movieClip.scaleX = this.button.movieClip.scaleY = 1.5;
            TweenMax.to(this.button.movieClip,0.2,{
               "scaleX":1,
               "scaleY":1
            });
         }
      }
      
      private function getScreenMargin() : int
      {
         if(Platform.requiresUiSafeZoneBuffer)
         {
            return UI_SAFE_ZONE_SCREEN_MARGIN;
         }
         return SCREEN_MARGIN;
      }
      
      public function handleParentResize() : void
      {
         this.checkScale();
      }
      
      private function checkScale() : void
      {
         var _loc1_:Number = this.layer.width / (this.tt_width + this.getScreenMargin() * 2);
         var _loc2_:Number = this.layer.height / (this.tt_height + this.getScreenMargin() * 2);
         var _loc3_:Number = Math.min(_loc1_,_loc2_);
         var _loc4_:Number = Math.min(this.dpiScale,_loc3_);
         this.scaleX = this.scaleY = 1;
         if(this.block)
         {
            this.block.scaleX = this.block.scaleY = _loc4_;
            if(this.arrow)
            {
               this.arrow.scaleX = this.arrow.scaleY = _loc4_;
            }
         }
      }
      
      public function updateTooltipText(param1:String) : void
      {
         this._text = param1;
         this.setupTextField(param1);
         this.resizeToolTip();
         if(this._useButton)
         {
            this.button.movieClip.x = this.width - this.button.movieClip.width * 0.3;
            this.button.movieClip.y = this.height - this.button.movieClip.height * 0.3;
            this.gp_ok.x = this.button.movieClip.x + this.button.movieClip.width / 2;
            this.gp_ok.y = this.button.movieClip.y + (this.button.movieClip.height - this.gp_ok.height) / 2;
         }
         if(this._useArrow)
         {
         }
         this.tt_width = this.width;
         this.tt_height = this.height;
         this.checkScale();
         this.update();
      }
      
      override public function cleanup() : void
      {
         if(this.cleanedup)
         {
            return;
         }
         this.cleanedup = true;
         if(this.cmd_ok)
         {
            GpBinder.gpbinder.unbind(this.cmd_ok);
            KeyBinder.keybinder.unbind(this.cmd_ok);
            this.cmd_ok.cleanup();
         }
         if(this.gp_ok)
         {
            GuiGp.releasePrimaryBitmap(this.gp_ok);
         }
         if(this.arrowAdapter)
         {
            this.arrowAdapter.cleanup();
            this.arrowAdapter = null;
         }
         if(!this.attach)
         {
         }
         if(this.gpTextHelper)
         {
            this.gpTextHelper.cleanup();
         }
         super.cleanup();
      }
      
      private function setupTextField(param1:String) : void
      {
         if(param1.indexOf("<font color=’#ff0000’>力量<") == 0)
         {
            param1 = param1;
         }
         var _loc2_:Locale = this.layer.context.locale;
         this.tf = this.block.getChildByName("text") as TextField;
         this.tf.width = 800;
         this.tf.height = 700;
         this.tf.selectable = false;
         this.tf.mouseEnabled = false;
         if(this.gpTextHelper == null)
         {
            this.gpTextHelper = new GuiGpTextHelper(_loc2_,this.logger);
         }
         else
         {
            this.gpTextHelper.cleanup();
         }
         if(GuiGpTextHelper.hasGpTokens(param1))
         {
            param1 = this.gpTextHelper.preProcessText(param1,this.layer.logger);
         }
         this.tf.condenseWhite = false;
         this.tf.htmlText = param1;
         _loc2_.fixTextFieldFormat(this.tf,null,null,true);
         this.tf.cacheAsBitmap = true;
         this.tf.width = this.tf.textWidth + 10;
         this.tf.height = this.tf.textHeight + 4;
         if(this.gpTextHelper)
         {
            this.gpTextHelper.finishProcessing(this.tf);
         }
      }
      
      private function rectToLayer(param1:Rectangle) : Rectangle
      {
         var _loc2_:Point = new Point(param1.x,param1.y);
         var _loc3_:Point = new Point(param1.right,param1.bottom);
         _loc2_ = this.layer.globalToLocal(_loc2_);
         _loc3_ = this.layer.globalToLocal(_loc3_);
         return new Rectangle(_loc2_.x,_loc2_.y,_loc3_.x - _loc2_.x,_loc3_.y - _loc2_.y);
      }
      
      private function rectToGlobal(param1:DisplayObject, param2:Rectangle) : Rectangle
      {
         var _loc3_:Point = new Point(param2.x,param2.y);
         var _loc4_:Point = new Point(param2.right,param2.bottom);
         _loc3_ = param1.localToGlobal(_loc3_);
         _loc4_ = param1.localToGlobal(_loc4_);
         return new Rectangle(_loc3_.x,_loc3_.y,_loc4_.x - _loc3_.x,_loc4_.y - _loc3_.y);
      }
      
      public function update() : Boolean
      {
         var _loc6_:Rectangle = null;
         var _loc15_:Object = null;
         var _loc16_:ScenePage = null;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         if(!this.canVisible)
         {
            visible = false;
            return false;
         }
         if(!stage || !parent)
         {
            return true;
         }
         if(Boolean(this.attach) && !this.attach.stage)
         {
            this.attach = null;
         }
         var _loc1_:SceneState = !!this.fsm ? this.fsm.current as SceneState : null;
         var _loc2_:Scene = !!_loc1_ ? _loc1_.scene : null;
         if(Boolean(_loc2_) && !_loc2_.ready)
         {
            visible = false;
            return true;
         }
         if(this.attach_pt)
         {
            if(_loc2_._camera.viewChangeCounter > this._lastViewChange)
            {
               this.attach_pt = null;
            }
         }
         if(!this.attach && !this.attach_dow && !this.attach_pt)
         {
            _loc15_ = this.layer.findObject(this.path,false);
            this.attach = !!_loc15_ ? _loc15_.object as DisplayObject : null;
            this.attach_dow = !!_loc15_ ? _loc15_.object as DisplayObjectWrapper : null;
            this.attach_pt = !!_loc15_ ? _loc15_.object as Point : null;
         }
         var _loc3_:Boolean = Boolean(this.attach) && this.attach.visible && Boolean(this.attach.stage);
         var _loc4_:Boolean = Boolean(this.attach_dow) && (this.attach_dow.visible || this.attach_dow.name && this.attach_dow.name.indexOf("click_") == 0);
         var _loc5_:* = this.attach_pt != null;
         if(!_loc3_ && !_loc4_ && !_loc5_)
         {
            this.attach = null;
            this.attach_dow = null;
            this.attach_pt = null;
            visible = false;
            return false;
         }
         if(this.layer.pm)
         {
            _loc16_ = this.layer.pm.currentPage as ScenePage;
         }
         if(!this.presentedTooltip)
         {
            this.presentTooltip();
         }
         visible = true;
         if(this.attach_dow)
         {
            _loc6_ = this.attach_dow.getStageBounds();
            _loc6_ = this.rectToLayer(_loc6_);
         }
         else if(this.attach is GuiSprite)
         {
            _loc6_ = new Rectangle(0,0,this.attach.width,this.attach.height);
            _loc6_ = this.rectToGlobal(this.attach,_loc6_);
            _loc6_ = this.rectToLayer(_loc6_);
         }
         else if(this.attach is DisplayObject)
         {
            _loc6_ = this.attach.getBounds(this.attach);
            _loc6_ = this.rectToGlobal(this.attach,_loc6_);
            _loc6_ = this.rectToLayer(_loc6_);
         }
         else if(this.attach_pt)
         {
            _loc6_ = new Rectangle(this.attach_pt.x,this.attach_pt.y,1,1);
            _loc6_ = this.rectToLayer(_loc6_);
         }
         var _loc7_:int = 60;
         var _loc8_:int = 60;
         var _loc9_:Number = !!this.arrow ? _loc7_ : 0;
         if(!_loc9_)
         {
            _loc9_ = !!this.eyeball ? _loc8_ : 0;
         }
         var _loc10_:Number = !!this.button ? this.button.movieClip.height / 2 : 0;
         var _loc11_:Number = 0;
         var _loc12_:Number = 0;
         switch(this.tt_align)
         {
            case TutorialTooltipAlign.LEFT:
               _loc11_ = -_loc9_;
               break;
            case TutorialTooltipAlign.RIGHT:
               _loc11_ = _loc9_;
               break;
            case TutorialTooltipAlign.TOP:
               _loc12_ = -_loc9_;
               break;
            case TutorialTooltipAlign.BOTTOM:
               _loc12_ = _loc9_;
         }
         var _loc13_:Number = this.block.width;
         var _loc14_:Number = this.block.height;
         this.x = 0;
         this.y = 0;
         this.updateWidgetPosition(this.attach_dow,this.attach,_loc6_,this.block,_loc13_,_loc14_,_loc11_,_loc12_,this.getScreenMargin());
         if(this.directionalIndicator)
         {
            _loc17_ = this.directionalIndicator.width;
            _loc18_ = this.directionalIndicator.height;
            this.updateWidgetPosition(this.attach_dow,this.attach,_loc6_,this.directionalIndicator,_loc17_,_loc18_,_loc17_ / 2,_loc18_ / 2,0);
            if(this.arrow)
            {
               switch(this.tt_align)
               {
                  case TutorialTooltipAlign.LEFT:
                     this.arrow.rotation = -90;
                     break;
                  case TutorialTooltipAlign.RIGHT:
                     this.arrow.rotation = 90;
                     break;
                  case TutorialTooltipAlign.TOP:
                     this.arrow.rotation = 0;
                     break;
                  case TutorialTooltipAlign.BOTTOM:
                     this.arrow.rotation = 180;
                     break;
                  case TutorialTooltipAlign.CENTER:
                  case TutorialTooltipAlign.NONE:
               }
            }
         }
         this.x = this.block.x + this.block.width / 2;
         this.y = this.block.y + this.block.height / 2;
         this.block.x -= this.x;
         this.block.y -= this.y;
         if(this.directionalIndicator)
         {
            this.directionalIndicator.x -= this.x;
            this.directionalIndicator.y -= this.y;
         }
         return true;
      }
      
      private function presentTooltip() : void
      {
         if(this.presentedTooltip)
         {
            return;
         }
         this.presentedTooltip = true;
         var _loc1_:Number = this.scaleX;
         this.scaleX = this.scaleY = 0;
         TweenMax.to(this,0.2,{
            "delay":0.1,
            "scaleX":_loc1_,
            "scaleY":_loc1_,
            "ease":Quad.easeIn
         });
      }
      
      private function updateWidgetPosition(param1:DisplayObjectWrapper, param2:DisplayObject, param3:Rectangle, param4:DisplayObject, param5:Number, param6:Number, param7:Number, param8:Number, param9:Number) : void
      {
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         if(!param4)
         {
            return;
         }
         var _loc10_:Number = param4.x;
         var _loc11_:Number = param4.y;
         switch(this.tt_anchor)
         {
            case TutorialTooltipAnchor.LEFT:
               _loc10_ = param3.x;
               _loc11_ = param3.y + param3.height / 2;
               break;
            case TutorialTooltipAnchor.RIGHT:
               _loc10_ = param3.right;
               _loc11_ = param3.y + param3.height / 2;
               break;
            case TutorialTooltipAnchor.TOP:
               _loc10_ = param3.x + param3.width / 2;
               _loc11_ = param3.y;
               break;
            case TutorialTooltipAnchor.BOTTOM:
               _loc10_ = param3.x + param3.width / 2;
               _loc11_ = param3.bottom;
               break;
            case TutorialTooltipAnchor.CENTER:
            case TutorialTooltipAnchor.NONE:
               _loc10_ = param3.x + param3.width / 2;
               _loc11_ = param3.y + param3.height / 2;
         }
         switch(this.tt_align)
         {
            case TutorialTooltipAlign.LEFT:
               _loc10_ += -param5 + this.tt_anchor_offset;
               _loc11_ -= param6 / 2;
               break;
            case TutorialTooltipAlign.RIGHT:
               _loc10_ += this.tt_anchor_offset;
               _loc11_ -= param6 / 2;
               break;
            case TutorialTooltipAlign.TOP:
               _loc10_ -= param5 / 2;
               _loc11_ += -param6 + this.tt_anchor_offset;
               break;
            case TutorialTooltipAlign.BOTTOM:
               _loc10_ -= param5 / 2;
               _loc11_ += this.tt_anchor_offset;
               break;
            case TutorialTooltipAlign.CENTER:
               _loc10_ -= param5 / 2;
               _loc11_ -= param6 / 2;
               break;
            case TutorialTooltipAlign.NONE:
         }
         _loc10_ += param7;
         _loc11_ += param8;
         if(!this._neverClamp)
         {
            _loc12_ = this.layer.width - param9 - param5;
            _loc13_ = this.layer.height - param9 - param6;
            _loc10_ = Math.max(param9,_loc10_);
            _loc10_ = Math.min(_loc12_,_loc10_);
            _loc11_ = Math.max(param9,_loc11_);
            _loc11_ = Math.min(_loc13_,_loc11_);
         }
         if(Math.abs(param4.x - _loc10_) > this.ADJUST_THRESHOLD)
         {
            param4.x = _loc10_;
         }
         if(Math.abs(param4.y - _loc11_) > this.ADJUST_THRESHOLD)
         {
            param4.y = _loc11_;
         }
      }
      
      public function buttonHandler(param1:IGuiButton) : void
      {
         this.layer.removeTooltip(this);
         dispatchEvent(new Event(EVENT_BUTTON));
         this.notifyClosed();
      }
      
      public function notifyClosed() : void
      {
         var _loc1_:Function = null;
         if(this.buttonCallback != null)
         {
            _loc1_ = this.buttonCallback;
            this.buttonCallback = null;
            _loc1_(this.id);
         }
      }
      
      private function cmdfunc_ok(param1:CmdExec) : void
      {
         if(Boolean(this.button) && Boolean(this.button.visible))
         {
            this.button.press();
         }
      }
   }
}
