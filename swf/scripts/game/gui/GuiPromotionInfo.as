package game.gui
{
   import engine.ability.IAbilityDefLevel;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.entity.UnitStatCosts;
   import engine.entity.def.IEntityClassDef;
   import engine.entity.def.IEntityDef;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpNav;
   import engine.talent.Talents;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.page.GuiPromotionConfig;
   
   public class GuiPromotionInfo extends GuiBase
   {
       
      
      private var _entity:IEntityDef;
      
      private var characterClassesArray:Vector.<IEntityClassDef>;
      
      private var guiConfig:GuiPromotionConfig;
      
      public var promotionInfoClassText:TextField;
      
      public var _text$promotion_info_ability:TextField;
      
      public var promotionInfoNameText:TextField;
      
      public var _button$continue:ButtonWithIndex;
      
      public var _button$cancel:ButtonWithIndex;
      
      public var _promoteQuill:MovieClip;
      
      public var _promote_ability:MovieClip;
      
      public var _promote_ability2:MovieClip;
      
      public var _promote_item:MovieClip;
      
      public var _text$promotion_info_item:TextField;
      
      public var _text$promotion_info_rebuild:TextField;
      
      public var _text$promotion_info:TextField;
      
      public var _text$promotion_info_ability_add:TextField;
      
      public var _text$promotion_info_stats_w_talents:TextField;
      
      public var _text$promotion_info_stats:TextField;
      
      public var _promote_heroic_title:MovieClip;
      
      public var _text$promotion_info_heroic_title:TextField;
      
      private var _callbackContinue:Function;
      
      private var _callbackCancel:Function;
      
      private var cmd_b:Cmd;
      
      private var nav:GuiGpNav;
      
      private var gplayer:int;
      
      public function GuiPromotionInfo()
      {
         this.characterClassesArray = new Vector.<IEntityClassDef>();
         this.cmd_b = new Cmd("pg_promotion_b",this.cmdfunc_b);
         super();
         this._button$continue = getChildByName("button$continue") as ButtonWithIndex;
         this._button$cancel = getChildByName("button$cancel") as ButtonWithIndex;
         this._promoteQuill = getChildByName("promoteQuill") as MovieClip;
         this._promote_ability = getChildByName("promote_ability") as MovieClip;
         this._promote_ability2 = getChildByName("promote_ability2") as MovieClip;
         this._promote_item = getChildByName("promote_item") as MovieClip;
         this._text$promotion_info_item = getChildByName("text$promotion_info_item") as TextField;
         this.promotionInfoClassText = this.getChildByName("text$promotion_info_class") as TextField;
         this._text$promotion_info_ability = this.getChildByName("text$promotion_info_ability") as TextField;
         this.promotionInfoNameText = this.getChildByName("text$promotion_info_name") as TextField;
         this._promoteQuill = this.getChildByName("promoteQuill") as MovieClip;
         this._text$promotion_info_rebuild = getChildByName("text$promotion_info_rebuild") as TextField;
         this._text$promotion_info = requireGuiChild("text$promotion_info") as TextField;
         this._text$promotion_info_ability_add = requireGuiChild("text$promotion_info_ability_add") as TextField;
         this._text$promotion_info_stats_w_talents = getChildByName("text$promotion_info_stats_w_talents") as TextField;
         this._text$promotion_info_stats = requireGuiChild("text$promotion_info_stats") as TextField;
         this._promote_heroic_title = getChildByName("promote_heroic_title") as MovieClip;
         this._text$promotion_info_heroic_title = getChildByName("text$promotion_info_heroic_title") as TextField;
         registerScalableTextfieldAlign(this._text$promotion_info_rebuild);
         registerScalableTextfieldAlign(this._text$promotion_info);
         registerScalableTextfieldAlign(this._text$promotion_info_ability_add);
         registerScalableTextfieldAlign(this._text$promotion_info_stats_w_talents);
         registerScalableTextfieldAlign(this._text$promotion_info_stats);
         registerScalableTextfieldAlign(this._text$promotion_info_item);
         registerScalableTextfieldAlign(this._text$promotion_info_ability);
      }
      
      private function get entity() : IEntityDef
      {
         return this._entity;
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         scaleTextfields();
      }
      
      private function set entity(param1:IEntityDef) : void
      {
         var _loc2_:IEntityClassDef = null;
         this._entity = param1;
         if(this.characterClassesArray)
         {
            this.characterClassesArray.splice(0,this.characterClassesArray.length);
            if(this._entity)
            {
               for each(_loc2_ in this._entity.entityClass.playerOnlyChildEntityClasses)
               {
                  if(context.isClassAvailable(_loc2_.id))
                  {
                     this.characterClassesArray.push(_loc2_);
                  }
               }
            }
         }
      }
      
      public function init(param1:IGuiContext, param2:GuiPromotionConfig, param3:Function, param4:Function) : void
      {
         super.initGuiBase(param1);
         this.guiConfig = param2;
         this._callbackContinue = param3;
         this._callbackCancel = param4;
         this._button$continue.guiButtonContext = param1;
         this._button$cancel.guiButtonContext = param1;
         registerScalableTextfield(this._text$promotion_info_item);
         registerScalableTextfield(this.promotionInfoClassText);
         registerScalableTextfield(this._text$promotion_info_ability);
         registerScalableTextfield(this.promotionInfoNameText);
         this.nav = new GuiGpNav(param1,"pgpromotioninfo",this);
         this.nav.setCallbackPress(this.navControlPressHandler);
         this.nav.scale = 1.5;
         this.nav.setAlignNavDefault(GuiGpAlignH.C,GuiGpAlignV.S);
         this.nav.setAlignControlDefault(GuiGpAlignH.C,GuiGpAlignV.N);
         this.nav.add(this._button$continue);
         this.nav.add(this._button$cancel);
      }
      
      private function navControlPressHandler(param1:DisplayObject, param2:Boolean) : Boolean
      {
         if(param1 == this._button$continue)
         {
            this._button$continue.press();
         }
         else if(param1 == this._button$cancel)
         {
            this._button$cancel.press();
         }
         return true;
      }
      
      public function cleanup() : void
      {
         this.visible = false;
         this.cmd_b.cleanup();
         this.cmd_b = null;
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         this._callbackContinue = null;
         this._callbackCancel = null;
         this.guiConfig = null;
         this._callbackContinue = null;
         this._callbackCancel = null;
         this._button$continue.cleanup();
         this._button$cancel.cleanup();
         this.characterClassesArray = null;
         this.entity = null;
         super.cleanupGuiBase();
      }
      
      private function buttonCancelHandler(param1:ButtonWithIndex) : void
      {
         this._callbackCancel();
      }
      
      private function onConfirmClassClicked(param1:ButtonWithIndex) : void
      {
         if(this.guiConfig.disabled && !this.guiConfig.allowConfirm)
         {
            return;
         }
         this._callbackContinue();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(param1)
         {
            this.gplayer = GpBinder.gpbinder.createLayer("GuiPromotionInfo");
            GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_b);
            if(this.nav)
            {
               this.nav.activate();
               this.nav.setSelectIndex(0);
            }
         }
         else
         {
            if(this.gplayer)
            {
               GpBinder.gpbinder.unbind(this.cmd_b);
               GpBinder.gpbinder.removeLayer(this.gplayer);
               this.gplayer = 0;
            }
            if(this.nav)
            {
               this.nav.deactivate();
            }
         }
      }
      
      public function characterInfoMode(param1:IEntityDef) : void
      {
         var _loc3_:UnitStatCosts = null;
         var _loc4_:Vector.<IAbilityDefLevel> = null;
         var _loc5_:int = 0;
         var _loc6_:IAbilityDefLevel = null;
         var _loc7_:BattleAbilityDef = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         this.entity = param1;
         this.visible = param1 != null;
         if(!param1)
         {
            return;
         }
         this._promote_ability2.visible = false;
         var _loc2_:int = int(param1.stats.rank);
         if(_loc2_ > 1)
         {
            _loc3_ = context.statCosts;
            if(this._entity.actives)
            {
               _loc5_ = 0;
               while(_loc5_ < this._entity.actives.numAbilities)
               {
                  _loc6_ = this._entity.actives.getAbilityDefLevel(_loc5_);
                  _loc7_ = _loc6_.def as BattleAbilityDef;
                  if(_loc7_.tag == BattleAbilityTag.SPECIAL)
                  {
                     _loc8_ = _loc6_.level;
                     _loc9_ = _loc3_.getAbilityLevel(_loc2_ + 1,_loc6_.rankAcquired);
                     if(_loc9_ > _loc8_)
                     {
                        if(!_loc4_)
                        {
                           _loc4_ = new Vector.<IAbilityDefLevel>();
                        }
                        _loc4_.push(_loc6_);
                     }
                  }
                  _loc5_++;
               }
            }
            if(Boolean(_loc4_) && Boolean(_loc4_.length))
            {
               this._promote_ability.visible = true;
               this._text$promotion_info_ability.visible = true;
               this.promotionInfoClassText.visible = false;
            }
            else
            {
               this._promote_ability.visible = false;
               this.promotionInfoClassText.visible = false;
               this._text$promotion_info_ability.visible = false;
            }
            this.promotionInfoNameText.visible = false;
            this._promoteQuill.visible = false;
            this._promote_item.visible = true;
            this._text$promotion_info_item.visible = true;
            this._promote_heroic_title.visible = false;
            this._text$promotion_info_heroic_title.visible = false;
         }
         else
         {
            this.promotionInfoClassText.visible = true;
            this._text$promotion_info_ability.visible = false;
            this.promotionInfoNameText.visible = true;
            this._promoteQuill.visible = true;
            this._promote_item.visible = false;
            this._text$promotion_info_item.visible = false;
            this._promote_heroic_title.visible = false;
            this._text$promotion_info_heroic_title.visible = false;
         }
         if(_loc2_ + 1 == _loc3_.RANK_REBUILD)
         {
            this._promote_ability.visible = false;
            this._promote_ability2.visible = true;
            this._text$promotion_info_ability.visible = false;
            this._text$promotion_info_rebuild.visible = true;
            this._text$promotion_info.visible = false;
            this._text$promotion_info_ability_add.visible = true;
         }
         else
         {
            this._text$promotion_info_rebuild.visible = false;
            this._text$promotion_info.visible = true;
            this._text$promotion_info_ability_add.visible = false;
         }
         if(_loc2_ >= GuiHeroicTitles.RANK_HEROIC_TITLE && param1.stats.titleRank == 0)
         {
            this._promote_ability.visible = false;
            this._promote_ability2.visible = false;
            this._text$promotion_info_ability.visible = false;
            this._text$promotion_info_rebuild.visible = false;
            this._text$promotion_info_ability_add.visible = false;
            this.promotionInfoClassText.visible = false;
            this._text$promotion_info.visible = true;
            this._promote_heroic_title.visible = true;
            this._text$promotion_info_heroic_title.visible = true;
         }
         if(this._text$promotion_info_stats_w_talents)
         {
            this._text$promotion_info_stats_w_talents.visible = Talents.ENABLED;
         }
         this._text$promotion_info_stats.visible = !Talents.ENABLED;
         this._button$continue.setDownFunction(this.onConfirmClassClicked);
         this._button$cancel.setDownFunction(this.buttonCancelHandler);
         scaleTextfields();
      }
      
      private function cmdfunc_b(param1:CmdExec) : void
      {
         this._callbackCancel();
      }
   }
}
