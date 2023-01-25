package game.gui
{
   import engine.ability.IAbilityDefLevel;
   import engine.anim.view.AnimControllerSpriteFlash;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.entity.def.IEntityDef;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import engine.gui.GuiUtil;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import game.gui.page.GuiCharacterAbilityAnimator;
   import game.gui.page.IGuiPgAbilityPopup;
   
   public class GuiPgAbilityPopup extends GuiBase implements IGuiPgAbilityPopup
   {
       
      
      public var _buttonClose:ButtonWithIndex;
      
      public var _placeholder_clip:MovieClip;
      
      public var _button_ability:ButtonWithIndex;
      
      public var _buttons:Vector.<ButtonWithIndex>;
      
      public var _textAblNamePassive:TextField;
      
      public var _textAblNameActive:TextField;
      
      public var _textAblDesc:TextField;
      
      public var _textAblRanks:TextField;
      
      public var _textAblRank:TextField;
      
      private var _$pg_abl_label_passive:TextField;
      
      private var _$pg_abl_label_active:TextField;
      
      public var textAblRanksBottom:Number = 0;
      
      public var entity:IEntityDef;
      
      public var actives:Vector.<BattleAbilityDef>;
      
      public var passives:Vector.<BattleAbilityDef>;
      
      public var btnToAbl:Dictionary;
      
      public var _ability:BattleAbilityDef;
      
      private var _textAblDescSize:Point;
      
      private var _textAblRanksY:int = 0;
      
      private var gp_b:GuiGpBitmap;
      
      private var gp_b2:GuiGpBitmap;
      
      private var cmd_close:Cmd;
      
      private var _sprite:AnimControllerSpriteFlash;
      
      private var nav:GuiGpNav;
      
      private var gplayer:int;
      
      public var animator:GuiCharacterAbilityAnimator;
      
      public function GuiPgAbilityPopup()
      {
         var _loc2_:ButtonWithIndex = null;
         this._buttons = new Vector.<ButtonWithIndex>();
         this.actives = new Vector.<BattleAbilityDef>();
         this.passives = new Vector.<BattleAbilityDef>();
         this.btnToAbl = new Dictionary();
         this._textAblDescSize = new Point();
         this.gp_b = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         this.gp_b2 = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         this.cmd_close = new Cmd("pg_bio_close",this.cmdfunc_close);
         super();
         this._buttonClose = requireGuiChild("button$close") as ButtonWithIndex;
         this._placeholder_clip = requireGuiChild("placeholder_clip") as MovieClip;
         this._button_ability = requireGuiChild("button_ability") as ButtonWithIndex;
         var _loc1_:int = 0;
         while(_loc1_ < 4)
         {
            _loc2_ = requireGuiChild("button_abl" + _loc1_) as ButtonWithIndex;
            this._buttons.push(_loc2_);
            _loc1_++;
         }
         this._textAblNamePassive = requireGuiChild("textAblNamePassive") as TextField;
         this._textAblNameActive = requireGuiChild("textAblNameActive") as TextField;
         this._textAblDesc = requireGuiChild("textAblDesc") as TextField;
         this._textAblRanks = requireGuiChild("textAblRanks") as TextField;
         this._textAblRank = requireGuiChild("textAblRank") as TextField;
         this._$pg_abl_label_passive = requireGuiChild("$pg_abl_label_passive") as TextField;
         this._$pg_abl_label_active = requireGuiChild("$pg_abl_label_active") as TextField;
         this._textAblRanksY = this._textAblRanks.y;
         this.textAblRanksBottom = this._textAblRanks.y + this._textAblRanks.height;
         this._textAblDescSize.x = this._textAblDesc.width;
         this._textAblDescSize.y = this._textAblDesc.height;
         name = "gui_pg_ability_popup";
      }
      
      public function get mc() : MovieClip
      {
         return this;
      }
      
      public function init(param1:IGuiContext) : void
      {
         var _loc2_:ButtonWithIndex = null;
         super.initGuiBase(param1);
         visible = false;
         this.animator = new GuiCharacterAbilityAnimator(_context.resourceManager);
         this._buttonClose.guiButtonContext = param1;
         this._buttonClose.setDownFunction(this.buttonCloseDownFunction);
         this._button_ability.setDownFunction(this.buttonCloseDownFunction);
         this._button_ability.guiButtonContext = param1;
         for each(_loc2_ in this._buttons)
         {
            _loc2_.guiButtonContext = param1;
            _loc2_.setDownFunction(this.buttonAblDownFunction);
         }
         this._placeholder_clip.visible = false;
         stop();
         param1.addEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
         this.localeChangedHandler(null);
         addChild(this.gp_b);
         addChild(this.gp_b2);
         this.gp_b.scale = 1.5;
         this.gp_b2.scale = 1.5;
         GuiGp.placeIcon(this._button_ability,null,this.gp_b,GuiGpAlignH.C,GuiGpAlignV.N_DOWN);
         GuiGp.placeIcon(this._buttonClose,null,this.gp_b2,GuiGpAlignH.E,GuiGpAlignV.C);
      }
      
      public function cleanup() : void
      {
         var _loc1_:ButtonWithIndex = null;
         if(this.animator)
         {
            this.animator.cleanup();
            this.animator = null;
         }
         GpBinder.gpbinder.unbind(this.cmd_close);
         this.cmd_close.cleanup();
         GuiGp.releasePrimaryBitmap(this.gp_b);
         GuiGp.releasePrimaryBitmap(this.gp_b2);
         this._buttonClose.cleanup();
         this._button_ability.cleanup();
         for each(_loc1_ in this._buttons)
         {
            _loc1_.cleanup();
         }
         this._buttons = null;
         this.actives = null;
         this.passives = null;
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         this.btnToAbl = null;
         if(context)
         {
            context.removeEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
         }
         super.cleanupGuiBase();
      }
      
      private function localeChangedHandler(param1:Event) : void
      {
         this.resetAbilityText();
      }
      
      private function buttonAblDownFunction(param1:ButtonWithIndex) : void
      {
         var _loc2_:BattleAbilityDef = this.btnToAbl[param1];
         if(_loc2_)
         {
            this.ability = _loc2_;
         }
      }
      
      private function buttonCloseDownFunction(param1:ButtonWithIndex) : void
      {
         this.deactivateAbilityPopup();
      }
      
      private function updateAbilityPopupButtons() : void
      {
         var _loc1_:ButtonWithIndex = null;
         var _loc2_:int = 0;
         var _loc3_:BattleAbilityDef = null;
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         if(!this.entity)
         {
            return;
         }
         this.btnToAbl = new Dictionary();
         this.actives.splice(0,this.actives.length);
         this.passives.splice(0,this.passives.length);
         this.nav = new GuiGpNav(context,"pgabl",this);
         this.nav.alwaysHintControls = true;
         this.nav.scale = 1.5;
         this.nav.setAlignNavDefault(GuiGpAlignH.C,GuiGpAlignV.S);
         this.nav.pressOnNavigate = true;
         if(this.entity.actives)
         {
            _loc2_ = 0;
            while(_loc2_ < this.entity.actives.numAbilities)
            {
               _loc3_ = this.entity.actives.getAbilityDef(_loc2_) as BattleAbilityDef;
               if(_loc3_.tag == BattleAbilityTag.SPECIAL)
               {
                  if(!_loc3_.pgHide)
                  {
                     this.actives.push(_loc3_);
                     _loc1_ = this.getButton(this.actives.length - 1);
                     this.setupButton(_loc1_,_loc3_);
                     this.nav.add(_loc1_);
                     this.nav.setShowControl(_loc1_,false);
                  }
               }
               _loc2_++;
            }
         }
         if(this.entity.passives)
         {
            _loc2_ = 0;
            while(_loc2_ < this.entity.passives.numAbilities)
            {
               _loc3_ = this.entity.passives.getAbilityDef(_loc2_) as BattleAbilityDef;
               if(_loc3_.tag == BattleAbilityTag.PASSIVE)
               {
                  this.passives.push(_loc3_);
                  _loc1_ = this.getButton(this.passives.length - 1 + this.actives.length);
                  this.setupButton(_loc1_,_loc3_);
                  this.nav.add(_loc1_);
                  this.nav.setShowControl(_loc1_,false);
               }
               _loc2_++;
            }
         }
         var _loc4_:int = int(this.passives.length + this.actives.length);
         _loc2_ = _loc4_;
         while(_loc2_ < this._buttons.length)
         {
            _loc1_ = this.getButton(_loc2_);
            _loc1_.visible = false;
            _loc2_++;
         }
         var _loc5_:int = 180;
         var _loc6_:int = (_loc4_ - 1) * _loc5_;
         var _loc7_:int = this._textAblNameActive.x + this._textAblNameActive.width / 2;
         var _loc8_:int = _loc6_ / 2;
         _loc2_ = 0;
         while(_loc2_ < _loc4_)
         {
            _loc1_ = this.getButton(_loc2_);
            _loc1_.x = _loc7_ - _loc8_ + _loc5_ * _loc2_;
            _loc2_++;
         }
         this.nav.add(this._buttonClose,false,true,true);
         this.nav.autoSelect();
         this.nav.activate();
         if(this.actives.length > 0)
         {
            this.ability = this.actives[0];
            this.nav.selected = this.getButton(0);
         }
         else if(this.passives.length > 0)
         {
            this.ability = this.passives[0];
            this.nav.selected = this.getButton(0);
         }
         else
         {
            this.ability = null;
            this.nav.selected = null;
         }
      }
      
      private function setupButton(param1:ButtonWithIndex, param2:BattleAbilityDef) : void
      {
         var _loc3_:MovieClip = param1.getChildByName("placeholder") as MovieClip;
         var _loc4_:GuiIcon = param1.getChildByName("icon") as GuiIcon;
         if(_loc4_)
         {
            param1.removeChild(_loc4_);
            _loc4_.release();
            _loc4_ = null;
         }
         this.btnToAbl[param1] = param2;
         if(param2.iconLargeUrl)
         {
            _loc4_ = context.getIcon(param2.iconLargeUrl);
            _loc4_.name = "icon";
            param1.addChildAt(_loc4_,0);
            _loc4_.x = _loc3_.x;
            _loc4_.y = _loc3_.y;
         }
         else
         {
            context.logger.error("GuiPgAbilityPopup.setupButton ability [" + param2.id + "] has no iconLargeUrl");
         }
         _loc3_.visible = false;
         param1.visible = true;
      }
      
      private function getButton(param1:int) : ButtonWithIndex
      {
         return this._buttons[param1];
      }
      
      public function deactivateAbilityPopup() : void
      {
         visible = false;
         GpBinder.gpbinder.removeLayer(this.gplayer);
         GpBinder.gpbinder.unbind(this.cmd_close);
         GpBinder.gpbinder.unbind(this.cmd_close);
         this.gplayer = 0;
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         this.animator.entityDef = null;
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      public function activateAbilityPopup(param1:IEntityDef) : void
      {
         this.entity = param1;
         visible = true;
         this.gplayer = GpBinder.gpbinder.createLayer("GuiPgAbilityPopup");
         GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_close);
         GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_close);
         this.gp_b.gplayer = this.gplayer;
         this.gp_b2.gplayer = this.gplayer;
         this.animator.entityDef = this.entity;
         this.updateAbilityPopupButtons();
         dispatchEvent(new Event(Event.OPEN));
      }
      
      public function hitTestAbilityPopup(param1:Number, param2:Number) : Boolean
      {
         if(!visible)
         {
            return false;
         }
         return hitTestPoint(param1,param2);
      }
      
      public function get ability() : BattleAbilityDef
      {
         return this._ability;
      }
      
      public function set ability(param1:BattleAbilityDef) : void
      {
         var _loc2_:ButtonWithIndex = null;
         var _loc3_:BattleAbilityDef = null;
         this._ability = param1;
         this.setupAnimClip();
         for each(_loc2_ in this._buttons)
         {
            _loc3_ = this.btnToAbl[_loc2_];
            _loc2_.setHovering(_loc3_ == this._ability);
         }
         if(!this._ability)
         {
            return;
         }
         this.resetAbilityText();
      }
      
      private function resetAbilityText() : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:IAbilityDefLevel = null;
         var _loc5_:int = 0;
         if(!context || !this._ability)
         {
            return;
         }
         this._textAblDesc.scaleX = this._textAblDesc.scaleY = 1;
         this._textAblDesc.width = this._textAblDescSize.x;
         this._textAblDesc.height = this._textAblDescSize.y;
         this._textAblRanks.y = this._textAblRanksY;
         var _loc1_:String = String(context.translateCategory(this._ability.id + "_pg_desc",LocaleCategory.ABILITY));
         _loc1_ = this._ability.makeSubstitutions(_loc1_,logger);
         this._textAblDesc.htmlText = _loc1_;
         if(this._ability.tag == BattleAbilityTag.PASSIVE)
         {
            this._textAblNamePassive.htmlText = !!this._ability.name ? this._ability.name : "";
            this._textAblNamePassive.visible = true;
            this._$pg_abl_label_passive.visible = true;
            this._$pg_abl_label_active.visible = false;
            this._textAblRanks.visible = false;
            this._textAblNameActive.visible = false;
            this._textAblRank.visible = false;
         }
         else
         {
            this._textAblNameActive.htmlText = !!this._ability.name ? this._ability.name : "";
            _loc2_ = String(context.translateCategory(this._ability.id + "_pg_ranks",LocaleCategory.ABILITY));
            _loc2_ = this._ability.makeSubstitutions(_loc2_,logger);
            this._textAblRanks.htmlText = _loc2_;
            this._textAblRanks.height = this._textAblRanks.textHeight + 5;
            this._textAblRanks.y = this.textAblRanksBottom - this._textAblRanks.height;
            this._textAblNamePassive.visible = false;
            this._$pg_abl_label_passive.visible = false;
            this._$pg_abl_label_active.visible = true;
            this._textAblRanks.visible = true;
            this._textAblNameActive.visible = true;
            _loc3_ = String(context.translate("pg_abl_rank"));
            _loc4_ = !!this.entity.actives ? this.entity.actives.getAbilityDefLevelById(this._ability.id) : null;
            _loc5_ = !!_loc4_ ? int(Math.min(_loc4_.level,this._ability.maxLevel)) : 0;
            _loc3_ = _loc3_.replace("$RANK",_loc5_);
            this._textAblRank.text = _loc3_;
            this._textAblRank.visible = true;
         }
         _context.currentLocale.fixTextFieldFormat(this._textAblRank);
         _context.currentLocale.fixTextFieldFormat(this._textAblNamePassive);
         _context.currentLocale.fixTextFieldFormat(this._textAblNameActive);
         _context.currentLocale.fixTextFieldFormat(this._textAblDesc);
         _context.currentLocale.fixTextFieldFormat(this._textAblRanks,null,null,true);
         if(this._textAblRanks.visible)
         {
            this._textAblRanks.height = this._textAblRanks.textHeight + 5;
            this._textAblRanks.y = this.textAblRanksBottom - this._textAblRanks.height;
         }
         GuiUtil.scaleTextToFit2d(this._textAblDesc,this._textAblDescSize.x,this._textAblRanks.y - this._textAblDesc.y - 8);
      }
      
      public function update(param1:int) : void
      {
         if(this.animator)
         {
            this.animator.update(param1);
         }
      }
      
      private function setupAnimClip() : void
      {
         this.animator.createAnimControllerSprite(this.animatorCallbackHandler);
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
                  this.animator.animId = "mix_idle";
               }
            }
            else
            {
               this.animator.animId = null;
            }
         }
      }
      
      private function cmdfunc_close(param1:CmdExec) : void
      {
         this.deactivateAbilityPopup();
      }
   }
}
