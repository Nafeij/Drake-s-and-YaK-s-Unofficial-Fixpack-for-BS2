package game.gui.pages
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpSource;
   import engine.entity.def.IEntityDef;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.core.ResizableTextField;
   import engine.saga.Saga;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiGamePrefs;
   import game.gui.IGuiContext;
   import game.gui.page.GuiProvingGroundsConfig;
   
   public class GuiPromoteBanner extends GuiBase
   {
      
      public static const EVENT_PROMOTE:String = "GuiPromoteBanner.EVENT_PROMOTE";
       
      
      public var hide_x:Number = 0;
      
      public var notVisibleX:Number = 0;
      
      public var _promote_banner_bg:MovieClip;
      
      public var _text$promote:ResizableTextField;
      
      public var _cross:ButtonWithIndex;
      
      public var _unitId:String;
      
      public var text_show_x:Number = 0;
      
      public var guiConfig:GuiProvingGroundsConfig;
      
      public var textFiltersNormal:Array;
      
      public var textFiltersHover:Array;
      
      private var _unit:IEntityDef;
      
      private var gp_x:GuiGpBitmap;
      
      private var cmd_promote:Cmd;
      
      private var _bannerVisible:Boolean;
      
      private var _extended:Boolean;
      
      public function GuiPromoteBanner()
      {
         this.gp_x = GuiGp.ctorPrimaryBitmap(GpControlButton.X,true);
         this.cmd_promote = new Cmd("pg_promote",this.cmdfunc_promote);
         super();
         super.visible = false;
         this._promote_banner_bg = getChildByName("promote_banner_bg") as MovieClip;
         this._text$promote = ResizableTextField.ctor(getChildByName("text$promote") as TextField);
         this._cross = getChildByName("cross") as ButtonWithIndex;
      }
      
      public function get unitId() : String
      {
         return this._unitId;
      }
      
      public function set unitId(param1:String) : void
      {
         if(!_context)
         {
            return;
         }
         this._unitId = param1;
         this.update();
      }
      
      public function init(param1:IGuiContext, param2:GuiProvingGroundsConfig) : void
      {
         initGuiBase(param1);
         this.guiConfig = param2;
         this._cross.guiButtonContext = param1;
         this._cross.setDownFunction(this.onPromoteCrossClicked);
         this._text$promote.mouseEnabled = false;
         this._promote_banner_bg.mouseEnabled = true;
         this._promote_banner_bg.addEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
         this._promote_banner_bg.addEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
         this._promote_banner_bg.addEventListener(MouseEvent.CLICK,this.clickHandler);
         this.textFiltersNormal = this._text$promote.filters;
         var _loc3_:GlowFilter = this.textFiltersNormal.length > 0 ? this.textFiltersNormal[0] : null;
         if(_loc3_)
         {
            this.textFiltersHover = [new GlowFilter(16743936,_loc3_.alpha,_loc3_.blurX,_loc3_.blurY,_loc3_.strength)];
         }
         if(!PlatformInput.hasClicker)
         {
            this._cross.visible = false;
         }
         this.text_show_x = this._text$promote.x;
         this.hide_x = x;
         this.notVisibleX = this.hide_x * 2;
         this.gp_x.gplayer = GpBinder.gpbinder.lastCmdId;
         addChild(this.gp_x);
         this.gp_x.scale = 1.5;
         param1.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.localeHandler(null);
         this.update();
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         this.gp_x.x = this._cross.x - this._cross.width - this.gp_x.width;
         var _loc2_:int = !!this._text$promote ? int(this._text$promote.height) : 0;
         this.gp_x.y = this._text$promote.y + _loc2_ - this.gp_x.height;
         if(this._text$promote)
         {
            this._text$promote.scaleToFit(_context.locale);
         }
      }
      
      public function cleanup() : void
      {
         context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         GuiGp.releasePrimaryBitmap(this.gp_x);
         GpBinder.gpbinder.unbind(this.cmd_promote);
         this.cmd_promote.cleanup();
         this._promote_banner_bg.removeEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
         this._promote_banner_bg.removeEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
         this._promote_banner_bg.removeEventListener(MouseEvent.CLICK,this.clickHandler);
         this._cross.cleanup();
         this._cross = null;
         while(numChildren)
         {
            removeChildAt(numChildren - 1);
         }
         super.cleanupGuiBase();
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         this.doPress(param1 != null);
      }
      
      public function doPress(param1:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:IEntityDef = context.legend.roster.getEntityDefById(this.unitId);
         if(!_loc2_)
         {
            context.logger.info("GuiPromoteBanner.clickHandler [" + this.unitId + "] NO UNIT");
            return;
         }
         if(!this.extended)
         {
            _loc3_ = int(_loc2_.stats.rank);
            _loc4_ = context.statCosts.getKillsRequiredToPromote(_loc3_);
            if(!_loc2_.readyToPromote(_loc4_))
            {
               context.logger.info("GuiPromoteBanner.clickHandler [" + this.unitId + "] NOT READY extended=" + this.extended + " rnk=" + _loc3_ + " kreq=" + _loc4_);
               return;
            }
         }
         if(param1)
         {
            if(!this.isPromoteBannerClickOk)
            {
               context.logger.info("GuiPromoteBanner.clickHandler [" + this.unitId + "] NOT CLICKABLE");
               return;
            }
         }
         context.logger.info("GuiPromoteBanner.clickHandler [" + this.unitId + "] OK");
         context.playSound("ui_generic");
         context.setPref(GuiGamePrefs.PREF_PG_PROMOTE_DISMISSED_PREFIX_ + this.unitId,false);
         dispatchEvent(new Event(EVENT_PROMOTE));
         this.update();
      }
      
      private function get isPromoteBannerClickOk() : Boolean
      {
         return this._promote_banner_bg.mouseX < this._cross.x - this._cross.width / 2;
      }
      
      private function rollOverHandler(param1:MouseEvent) : void
      {
         addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         this.mouseMoveHandler(null);
      }
      
      private function mouseMoveHandler(param1:MouseEvent) : void
      {
         if(this.isPromoteBannerClickOk)
         {
            this._text$promote.filters = this.textFiltersHover;
         }
      }
      
      private function rollOutHandler(param1:MouseEvent) : void
      {
         removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         this._text$promote.filters = this.textFiltersNormal;
      }
      
      private function onPromoteCrossClicked(param1:ButtonWithIndex) : void
      {
         if(!visible || this.guiConfig.disabled)
         {
            return;
         }
         this.extended = !this.extended;
         context.setPref(GuiGamePrefs.PREF_PG_PROMOTE_DISMISSED_PREFIX_ + this.unitId,!this.extended);
      }
      
      private function bannerDoneAnimating() : void
      {
         if(!this.extended)
         {
            super.visible = this._bannerVisible;
            this.gp_x.visible = false;
            this.rollOutHandler(null);
         }
         mouseEnabled = true;
         mouseChildren = true;
      }
      
      public function get bannerVisible() : Boolean
      {
         return this._bannerVisible;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(this._bannerVisible == param1)
         {
            if(!param1)
            {
               return;
            }
            if(super.visible && this.gp_x.visible)
            {
               return;
            }
         }
         this._bannerVisible = param1;
         if(!param1)
         {
            this.notVisibleBanner();
         }
         else
         {
            super.visible = true;
            this.gp_x.gplayer = GpBinder.gpbinder.lastCmdId;
            this.gp_x.visible = true;
            GpBinder.gpbinder.bindPress(GpControlButton.X,this.cmd_promote);
            this.localeHandler(null);
         }
      }
      
      public function set extended(param1:Boolean) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         this._extended = param1;
         this.rollOutHandler(null);
         mouseEnabled = false;
         mouseChildren = false;
         this._cross.setStateToNormal();
         this.gp_x.gplayer = GpBinder.gpbinder.lastCmdId;
         if(this._extended)
         {
            this.visible = true;
            this.gp_x.visible = true;
            if(this.x == 0)
            {
               this._text$promote.x = this.text_show_x;
               this._cross.rotation = 45;
               this.bannerDoneAnimating();
            }
            else
            {
               _loc2_ = 0.5;
               TweenMax.to(this._text$promote,_loc2_,{"x":this.text_show_x});
               TweenMax.to(this,_loc2_,{
                  "x":0,
                  "onComplete":this.bannerDoneAnimating
               });
               TweenMax.to(this._cross,_loc2_,{"rotation":45});
            }
         }
         else
         {
            _loc3_ = 0.5;
            TweenMax.to(this._text$promote,_loc3_,{"x":-this._text$promote.width});
            TweenMax.to(this,_loc3_,{
               "x":this.hide_x,
               "onComplete":this.bannerDoneAnimating
            });
            TweenMax.to(this._cross,_loc3_,{"rotation":0});
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function notVisibleBanner() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_promote);
         this._extended = false;
         var _loc1_:Number = 0.5;
         TweenMax.to(this._text$promote,_loc1_,{"x":-this._text$promote.width});
         TweenMax.to(this,_loc1_,{
            "x":this.notVisibleX,
            "onComplete":this.bannerDoneAnimating
         });
         TweenMax.to(this._cross,_loc1_,{"rotation":0});
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get extended() : Boolean
      {
         return this._extended;
      }
      
      public function get unit() : IEntityDef
      {
         return this._unit;
      }
      
      public function set unit(param1:IEntityDef) : void
      {
         this._unit = param1;
      }
      
      public function update() : void
      {
         var _loc5_:Boolean = false;
         if(!context || !context.legend)
         {
            return;
         }
         var _loc1_:Saga = Saga.instance;
         var _loc2_:IEntityDef = context.legend.roster.getEntityDefById(this.unitId);
         if(!_loc2_)
         {
            this.visible = false;
            return;
         }
         if(!_loc2_.isSurvivalPromotable)
         {
            this.visible = false;
            return;
         }
         var _loc3_:int = int(_loc2_.stats.rank);
         var _loc4_:int = _context.statCosts.getKillsRequiredToPromote(_loc3_);
         if(_loc2_.readyToPromote(_loc4_))
         {
            this.visible = true;
            _loc5_ = Boolean(context.getPref(GuiGamePrefs.PREF_PG_PROMOTE_DISMISSED_PREFIX_ + this.unitId));
            this.extended = !_loc5_ || Boolean(GpSource.instance.numDevices);
         }
         else
         {
            this.visible = false;
         }
      }
      
      public function cmdfunc_promote(param1:CmdExec) : void
      {
         this.clickHandler(null);
         this.gp_x.pulse();
      }
   }
}
