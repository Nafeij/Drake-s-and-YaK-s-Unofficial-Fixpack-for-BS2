package game.gui
{
   import engine.anim.view.AnimControllerSpriteFlash;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.entity.def.IEntityDef;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpNav;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.page.GuiCharacterAbilityAnimator;
   
   public class GuiPromotionAbility extends GuiBase
   {
       
      
      private var _iconAblHolder:MovieClip;
      
      private var _textAblName:TextField;
      
      private var _textAblDesc:TextField;
      
      private var _placeholder_clip:MovieClip;
      
      private var _ability:BattleAbilityDef;
      
      private var _button$choose_ability:ButtonWithIndex;
      
      private var _button$cancel:ButtonWithIndex;
      
      private var _icon:GuiIcon;
      
      public var animator:GuiCharacterAbilityAnimator;
      
      private var _sprite:AnimControllerSpriteFlash;
      
      private var _abilities:Vector.<BattleAbilityDef>;
      
      private var _entity:IEntityDef;
      
      private var _callback:Function;
      
      private var cmd_b:Cmd;
      
      private var nav:GuiGpNav;
      
      public function GuiPromotionAbility()
      {
         this._abilities = new Vector.<BattleAbilityDef>();
         this.cmd_b = new Cmd("pg_p_abl_b",this.cmdfunc_b);
         super();
      }
      
      public function cleanup() : void
      {
         this.cmd_b.cleanup();
         this.cmd_b = null;
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         this.visible = false;
         if(this.animator)
         {
            this.animator.cleanup();
            this.animator = null;
         }
         super.cleanupGuiBase();
      }
      
      public function init(param1:IGuiContext, param2:Function) : void
      {
         var _loc4_:DisplayObject = null;
         super.initGuiBase(param1);
         this._iconAblHolder = requireGuiChild("iconAbl") as MovieClip;
         var _loc3_:int = 0;
         while(_loc3_ < this._iconAblHolder.numChildren)
         {
            _loc4_ = this._iconAblHolder.getChildAt(_loc3_);
            _loc4_.visible = false;
            _loc3_++;
         }
         this._textAblName = requireGuiChild("textAblName") as TextField;
         this._textAblDesc = requireGuiChild("textAblDesc") as TextField;
         this._placeholder_clip = requireGuiChild("placeholder_clip") as MovieClip;
         this._placeholder_clip.visible = false;
         this._button$choose_ability = requireGuiChild("button$choose_ability") as ButtonWithIndex;
         this._button$cancel = requireGuiChild("button$cancel") as ButtonWithIndex;
         this._button$choose_ability.guiButtonContext = param1;
         this._button$cancel.guiButtonContext = param1;
         this._button$choose_ability.setDownFunction(this.buttonChooseHandler);
         this._button$cancel.setDownFunction(this.buttonCancelHandler);
         this.animator = new GuiCharacterAbilityAnimator(_context.resourceManager);
         this._callback = param2;
         this.nav = new GuiGpNav(param1,"pgpromotionability",this);
         this.nav.setCallbackPress(this.navControlPressHandler);
         this.nav.scale = 1.5;
         this.nav.setAlignNavDefault(GuiGpAlignH.C,GuiGpAlignV.S);
         this.nav.setAlignControlDefault(GuiGpAlignH.C,GuiGpAlignV.N);
         this.nav.add(this._button$choose_ability);
         this.nav.add(this._button$cancel);
      }
      
      private function navControlPressHandler(param1:DisplayObject, param2:Boolean) : Boolean
      {
         if(param1 == this._button$choose_ability)
         {
            this._button$choose_ability.press();
         }
         else if(param1 == this._button$cancel)
         {
            this._button$cancel.press();
         }
         return true;
      }
      
      private function buttonChooseHandler(param1:*) : void
      {
         if(this._callback != null)
         {
            this._callback(this._ability);
         }
      }
      
      private function buttonCancelHandler(param1:*) : void
      {
         if(this._callback != null)
         {
            this._callback(null);
         }
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(visible)
         {
            GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_b);
            if(this.nav)
            {
               this.nav.activate();
               this.nav.setSelectIndex(0);
            }
         }
         else
         {
            this.setupAbilities(null,null);
            GpBinder.gpbinder.unbind(this.cmd_b);
            if(this.nav)
            {
               this.nav.deactivate();
            }
         }
      }
      
      public function setupAbilities(param1:IEntityDef, param2:Vector.<BattleAbilityDef>) : void
      {
         this._entity = param1;
         if(param2)
         {
            this._abilities = param2.concat();
         }
         else
         {
            this._abilities = new Vector.<BattleAbilityDef>();
         }
         if(this.animator)
         {
            this.animator.entityDef = param1;
         }
         if(this._abilities.length)
         {
            this.ability = this._abilities[0];
         }
         else
         {
            this.ability = null;
         }
      }
      
      public function nextAbility() : int
      {
         var _loc1_:int = this._abilities.indexOf(this._ability);
         if(_loc1_ >= 0)
         {
            _loc1_ = (_loc1_ + 1) % this._abilities.length;
            this.ability = this._abilities[_loc1_];
            return _loc1_;
         }
         return -1;
      }
      
      public function prevAbility() : int
      {
         var _loc1_:int = this._abilities.indexOf(this._ability);
         if(_loc1_ >= 0)
         {
            _loc1_ = (_loc1_ + this._abilities.length - 1) % this._abilities.length;
            this.ability = this._abilities[_loc1_];
            return _loc1_;
         }
         return -1;
      }
      
      public function get ability() : BattleAbilityDef
      {
         return this._ability;
      }
      
      public function set ability(param1:BattleAbilityDef) : void
      {
         var _loc2_:String = null;
         if(this._ability == param1)
         {
            return;
         }
         this._ability = param1;
         if(this._ability)
         {
            this._textAblName.text = this._ability.name;
            _loc2_ = context.translateCategory(this._ability.id + "_pg_desc",LocaleCategory.ABILITY);
            _loc2_ = this._ability.makeSubstitutions(_loc2_,logger);
            this._textAblDesc.htmlText = _loc2_;
            this.icon = _context.getLargeAbilityIcon(this._ability);
            _context.locale.fixTextFieldFormat(this._textAblName);
            _context.locale.fixTextFieldFormat(this._textAblDesc);
         }
         else
         {
            this.icon = null;
         }
         this.setupAnimClip();
      }
      
      public function get icon() : GuiIcon
      {
         return this._icon;
      }
      
      public function set icon(param1:GuiIcon) : void
      {
         if(this._icon == param1)
         {
            return;
         }
         if(this._icon)
         {
            if(this._icon.parent)
            {
               this._icon.parent.removeChild(this._icon);
            }
         }
         this._icon = param1;
         if(this._icon)
         {
            this._iconAblHolder.addChild(this._icon);
         }
      }
      
      public function update(param1:int) : void
      {
         if(!super.visible)
         {
            return;
         }
         if(this.animator)
         {
            this.animator.update(param1);
         }
      }
      
      private function setupAnimClip() : void
      {
         if(!this.animator)
         {
            return;
         }
         if(!this._ability)
         {
            this.animator.entityDef = null;
         }
         else
         {
            this.animator.createAnimControllerSprite(this.animatorCallbackHandler);
         }
      }
      
      private function animatorCallbackHandler(param1:AnimControllerSpriteFlash) : void
      {
         var _loc2_:int = 0;
         if(this._sprite)
         {
            this._sprite.displayObjectWrapper.removeFromParent();
         }
         this._sprite = param1;
         if(this._sprite)
         {
            this._sprite.displayObjectWrapper.x = this._placeholder_clip.x;
            this._sprite.displayObjectWrapper.y = this._placeholder_clip.y;
            this._sprite.displayObjectWrapper.scale = this._placeholder_clip.scaleX;
            _loc2_ = getChildIndex(this._placeholder_clip);
            addChildAt(this._sprite._sprite,_loc2_);
            if(this._ability)
            {
               if(this._ability.abilityPopupAnimId)
               {
                  this.animator.animId = this._ability.abilityPopupAnimId;
               }
               else if(Boolean(this._ability.id) && this._ability.id.indexOf("pas_") != 0)
               {
                  this.animator.animId = "ability1";
               }
               else
               {
                  this.animator.animId = null;
               }
            }
            else
            {
               this.animator.animId = null;
            }
         }
      }
      
      private function cmdfunc_b(param1:CmdExec) : void
      {
         this._button$cancel.press();
      }
   }
}
