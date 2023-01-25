package game.gui
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.ITitleDef;
   import engine.entity.def.ITitleListDef;
   import engine.entity.def.ItemDef;
   import engine.gui.GuiContextEvent;
   import engine.saga.ISagaDef;
   import engine.saga.SagaAchievements;
   import engine.saga.SagaVar;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import game.gui.battle.GuiRenownConfirmDialog;
   import game.gui.pages.GuiPgDetails;
   import game.gui.pages.GuiTitleRankChanger;
   
   public class GuiHeroicTitles extends GuiBase
   {
      
      public static var mcClazzRankText:Class;
      
      public static const MAX_TITLES:int = 20;
      
      public static const RANK_HEROIC_TITLE:int = 11;
      
      private static const SELECTION_PREFIX:String = "<font color=\'#DFF3FE\'>";
      
      private static const SELECTION_SUFFIX:String = "</font>";
       
      
      private var _text_desc:TextField;
      
      private var _text_title:TextField;
      
      private var _text_ranks:TextField;
      
      private var _titlesChits:GuiChitsGroup;
      
      private var _rankFrame:DisplayObjectContainer;
      
      public var _button$continue:ButtonWithIndex;
      
      public var _button_left:ButtonWithIndex;
      
      public var _button_right:ButtonWithIndex;
      
      public var _rankChanger:GuiTitleRankChanger;
      
      private var _iSagaDef:ISagaDef;
      
      private var _titleDefs:ITitleListDef;
      
      private var _validTitles:Vector.<ITitleDef>;
      
      private var _renownCostFrame:MovieClip;
      
      private var _text_cost:TextField;
      
      private var _fail_text_cost:TextField;
      
      private var _inTitleRankToPurchaseUpdateFailSequence:Boolean;
      
      private var _guiPgDetails:GuiPgDetails;
      
      private var _curCharacter:IEntityDef;
      
      private var _lastSelectedDict:Dictionary;
      
      public var _guiTitleConfirmDialog:GuiRenownConfirmDialog;
      
      public var gp:GuiHeroicTitles_Gp;
      
      public function GuiHeroicTitles()
      {
         this._guiTitleConfirmDialog = new GuiRenownConfirmDialog();
         this.gp = new GuiHeroicTitles_Gp();
         super();
         this.visible = false;
         this._validTitles = new Vector.<ITitleDef>();
         this._lastSelectedDict = new Dictionary();
         this._guiTitleConfirmDialog = new GuiRenownConfirmDialog();
         this._button$continue = requireGuiChild("button$continue") as ButtonWithIndex;
         this._button_left = requireGuiChild("titleLeft") as ButtonWithIndex;
         this._button_right = requireGuiChild("titleRight") as ButtonWithIndex;
         this._text_desc = requireGuiChild("text_desc") as TextField;
         this._text_title = requireGuiChild("titleText") as TextField;
         this._text_ranks = requireGuiChild("text_ranks") as TextField;
         this._renownCostFrame = requireGuiChild("renownCostFrame") as MovieClip;
         this._text_cost = requireGuiChild("renownCost",this._renownCostFrame) as TextField;
         this._fail_text_cost = requireGuiChild("renownCostFail",this._renownCostFrame) as TextField;
         this._titlesChits = requireGuiChild("titlesChits") as GuiChitsGroup;
         this._rankFrame = requireGuiChild("rankFrame") as DisplayObjectContainer;
         this._rankChanger = requireGuiChild("rankGui") as GuiTitleRankChanger;
      }
      
      public function init(param1:IGuiContext, param2:GuiPgDetails) : void
      {
         super.initGuiBase(param1);
         this._iSagaDef = param1.saga.def;
         this._titleDefs = this._iSagaDef.titleDefs;
         this._guiPgDetails = param2;
         registerScalableTextfield2d(this._text_ranks,false);
         registerScalableTextfield(this._text_title,true);
         this._button_left.guiButtonContext = param1;
         this._button_right.guiButtonContext = param1;
         this._button$continue.guiButtonContext = param1;
         this._button$continue.visible = false;
         this._renownCostFrame.visible = false;
         this._button_left.clickSound = "ui_heroic_title_select";
         this._button_right.clickSound = "ui_heroic_title_select";
         this._button$continue.clickSound = "ui_heroic_title_continue";
         this._guiTitleConfirmDialog.setSounds("ui_heroic_title_confirm","ui_heroic_title_cancel");
         this._button_left.setDownFunction(this.buttonTitleLeftPressed);
         this._button_right.setDownFunction(this.buttonTitleRightPressed);
         this._button$continue.setDownFunction(this.buttonConfirmPressed);
         this._titlesChits.init(param1);
         this._rankChanger.init(param1,this);
         this._guiTitleConfirmDialog.init(param1);
         this.gp.init(this,this._rankChanger);
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         this._rankChanger.handleLocaleChange();
         this.updateDisplay();
         scaleTextfields();
      }
      
      public function cleanup() : void
      {
         _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.gp.cleanup();
         this._validTitles.length = 0;
         this._button$continue.cleanup();
         this._button$continue = null;
         this._button_left.cleanup();
         this._button_left = null;
         this._button_right.cleanup();
         this._button_right = null;
         this._rankChanger.cleanup();
         this._rankChanger = null;
         this._guiTitleConfirmDialog.cleanup();
         this._guiTitleConfirmDialog = null;
      }
      
      public function update() : void
      {
         if(this._titleDefs == null)
         {
            return;
         }
         this.updateValidTitles();
         this._titlesChits.numVisibleChits = this._validTitles.length;
         this.updateDisplay();
      }
      
      public function updateDisplay() : void
      {
         var _loc1_:ITitleDef = null;
         if(this._validTitles.length == 0 || this._curCharacter == null)
         {
            this.displayBlank();
            return;
         }
         var _loc2_:int = !!this._curCharacter.defTitle ? 0 : this.getLastSelected(this._curCharacter);
         if(_loc2_ < 0 || _loc2_ >= this._validTitles.length)
         {
            _loc2_ = 0;
         }
         this._button$continue.visible = false;
         this._renownCostFrame.visible = false;
         this._rankChanger.updateDisplay(this._curCharacter.stats.titleRank);
         _loc1_ = !!this._curCharacter.defTitle ? this._curCharacter.defTitle : this._validTitles[_loc2_];
         this.displayTitle(_loc1_);
         this.displayRanks(_loc1_);
         _context.locale.fixTextFieldFormat(this._text_cost);
         _context.locale.fixTextFieldFormat(this._fail_text_cost);
         TweenMax.killTweensOf(this._fail_text_cost);
         this.curTitleIndex = _loc2_;
      }
      
      private function displayBlank() : void
      {
         this._titlesChits.activeChitIndex = 0;
         this.displayTitle(null);
         this.displayRanks(null);
         this._rankChanger.updateDisplay(0);
         this._guiPgDetails.setGuiHeroicTitlesVisible(false);
      }
      
      public function set curTitleIndex(param1:int) : void
      {
         this._titlesChits.activeChitIndex = param1;
         this.updateLeftRightButtons();
         if(Boolean(this._curCharacter) && Boolean(this._lastSelectedDict))
         {
            this._lastSelectedDict[this._curCharacter] = this._titlesChits.activeChitIndex;
         }
      }
      
      public function get curTitleIndex() : int
      {
         return this._titlesChits.activeChitIndex;
      }
      
      public function get curTitle() : ITitleDef
      {
         return !!this._validTitles.length ? this._validTitles[this.curTitleIndex] : null;
      }
      
      public function get pgDetails() : GuiPgDetails
      {
         return this._guiPgDetails;
      }
      
      private function updateLeftRightButtons() : void
      {
         if(this._curCharacter && this._curCharacter.defTitle || this._validTitles.length <= 1)
         {
            this._button_left.visible = false;
            this._button_right.visible = false;
         }
         else
         {
            this._button_left.visible = true;
            this._button_right.visible = true;
         }
      }
      
      private function displayTitle(param1:ITitleDef) : void
      {
         var _loc2_:String = !!this._curCharacter ? this._curCharacter.gender : null;
         this._text_title.htmlText = !!param1 ? "\"" + param1.getName(_loc2_) + "\"" : "";
         this._text_desc.htmlText = !!param1 ? param1.getDescription(_loc2_) : "";
         context.currentLocale.fixTextFieldFormat(this._text_title);
         context.currentLocale.fixTextFieldFormat(this._text_desc);
      }
      
      private function displayRanks(param1:ITitleDef) : void
      {
         var _loc5_:String = null;
         var _loc6_:* = null;
         var _loc7_:ItemDef = null;
         var _loc8_:String = null;
         if(!param1)
         {
            return;
         }
         var _loc2_:Locale = _context.locale;
         var _loc3_:* = "";
         var _loc4_:int = 0;
         while(_loc4_ < param1.numRanks)
         {
            if(_loc3_)
            {
               _loc3_ += "\n";
            }
            _loc5_ = (_loc4_ + 1).toString();
            _loc6_ = _loc2_.translateGui("pg_abl_rank");
            _loc6_ = _loc6_.replace("$RANK",_loc5_);
            _loc6_ += ": ";
            _loc7_ = param1.getRank(_loc4_);
            _loc8_ = _loc2_.translate(LocaleCategory.TITLE,_loc7_.id);
            _loc6_ += _loc8_;
            if(this._rankChanger.currentRank == _loc4_ + 1)
            {
               _loc6_ = SELECTION_PREFIX + _loc6_ + SELECTION_SUFFIX;
            }
            _loc3_ += _loc6_;
            _loc4_++;
         }
         this._text_ranks.htmlText = _loc3_;
         _loc2_.fixTextFieldFormat(this._text_ranks);
         super.scaleTextfields();
      }
      
      public function set currentCharacter(param1:IEntityDef) : void
      {
         if(this._curCharacter == param1)
         {
            return;
         }
         this._curCharacter = param1;
         this.update();
      }
      
      public function get currentCharacter() : IEntityDef
      {
         return this._curCharacter;
      }
      
      private function updateValidTitles() : void
      {
         var td:ITitleDef = null;
         var g:String = null;
         this._validTitles.length = 0;
         if(Boolean(this._curCharacter) && Boolean(this._curCharacter.defTitle))
         {
            this._validTitles.push(this._curCharacter.defTitle);
            return;
         }
         for each(td in this._titleDefs.getTitleDict())
         {
            if(this.isValidTitle(td))
            {
               this._validTitles.push(td);
            }
         }
         g = !!this._curCharacter ? this._curCharacter.gender : null;
         this._validTitles = this._validTitles.sort(function(param1:ITitleDef, param2:ITitleDef):int
         {
            var _loc3_:* = param1.getName(g);
            var _loc4_:* = param2.getName(g);
            if(_loc3_.toLocaleLowerCase() > _loc4_.toLocaleLowerCase())
            {
               return 1;
            }
            if(_loc3_ < _loc4_)
            {
               return -1;
            }
            return 0;
         });
      }
      
      public function buttonConfirmPressed(param1:*) : void
      {
         var _loc2_:int = this._rankChanger.pendingRenownSpend();
         var _loc3_:int = context.saga.getVarNumber(SagaVar.VAR_RENOWN);
         if(_loc2_ <= 0)
         {
            this.confirmDialogCallback("Confirm");
            return;
         }
         if(_loc2_ > _loc3_)
         {
            context.playSound("ui_error");
            this.confirmDialogCallback("Cancel");
            return;
         }
         var _loc4_:String = "renown_confirm_title_heroic_title";
         var _loc5_:String = "renown_confirm_body_heroic_title";
         var _loc6_:String = String(context.translate(_loc5_));
         _loc6_ = _loc6_.replace("$RENOWN",_loc2_);
         var _loc7_:String = !!this._curCharacter ? this._curCharacter.gender : null;
         _loc6_ = _loc6_.replace("$TITLE",this.curTitle.getName(_loc7_));
         this._guiTitleConfirmDialog.display(_loc4_,_loc6_,this.confirmDialogCallback);
      }
      
      public function buttonCancelPressed(param1:*) : void
      {
         this._guiPgDetails.setGuiHeroicTitlesVisible(false);
      }
      
      public function buttonTitleLeftPressed(param1:*) : void
      {
         if(this.curTitleIndex > 0)
         {
            --this.curTitleIndex;
         }
         else
         {
            this.curTitleIndex = this._validTitles.length - 1;
         }
         this.updateDisplay();
      }
      
      public function buttonTitleRightPressed(param1:*) : void
      {
         if(this.curTitleIndex < this._validTitles.length - 1)
         {
            ++this.curTitleIndex;
         }
         else
         {
            this.curTitleIndex = 0;
         }
         this.updateDisplay();
      }
      
      public function updateTitleRankPurchase(param1:int) : void
      {
         TweenMax.killTweensOf(this._fail_text_cost);
         this._fail_text_cost.visible = false;
         this._text_cost.visible = true;
         this._inTitleRankToPurchaseUpdateFailSequence = false;
         if(param1 != 0 && param1 != this._curCharacter.stats.titleRank && param1 <= this.curTitle.numRanks)
         {
            this._button$continue.visible = true;
            this._renownCostFrame.visible = true;
            this._text_cost.text = this._rankChanger.calculateRenownSpend(param1).toString();
         }
         else
         {
            this._button$continue.visible = false;
            this._renownCostFrame.visible = false;
         }
         this.displayRanks(this.curTitle);
      }
      
      public function failUpdateTitleRankPurchase(param1:int) : void
      {
         if(this._inTitleRankToPurchaseUpdateFailSequence)
         {
            return;
         }
         this._inTitleRankToPurchaseUpdateFailSequence = true;
         this._text_cost.visible = false;
         this._fail_text_cost.visible = true;
         this._renownCostFrame.visible = true;
         this._fail_text_cost.text = this._rankChanger.calculateRenownSpend(param1).toString();
         TweenMax.fromTo(this._fail_text_cost,0.5,{
            "alpha":0.7,
            "scaleX":0.9,
            "scaleY":0.9
         },{
            "alpha":1,
            "scaleX":1,
            "scaleY":1,
            "ease":Back.easeOut,
            "repeat":3,
            "onComplete":this.updateTitleRankPurchase,
            "onCompleteParams":[param1 - 1]
         });
      }
      
      private function isValidTitle(param1:ITitleDef) : Boolean
      {
         return Boolean(context) && Boolean(context.saga) ? context.saga.isTitleValid(this._curCharacter,param1) : false;
      }
      
      private function getLastSelected(param1:IEntityDef) : int
      {
         if(param1 == null || this._lastSelectedDict == null)
         {
            return 0;
         }
         var _loc2_:Object = this._lastSelectedDict[param1];
         if(_loc2_)
         {
            return int(_loc2_);
         }
         return 0;
      }
      
      private function confirmDialogCallback(param1:String) : void
      {
         if(param1 == "Cancel")
         {
            return;
         }
         var _loc2_:Boolean = context.saga.suppressVariableFlytext;
         context.saga.suppressVariableFlytext = true;
         context.saga.setVar("renown",context.saga.getVarInt("renown") - this._rankChanger.pendingRenownSpend());
         context.saga.suppressVariableFlytext = _loc2_;
         this._curCharacter.defTitle = this.curTitle;
         this._curCharacter.stats.titleRank = this._rankChanger.currentRank;
         context.saga.def.consumeTitle(this.curTitle);
         this._guiPgDetails.setGuiHeroicTitlesVisible(false);
         this._guiPgDetails.selectedCharacter = this._curCharacter;
         SagaAchievements.unlockAchievementById("acv_3_27_aka",context.saga.minutesPlayed,true);
      }
   }
}
