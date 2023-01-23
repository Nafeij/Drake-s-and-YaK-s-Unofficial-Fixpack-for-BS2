package game.gui.battle
{
   import com.greensock.TweenMax;
   import engine.core.util.MovieClipAdapter;
   import engine.gui.IGuiGpNavButton;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiEnemyPopupButton extends GuiBase implements IGuiGpNavButton
   {
       
      
      private var _button:ButtonWithIndex;
      
      private var _damageText:TextField;
      
      private var _damageFlag:MovieClip;
      
      private var _damageFlagMca:MovieClipAdapter;
      
      private var _missFlagMca:MovieClipAdapter;
      
      private var _missFlag:MovieClip;
      
      public var _missText:TextField;
      
      private var _darken:MovieClip;
      
      private var _check:MovieClip;
      
      private var _checkMca:MovieClipAdapter;
      
      private var _glow_fire:MovieClip;
      
      private const normalTextColor:uint = 16767921;
      
      private const negativeTextColor:uint = 16727040;
      
      private const positiveTextColor:uint = 65280;
      
      private var _popup:GuiEnemyPopup;
      
      public function GuiEnemyPopupButton()
      {
         super();
      }
      
      public function init(param1:IGuiContext, param2:GuiEnemyPopup) : void
      {
         var _loc4_:MovieClip = null;
         super.initGuiBase(param1);
         this._popup = param2;
         this._darken = requireGuiChild("darken") as MovieClip;
         this._darken.visible = false;
         this._darken.mouseEnabled = this._darken.mouseChildren = false;
         this._button = requireGuiChild("button") as ButtonWithIndex;
         this._button.guiButtonContext = _context;
         this._button.setDownFunction(this.buttonDownHandler);
         this._glow_fire = requireGuiChild("glow_fire") as MovieClip;
         this._glow_fire.mouseEnabled = this._glow_fire.mouseChildren = false;
         this._glow_fire.visible = false;
         this._glow_fire.stop();
         this._check = requireGuiChild("check") as MovieClip;
         this._check.visible = false;
         this._check.mouseEnabled = this._check.mouseChildren = false;
         this._check.stop();
         this._checkMca = new MovieClipAdapter(this._check,GuiEnemyPopup.MC_FPS,0,false,_context.logger);
         this._damageFlag = requireGuiChild("damage_flag") as MovieClip;
         this._damageFlag.stop();
         var _loc3_:MovieClip = this._damageFlag.getChildByName("damage_flag") as MovieClip;
         this._damageText = _loc3_.getChildByName("damage_text") as TextField;
         this._missFlag = getChildByName("miss_flag") as MovieClip;
         if(this._missFlag)
         {
            this._missFlag.stop();
            this._missFlagMca = new MovieClipAdapter(this._missFlag,GuiEnemyPopup.MC_FPS,0,false,_context.logger);
            _loc4_ = this._missFlag.getChildByName("miss_flag") as MovieClip;
            this._missText = _loc4_.getChildByName("miss_text") as TextField;
         }
         this._damageFlagMca = new MovieClipAdapter(this._damageFlag,GuiEnemyPopup.MC_FPS,0,false,_context.logger);
      }
      
      override public function set visible(param1:Boolean) : void
      {
         var _loc2_:Boolean = false;
         _loc2_ = super.visible;
         super.visible = param1;
         if(param1 != _loc2_)
         {
            if(param1)
            {
               this._damageFlagMca.playOnce();
            }
            else
            {
               this._damageFlagMca.stop();
            }
         }
      }
      
      public function reset() : void
      {
         if(this._missFlagMca)
         {
            this._missFlagMca.stop();
            this._missFlag.gotoAndStop(1);
         }
         this._darken.visible = false;
         TweenMax.killTweensOf(this._darken);
         this.glowFireVisible = false;
         this._check.visible = false;
      }
      
      public function set glowFireVisible(param1:Boolean) : void
      {
         if(param1)
         {
            this._glow_fire.visible = true;
            this._glow_fire.gotoAndPlay(1);
         }
         else
         {
            this._glow_fire.visible = false;
            this._glow_fire.stop();
         }
      }
      
      public function buttonDownHandler(param1:ButtonWithIndex) : void
      {
         if(this.attemptConfirm())
         {
            return;
         }
         if(!this._popup.handleButtonSelected(this))
         {
            return;
         }
         this._check.visible = true;
         this._checkMca.playOnce();
         this._darken.visible = true;
         this._darken.alpha = 0;
         var _loc2_:Number = 0.25;
         var _loc3_:Number = 0.5;
         TweenMax.to(this._darken,_loc2_,{"alpha":_loc3_});
      }
      
      public function attemptConfirm() : Boolean
      {
         if(this._check.visible)
         {
            this._popup.handleButtonConfirmed(this);
            return true;
         }
         return false;
      }
      
      public function setMissChance(param1:int) : void
      {
         var _loc2_:int = 0;
         if(!this._missText)
         {
            return;
         }
         if(param1 > 0)
         {
            _loc2_ = 100 - param1;
            this._missText.text = _loc2_.toString() + "%";
            this._missText.cacheAsBitmap = true;
            if(this._missFlag.currentFrame <= 1)
            {
               this._missFlagMca.playOnce();
            }
         }
      }
      
      public function setDamageText(param1:int, param2:int, param3:int, param4:int = 0) : void
      {
         if(!this._damageText)
         {
            return;
         }
         this._damageText.text = param2.toString();
         if(param1 > param2 || param3 > 0)
         {
            this._damageText.textColor = this.negativeTextColor;
         }
         else if(param1 < param2)
         {
            this._damageText.textColor = this.positiveTextColor;
         }
         else
         {
            this._damageText.textColor = this.normalTextColor;
         }
      }
      
      public function cleanup() : void
      {
         this.reset();
      }
      
      public function press() : void
      {
         this._button.press();
      }
      
      override public function get enabled() : Boolean
      {
         return this._button.enabled;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         this._button.enabled = param1;
      }
      
      public function setHovering(param1:Boolean) : void
      {
         this._button.setHovering(param1);
      }
      
      public function getNavRectangle(param1:DisplayObject) : Rectangle
      {
         return this._button.getNavRectangle(param1);
      }
   }
}
