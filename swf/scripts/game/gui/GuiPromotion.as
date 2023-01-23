package game.gui
{
   import engine.ability.IAbilityDef;
   import engine.ability.def.AbilityDefLevel;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.http.HttpAction;
   import engine.entity.UnitStatCosts;
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityClassDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.ILegend;
   import engine.gui.GuiButtonState;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.IGuiButton;
   import engine.stat.def.StatRanges;
   import engine.stat.def.StatType;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import game.gui.battle.GuiRenownConfirmDialog;
   import game.gui.page.GuiPromotionConfig;
   import game.gui.page.IGuiPromotionListener;
   import tbs.srv.util.IapMktCatPage;
   import tbs.srv.util.InAppPurchaseItemDef;
   
   public class GuiPromotion extends GuiBase
   {
       
      
      public var _chits:GuiChitsGroup;
      
      public var cancel:ButtonWithIndex;
      
      public var confirm:ButtonWithIndex;
      
      public var _entity:IEntityDef;
      
      public var characterClassesArray:Vector.<IEntityClassDef>;
      
      public var activeClassIndex:int;
      
      public var listener:IGuiPromotionListener;
      
      public var namingAccept:ButtonWithIndex;
      
      public var namingCancel:ButtonWithIndex;
      
      public var nameInput:TextField;
      
      public var renownText:TextField;
      
      public var renownBanner:ButtonWithIndex;
      
      public var className:TextField;
      
      public var classDesc:TextField;
      
      public var abilityName:TextField;
      
      public var abilityIcon:MovieClip;
      
      public var abilityDesc:TextField;
      
      public var currentCharacterClass:IEntityClassDef;
      
      public var renameMode:Boolean;
      
      public var button$random_name:ButtonWithIndex;
      
      public var guiConfig:GuiPromotionConfig;
      
      public var baseRenownCost:int;
      
      public var guiRenownConfirmDialog:GuiRenownConfirmDialog;
      
      public var _overlay_info:GuiPromotionInfo;
      
      public var _overlay_variation:GuiPromotionVariations;
      
      public var _overlay_class:MovieClip;
      
      public var _overlay_naming:MovieClip;
      
      public var _overlay_ability:GuiPromotionAbility;
      
      public var _left_arrow:ButtonWithIndex;
      
      public var _right_arrow:ButtonWithIndex;
      
      public var _renown_total:MovieClip;
      
      public var _stat_values:MovieClip;
      
      private var gp_l1:GuiGpBitmap;
      
      private var gp_r1:GuiGpBitmap;
      
      private var cmd_l1:Cmd;
      
      private var cmd_r1:Cmd;
      
      private var gplayer:int;
      
      private var show_class_id:String;
      
      private var use_unit_name:String;
      
      private var auto_name:Boolean;
      
      private var _selectedAbility:BattleAbilityDef;
      
      public function GuiPromotion()
      {
         this.characterClassesArray = new Vector.<IEntityClassDef>();
         this.guiRenownConfirmDialog = new GuiRenownConfirmDialog();
         this.gp_l1 = GuiGp.ctorPrimaryBitmap(GpControlButton.L1);
         this.gp_r1 = GuiGp.ctorPrimaryBitmap(GpControlButton.R1);
         this.cmd_l1 = new Cmd("pg_pro_l1",this.cmdfunc_l1);
         this.cmd_r1 = new Cmd("pg_pro_r1",this.cmdfunc_r1);
         super();
         this._overlay_info = getChildByName("overlay_info") as GuiPromotionInfo;
         this._overlay_variation = getChildByName("overlay_variation") as GuiPromotionVariations;
         this._overlay_class = getChildByName("overlay_class") as MovieClip;
         this._overlay_naming = getChildByName("overlay_naming") as MovieClip;
         this._left_arrow = getChildByName("left_arrow") as ButtonWithIndex;
         this._right_arrow = getChildByName("left_arrow") as ButtonWithIndex;
         this._renown_total = getChildByName("renown_total") as MovieClip;
         this._stat_values = getChildByName("stat_values") as MovieClip;
         this._overlay_ability = requireGuiChild("overlay_ability") as GuiPromotionAbility;
         this._overlay_ability.visible = false;
         this.gp_l1.scale = this.gp_r1.scale = 1.5;
         addChild(this.gp_l1);
         addChild(this.gp_r1);
         this.gp_l1.alwaysHint = true;
         this.gp_r1.alwaysHint = true;
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         this._overlay_info.handleLocaleChange();
      }
      
      private function get entity() : IEntityDef
      {
         return this._entity;
      }
      
      private function set entity(param1:IEntityDef) : void
      {
         var _loc2_:Vector.<IEntityClassDef> = null;
         var _loc3_:IEntityClassDef = null;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         this._selectedAbility = null;
         this._entity = param1;
         this.characterClassesArray.splice(0,this.characterClassesArray.length);
         this._overlay_variation.entity = param1;
         if(this._entity)
         {
            _loc2_ = this._entity.entityClass.playerOnlyChildEntityClasses;
            for each(_loc3_ in _loc2_)
            {
               _loc5_ = Boolean(context.isClassAvailable(_loc3_.id));
               if(_loc5_)
               {
                  this.characterClassesArray.push(_loc3_);
               }
            }
            this.currentCharacterClass = this._entity.entityClass;
            _loc4_ = int(this._entity.stats.rank);
            this.baseRenownCost = context.statCosts.getPromotionCost(_loc4_);
         }
         else
         {
            this.baseRenownCost = 0;
         }
      }
      
      private function infoCancelHandler() : void
      {
         this.onCancelClicked(null);
      }
      
      private function infoContinueHandler() : void
      {
         if(this.guiConfig.disabled && !this.guiConfig.allowConfirm)
         {
            return;
         }
         if(!this._entity)
         {
            return;
         }
         var _loc1_:int = int(this._entity.stats.rank);
         var _loc2_:UnitStatCosts = _context.statCosts;
         if(this.guiConfig.enableVariation)
         {
            if(this.haveEnoughRenown(_loc2_.getKillsRequiredToPromote(_loc1_)))
            {
               this.variationMode();
            }
         }
         else
         {
            if(_loc1_ + 1 == _loc2_.RANK_REBUILD)
            {
               if(this.showOverlayAbility())
               {
                  return;
               }
            }
            this.onAcceptClicked(this.confirm);
         }
      }
      
      public function init(param1:IGuiContext, param2:GuiPromotionConfig, param3:IGuiPromotionListener, param4:IGuiButton) : void
      {
         super.initGuiBase(param1);
         this.listener = param3;
         this.guiConfig = param2;
         this._overlay_info.init(param1,param2,this.infoContinueHandler,this.infoCancelHandler);
         this._overlay_variation.init(param1,param2,this.setupVariationConfirmCancel,this.variationCostChangedHandler);
         this._overlay_ability.init(param1,this.overlayAbilityChooseHandler);
         this.className = this._overlay_class.getChildByName("className") as TextField;
         this.classDesc = this._overlay_class.getChildByName("classDesc") as TextField;
         this.abilityName = this._overlay_class.getChildByName("abilityName") as TextField;
         this.abilityDesc = this._overlay_class.getChildByName("abilityDesc") as TextField;
         this.abilityIcon = this._overlay_class.getChildByName("promoteAbilityIcon") as MovieClip;
         this._overlay_naming = getChildByName("overlay_naming") as MovieClip;
         this.button$random_name = this._overlay_naming.getChildByName("button$random_name") as ButtonWithIndex;
         this.button$random_name.setDownFunction(this.onbutton$random_nameClick);
         this.namingCancel = this._overlay_naming.getChildByName("button$cancel") as ButtonWithIndex;
         this.namingCancel.setDownFunction(this.onCancelClicked);
         this.nameInput = this._overlay_naming.getChildByName("name_input") as TextField;
         this.nameInput.text = "";
         this.nameInput.addEventListener(Event.CHANGE,this.onNameInputChanged);
         this.namingAccept = this._overlay_naming.getChildByName("button$accept") as ButtonWithIndex;
         this.namingAccept.setDownFunction(this.onAcceptClicked);
         this._left_arrow = getChildByName("left_arrow") as ButtonWithIndex;
         this._left_arrow.guiButtonContext = param1;
         this._left_arrow.setDownFunction(this.onArrowClick);
         this._right_arrow = getChildByName("right_arrow") as ButtonWithIndex;
         this._right_arrow.setDownFunction(this.onArrowClick);
         this._right_arrow.guiButtonContext = param1;
         this.cancel = getChildByName("button$cancel") as ButtonWithIndex;
         this.cancel.setDownFunction(this.onCancelClicked);
         this.cancel.guiButtonContext = param1;
         this.confirm = getChildByName("button$confirm") as ButtonWithIndex;
         this.confirm.guiButtonContext = param1;
         this._renown_total = getChildByName("renown_total") as MovieClip;
         this.renownText = this._renown_total.getChildByName("text") as TextField;
         this.renownText.text = "";
         this._stat_values = getChildByName("stat_values") as MovieClip;
         this.renownBanner = param4 as ButtonWithIndex;
         this._chits = requireGuiChild("chits") as GuiChitsGroup;
         this._chits.init(param1);
         this.guiRenownConfirmDialog.init(param1);
         param2.addEventListener(GuiPromotionConfig.EVENT_CHANGED,this.guiConfigHandler);
         this.guiConfigHandler(null);
      }
      
      public function cleanup() : void
      {
         this.cmd_l1.cleanup();
         this.cmd_r1.cleanup();
         this.cmd_l1 = null;
         this.cmd_r1 = null;
         GuiGp.releasePrimaryBitmap(this.gp_l1);
         GuiGp.releasePrimaryBitmap(this.gp_r1);
         this.gp_l1 = null;
         this.gp_r1 = null;
         this.guiConfig.removeEventListener(GuiPromotionConfig.EVENT_CHANGED,this.guiConfigHandler);
         this.nameInput.removeEventListener(Event.CHANGE,this.onNameInputChanged);
         this.guiRenownConfirmDialog.cleanup();
         this.guiRenownConfirmDialog = null;
         if(this.renownBanner)
         {
            this.renownBanner.cleanup();
            this.renownBanner = null;
         }
         this.confirm.cleanup();
         this.confirm = null;
         this.cancel.cleanup();
         this.cancel = null;
         this._right_arrow.cleanup();
         this._right_arrow = null;
         this._left_arrow.cleanup();
         this._left_arrow = null;
         this.namingAccept.cleanup();
         this.namingAccept = null;
         this.namingCancel.cleanup();
         this.namingCancel = null;
         this.button$random_name.cleanup();
         this.button$random_name = null;
         this._overlay_variation.cleanup();
         this._overlay_variation = null;
         this._overlay_info.cleanup();
         this._overlay_info = null;
         this.listener = null;
         this.guiConfig = null;
         if(this._overlay_ability)
         {
            this._overlay_ability.cleanup();
            this._overlay_ability = null;
         }
         while(numChildren)
         {
            removeChildAt(numChildren - 1);
         }
         super.cleanupGuiBase();
      }
      
      private function guiConfigHandler(param1:Event) : void
      {
         if(!this.guiConfig)
         {
            return;
         }
         if(this.guiConfig.disabled)
         {
            this.nameInput.type = TextFieldType.DYNAMIC;
         }
         else
         {
            this.nameInput.type = TextFieldType.INPUT;
         }
      }
      
      private function onNameInputChanged(param1:Event) : void
      {
         if(this.nameInput.text)
         {
            this.namingAccept.disableGotoOnStateChange = true;
            this.namingAccept.enabled = true;
         }
         else
         {
            this.namingAccept.enabled = false;
            this.namingAccept.disableGotoOnStateChange = false;
         }
      }
      
      private function renownDialogCallback(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc3_:IEntityClassDef = null;
         var _loc4_:ILegend = null;
         var _loc5_:String = null;
         if(param1 != "Confirm")
         {
            this.onCancelClicked(null);
            return;
         }
         if(this.renameMode)
         {
            context.legend.rename(this.entity.id,this.nameInput.text);
            this.closeAndUpdate();
         }
         else if(this._overlay_variation.variationFromBio)
         {
            this.purchaseVariationAndClose(null);
         }
         else
         {
            _loc2_ = this._entity.id;
            if(this.activeClassIndex >= 0 && this.activeClassIndex < this.characterClassesArray.length)
            {
               _loc3_ = this.characterClassesArray[this.activeClassIndex];
            }
            else
            {
               _loc3_ = this.currentCharacterClass;
            }
            _loc4_ = context.legend;
            _loc5_ = this.guiConfig.enableName ? this.nameInput.text : null;
            _loc4_.promote(_loc2_,_loc3_.id,_loc5_,this.purchaseVariationAndClose);
            if(this._selectedAbility)
            {
               this._entity.addActiveAbilityDefLevel(new AbilityDefLevel(this._selectedAbility,1,this._entity.stats.rank),_context.logger);
               this._selectedAbility = null;
            }
         }
         this.listener.guiPromotionHide();
         this.hideEverything();
      }
      
      private function onAcceptClicked(param1:ButtonWithIndex) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:int = int(this.renownText.text);
         if(this.renameMode)
         {
            _loc2_ = context.statCosts.getRenameCost();
            _loc4_ = "renown_confirm_title_rename";
            _loc3_ = "renown_confirm_body_rename";
         }
         else if(this._overlay_variation.variationFromBio)
         {
            _loc4_ = "renown_confirm_title_variation";
            _loc3_ = "renown_confirm_body_variation";
         }
         else
         {
            _loc4_ = "renown_confirm_title_promotion";
            _loc3_ = "renown_confirm_body_promotion";
         }
         if(_loc2_ <= 0)
         {
            this.renownDialogCallback("Confirm");
            return;
         }
         if(!this.haveEnoughRenown(_loc2_))
         {
            return;
         }
         var _loc5_:String = context.translate(_loc3_).replace("$RENOWN",_loc2_.toString());
         if(!this.guiConfig.disabled)
         {
            this.guiRenownConfirmDialog.display(_loc4_,_loc5_,this.renownDialogCallback);
         }
         else
         {
            this.renownDialogCallback("Confirm");
         }
      }
      
      private function purchaseVariationAndClose(param1:HttpAction) : void
      {
         if(param1 == null || param1.success)
         {
            this.purchaseAndSetVariation();
            this.closeAndUpdate();
         }
      }
      
      private function closeAndUpdate() : void
      {
         this.listener.guiPromotionPromote();
         this.onCancelClicked(null);
         if(this.renownBanner)
         {
            this.renownBanner.buttonText = context.legend.renown.toString();
         }
         this.listener.guiPromotionNamingAccept();
      }
      
      private function haveEnoughRenown(param1:int) : Boolean
      {
         var _loc2_:IGuiDialog = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         if(param1 > context.legend.renown)
         {
            context.playSound("ui_players_turn");
            if(this.renownBanner)
            {
               this.renownBanner.setStateForCertainTimeframe(GuiButtonState.HOVER,20);
            }
            _loc2_ = context.createDialog();
            _loc3_ = context.translate("pg_promote_insufficient_renown_title");
            _loc4_ = context.translate("pg_promote_insufficient_renown_body");
            _loc4_ = _loc4_.replace("$RENOWN",param1.toString());
            _loc5_ = context.translate("ok");
            _loc2_.openDialog(_loc3_,_loc4_,_loc5_);
            return false;
         }
         return true;
      }
      
      private function onConfirmClassClicked(param1:ButtonWithIndex) : void
      {
         if(this.guiConfig.disabled && !this.guiConfig.allowConfirm)
         {
            return;
         }
         if(this.haveEnoughRenown(context.statCosts.getKillsRequiredToPromote(this.entity.stats.rank)))
         {
            this._overlay_variation.variationFromBio = false;
            this.variationMode();
         }
      }
      
      private function onConfirmVariationClicked(param1:ButtonWithIndex) : void
      {
         if(this.guiConfig.disabled && !this.guiConfig.allowConfirm)
         {
            return;
         }
         if(this.haveEnoughRenown(int(this.renownText.text)))
         {
            this.namingMode();
         }
      }
      
      private function purchaseAndSetVariation() : void
      {
         var vi:int = this._overlay_variation.variationIndex;
         var app:IEntityAppearanceDef = this.currentCharacterClass.getEntityClassAppearanceDef(vi);
         if(Boolean(app.unlock_id) && !context.hasUnlock(app.unlock_id))
         {
            context.logger.error("Cannot purchase " + vi + ", not unlocked: " + app.unlock_id);
            return;
         }
         try
         {
            context.legend.purchaseVariation(this.entity,vi);
            context.playSound("ui_stats_promote");
         }
         catch(error:Error)
         {
            context.logger.error("Error purchasing: " + error);
         }
      }
      
      private function onCancelClicked(param1:ButtonWithIndex) : void
      {
         if(param1)
         {
            if(this.guiConfig.disabled)
            {
               return;
            }
            param1.setStateToNormal();
         }
         this.listener.guiPromotionHide();
         this.confirm.setDownFunction(null);
      }
      
      private function hideEverything() : void
      {
         this.gpArrowsDisable();
         this._selectedAbility = null;
         this._overlay_info.visible = false;
         this._overlay_class.visible = false;
         this._overlay_ability.visible = false;
         this._overlay_naming.visible = false;
         this._left_arrow.visible = false;
         this._right_arrow.visible = false;
         this.cancel.visible = false;
         this.confirm.visible = false;
         this._overlay_variation.visible = false;
         this._stat_values.visible = false;
         this._chits.visible = false;
      }
      
      private function onbutton$random_nameClick(param1:ButtonWithIndex) : void
      {
         if(this.guiConfig.disabled)
         {
            return;
         }
         this.setRandomName(this.entity.entityClass);
      }
      
      public function characterInfoMode(param1:IEntityDef) : void
      {
         this.hideEverything();
         this.entity = param1;
         this.variationCostChangedHandler();
         this._overlay_info.characterInfoMode(param1);
      }
      
      private function setRandomName(param1:IEntityClassDef) : void
      {
         if(param1.partyTag == "archer")
         {
            this.nameInput.text = context.randomFemaleName;
         }
         else
         {
            this.nameInput.text = context.randomMaleName;
         }
      }
      
      public function renameEntity(param1:IEntityDef) : void
      {
         this.hideEverything();
         this.renameMode = true;
         this._overlay_variation.variationFromBio = false;
         this.renownText.text = context.statCosts.getRenameCost().toString();
         this.setRandomName(param1.entityClass);
         this.currentCharacterClass = param1.entityClass;
         this.entity = param1;
         this.namingMode();
      }
      
      private function namingMode() : void
      {
         var _loc1_:int = 0;
         this.hideEverything();
         this._overlay_naming.visible = true;
         if(this.renameMode)
         {
            this.setClassIconHolder(this._overlay_naming,context.getEntityPromotePortrait(this.entity));
         }
         else
         {
            _loc1_ = this._overlay_variation.variationIndex;
            this.setClassIconHolder(this._overlay_naming,context.getEntityClassPromotePortraitAtAppIndex(this.currentCharacterClass,_loc1_));
         }
         stage.focus = this.nameInput;
         this.nameInput.setSelection(0,this.nameInput.text.length);
         this.listener.guiPromotionNamingMode();
      }
      
      private function setupVariationConfirmCancel() : void
      {
         this.cancel.visible = true;
         this.confirm.visible = true;
         if(this._overlay_variation.variationFromBio || this.entity.stats.rank > 1)
         {
            this.confirm.setDownFunction(this.onAcceptClicked);
         }
         else
         {
            this.confirm.setDownFunction(this.onConfirmVariationClicked);
         }
         this.listener.guiPromotionVariationSelected();
      }
      
      private function variationCostChangedHandler() : void
      {
         if(this._overlay_variation.variationFromBio)
         {
            this.renownText.text = "0";
         }
         else
         {
            this.renownText.text = (this.baseRenownCost + this._overlay_variation.cost).toString();
         }
      }
      
      private function onStoreOnlyVariationButtonClick(param1:ButtonWithIndex) : void
      {
         if(!context.iap)
         {
            context.logger.error("no IAP for store only variation");
            return;
         }
         var _loc2_:int = int(param1.name.replace("_",""));
         if(context.iap.itemList.findItemsByUnlock(this.currentCharacterClass.appearanceDefs[_loc2_].unlock_id).length <= 0)
         {
            context.logger.error("unable to locate the unlock id called: " + this.currentCharacterClass.appearanceDefs[_loc2_].unlock_id + " consult Jenkins or check character_classes.");
            return;
         }
         var _loc3_:InAppPurchaseItemDef = context.iap.itemList.findItemsByUnlock(this.currentCharacterClass.appearanceDefs[_loc2_].unlock_id)[0];
         var _loc4_:IapMktCatPage = context.iap.itemList.mkt.findPageForItem(_loc3_.id);
         context.showMarket(true,_loc3_.category,_loc4_.id,this.variationMode);
      }
      
      public function bioVariation(param1:IEntityDef) : void
      {
         this.renameMode = false;
         this.baseRenownCost = 0;
         this.renownText.text = "0";
         this.currentCharacterClass = param1.entityClass;
         this.entity = param1;
         this._overlay_variation.bioVariation(this.entity);
      }
      
      private function turnOffOtherTogggles(param1:String) : void
      {
         var _loc3_:ButtonWithIndex = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.currentCharacterClass.appearanceDefs.length)
         {
            _loc3_ = this._overlay_variation.getChildByName("_" + _loc2_) as ButtonWithIndex;
            if(_loc3_.name != param1)
            {
               _loc3_.isToggle = false;
               _loc3_.toggled = false;
            }
            _loc2_++;
         }
      }
      
      private function variationMode() : void
      {
         this.hideEverything();
         this._overlay_variation.variationMode(this.currentCharacterClass);
         this.listener.guiPromotionVariationOpened();
      }
      
      private function changeActiveClass(param1:int) : void
      {
         if(param1 >= this.characterClassesArray.length)
         {
            param1 = 0;
         }
         else if(param1 < 0)
         {
            param1 = this.characterClassesArray.length - 1;
         }
         this.setBaseStatValues(this.characterClassesArray[param1].statRanges);
         this.className.text = this.characterClassesArray[param1].name;
         this.classDesc.text = this.characterClassesArray[param1].description;
         var _loc2_:IAbilityDef = context.getAbilityDef(this.characterClassesArray[param1].actives[0]);
         this.abilityName.text = _loc2_.name;
         this.abilityDesc.text = _loc2_.descriptionBrief;
         var _loc3_:GuiIcon = context.getLargeAbilityIcon(_loc2_);
         if(_loc3_)
         {
            this.abilityIcon.removeChildAt(0);
            this.abilityIcon.addChildAt(_loc3_,0);
         }
         this.setClassIconHolder(this._overlay_class,context.getEntityClassPromotePortraitAtAppIndex(this.characterClassesArray[param1],0));
         this._chits.activeChitIndex[param1];
         this.activeClassIndex = param1;
         this.currentCharacterClass = this.characterClassesArray[this.activeClassIndex];
      }
      
      private function setSingleStatRange(param1:StatRanges, param2:String, param3:StatType) : void
      {
         var _loc4_:MovieClip = this._stat_values.getChildByName(param2) as MovieClip;
         _loc4_.numerator.text = param1.getStatRange(param3).max;
      }
      
      private function setBaseStatValues(param1:StatRanges) : void
      {
         this.setSingleStatRange(param1,"armor_text",StatType.ARMOR);
         this.setSingleStatRange(param1,"strength_text",StatType.STRENGTH);
         this.setSingleStatRange(param1,"willpower_text",StatType.WILLPOWER);
         this.setSingleStatRange(param1,"exertion_text",StatType.EXERTION);
         this.setSingleStatRange(param1,"armor_break_text",StatType.ARMOR_BREAK);
      }
      
      private function setupChits(param1:int) : void
      {
         this._chits.numVisibleChits = param1;
         this._chits.visible = true;
      }
      
      private function onArrowClick(param1:ButtonWithIndex) : void
      {
         if(this.guiConfig.disabled)
         {
            return;
         }
         if(param1.name == "left_arrow")
         {
            if(this._overlay_ability.visible)
            {
               this._chits.activeChitIndex = this._overlay_ability.prevAbility();
            }
            else
            {
               this.changeActiveClass(this.activeClassIndex - 1);
            }
         }
         else if(this._overlay_ability.visible)
         {
            this._chits.activeChitIndex = this._overlay_ability.nextAbility();
         }
         else
         {
            this.changeActiveClass(this.activeClassIndex + 1);
         }
      }
      
      public function showOverlayAbility() : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:BattleAbilityDef = null;
         if(!this._entity)
         {
            return false;
         }
         var _loc1_:Vector.<BattleAbilityDef> = new Vector.<BattleAbilityDef>();
         var _loc2_:Vector.<String> = this._entity.additionalActives;
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_)
            {
               if(!(Boolean(this._entity.actives) && this._entity.actives.hasAbility(_loc3_)))
               {
                  _loc4_ = _context.getAbilityDefById(_loc3_) as BattleAbilityDef;
                  _loc1_.push(_loc4_);
               }
            }
         }
         if(_loc1_.length > 0)
         {
            this.hideEverything();
            this.gpArrowsEnable();
            this._overlay_ability.setupAbilities(this._entity,_loc1_);
            this._overlay_ability.visible = true;
            this._left_arrow.visible = true;
            this._right_arrow.visible = true;
            this.cancel.visible = false;
            this.confirm.visible = false;
            this.setupChits(_loc1_.length);
            this._chits.activeChitIndex = 0;
            return true;
         }
         return false;
      }
      
      private function gpArrowsEnable() : void
      {
         this.gpArrowsDisable();
         this.gplayer = GpBinder.gpbinder.createLayer("GuiPromotion");
         GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_l1);
         GpBinder.gpbinder.bindPress(GpControlButton.R1,this.cmd_r1);
         this.gp_l1.gplayer = this.gplayer;
         this.gp_r1.gplayer = this.gplayer;
         this.gp_l1.visible = true;
         this.gp_r1.visible = true;
         GuiGp.placeIconBottom(this._left_arrow,this.gp_l1);
         GuiGp.placeIconBottom(this._right_arrow,this.gp_r1);
      }
      
      private function gpArrowsDisable() : void
      {
         if(this.gplayer)
         {
            GpBinder.gpbinder.unbind(this.cmd_l1);
            GpBinder.gpbinder.unbind(this.cmd_r1);
            GpBinder.gpbinder.removeLayer(this.gplayer);
            this.gplayer = 0;
            this.gp_l1.visible = false;
            this.gp_r1.visible = false;
         }
      }
      
      private function onInfoModeClicked(param1:ButtonWithIndex) : void
      {
         this.gpArrowsEnable();
         this.removeEventListener(MouseEvent.MOUSE_UP,this.onInfoModeClicked);
         this.confirm.setDownFunction(this.onConfirmClassClicked);
         this.hideEverything();
         this._overlay_class.visible = true;
         this._left_arrow.visible = true;
         this._right_arrow.visible = true;
         if(!this.guiConfig.disabled)
         {
            this._right_arrow.pulseHover(500);
         }
         this._stat_values.visible = true;
         this.cancel.visible = true;
         this.confirm.visible = true;
         this.activeClassIndex = 0;
         this.changeActiveClass(this.activeClassIndex);
         this.setupChits(this.characterClassesArray.length);
      }
      
      public function showPromotionClassId(param1:String, param2:String) : void
      {
         this.show_class_id = param1;
         this.use_unit_name = param2;
         if(!this.show_class_id)
         {
            this.show_class_id = this.characterClassesArray.length > this.activeClassIndex ? this.characterClassesArray[this.activeClassIndex].id : null;
            if(!this.show_class_id)
            {
               return;
            }
         }
         this.handleShowClassId();
      }
      
      private function handleShowClassId() : void
      {
         var _loc1_:int = 0;
         var _loc2_:IEntityClassDef = null;
         this.onInfoModeClicked(null);
         if(this.show_class_id)
         {
            _loc1_ = 0;
            while(_loc1_ < this.characterClassesArray.length)
            {
               _loc2_ = this.characterClassesArray[_loc1_];
               if(_loc2_.id == this.show_class_id)
               {
                  this.changeActiveClass(_loc1_);
                  break;
               }
               _loc1_++;
            }
         }
         if(this.use_unit_name)
         {
            this.nameInput.text = this.use_unit_name;
         }
      }
      
      private function setClassIconHolder(param1:MovieClip, param2:GuiIcon) : void
      {
         var _loc3_:MovieClip = param1.getChildByName("classIconHolder") as MovieClip;
         if(_loc3_.numChildren > 0)
         {
            _loc3_.removeChildAt(0);
         }
         _loc3_.addChild(param2);
      }
      
      public function set autoName(param1:Boolean) : void
      {
         this.auto_name = param1;
      }
      
      public function update(param1:int) : void
      {
         if(Boolean(this._overlay_ability) && this._overlay_ability.visible)
         {
            this._overlay_ability.update(param1);
         }
      }
      
      private function overlayAbilityChooseHandler(param1:BattleAbilityDef) : void
      {
         if(!param1)
         {
            this.cancel.press();
            return;
         }
         this._selectedAbility = param1;
         this.onAcceptClicked(this.confirm);
      }
      
      private function cmdfunc_l1(param1:CmdExec) : void
      {
         if(this._left_arrow.visible)
         {
            this._left_arrow.press();
            this.gp_l1.pulse();
         }
      }
      
      private function cmdfunc_r1(param1:CmdExec) : void
      {
         if(this._right_arrow.visible)
         {
            this._right_arrow.press();
            this.gp_r1.pulse();
         }
      }
   }
}
