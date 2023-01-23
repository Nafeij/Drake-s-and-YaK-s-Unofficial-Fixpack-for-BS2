package game.gui.pages
{
   import engine.entity.def.ITitleDef;
   import engine.saga.SagaVar;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiHeroicTitles;
   import game.gui.IGuiContext;
   
   public class GuiTitleRankChanger extends GuiBase
   {
       
      
      private var _rankUp:ButtonWithIndex;
      
      private var _rankDown:ButtonWithIndex;
      
      private var _curRank:int;
      
      private var _curRankText:TextField;
      
      private var _maxRankText:TextField;
      
      private var _guiTitles:GuiHeroicTitles;
      
      private var _pendingRenownSpend:int = 0;
      
      public function GuiTitleRankChanger()
      {
         super();
      }
      
      public function init(param1:IGuiContext, param2:GuiHeroicTitles) : void
      {
         super.initGuiBase(param1);
         this._guiTitles = param2;
         this._curRankText = requireGuiChild("curRank") as TextField;
         this._maxRankText = requireGuiChild("maxRank") as TextField;
         this._rankUp = requireGuiChild("rankUp") as ButtonWithIndex;
         this._rankUp.guiButtonContext = param1;
         this._rankUp.setDownFunction(this.buttonRankUpPressed);
         this._rankDown = requireGuiChild("rankDown") as ButtonWithIndex;
         this._rankDown.guiButtonContext = param1;
         this._rankDown.clickSound = "ui_heroic_title_select";
         this._rankDown.setDownFunction(this.buttonRankDownPressed);
      }
      
      public function cleanup() : void
      {
         super.cleanupGuiBase();
         this._rankUp.cleanup();
         this._rankUp = null;
         this._rankDown.cleanup();
         this._rankDown = null;
      }
      
      public function pendingRenownSpend() : int
      {
         return this._pendingRenownSpend;
      }
      
      public function get currentRank() : int
      {
         return this._curRank;
      }
      
      public function get maxRankValue() : int
      {
         var _loc1_:ITitleDef = this._guiTitles.curTitle;
         return !!_loc1_ ? _loc1_.numRanks : -1;
      }
      
      public function get rankUpButton() : ButtonWithIndex
      {
         return this._rankUp;
      }
      
      public function get rankDownButton() : ButtonWithIndex
      {
         return this._rankDown;
      }
      
      public function localeHandler() : void
      {
         _context.locale.fixTextFieldFormat(this._curRankText);
         _context.locale.fixTextFieldFormat(this._maxRankText);
      }
      
      public function updateDisplay(param1:int) : void
      {
         var _loc2_:ITitleDef = null;
         _loc2_ = this._guiTitles.curTitle;
         this._curRank = param1;
         this._pendingRenownSpend = this.calculateRenownSpend(param1);
         if(_loc2_)
         {
            this._rankDown.visible = param1 > this._guiTitles.currentCharacter.stats.titleRank;
            this._rankUp.visible = param1 < _loc2_.numRanks;
         }
         else
         {
            this._rankDown.visible = this._rankUp.visible = false;
         }
         this._curRankText.htmlText = param1.toString();
         this._maxRankText.htmlText = !!_loc2_ ? _loc2_.numRanks.toString() : "";
      }
      
      public function buttonRankUpPressed(param1:*) : void
      {
         if(this.canPurchaseRank(this._curRank + 1))
         {
            this.updateDisplay(this._curRank + 1);
            this._guiTitles.updateTitleRankPurchase(this._curRank);
            context.playSound("ui_heroic_title_select");
         }
         else
         {
            context.playSound("ui_error");
            this._guiTitles.failUpdateTitleRankPurchase(this._curRank + 1);
         }
      }
      
      public function buttonRankDownPressed(param1:*) : void
      {
         if(this.canDecreaseRank(this._curRank - 1))
         {
            this.updateDisplay(this._curRank - 1);
            this._guiTitles.updateTitleRankPurchase(this._curRank);
         }
         else
         {
            context.playSound("ui_error");
         }
      }
      
      private function canPurchaseRank(param1:int) : Boolean
      {
         var _loc2_:int = context.saga.getVarNumber(SagaVar.VAR_RENOWN);
         var _loc3_:int = this.calculateRenownSpend(param1);
         if(_loc3_ > _loc2_)
         {
            return false;
         }
         this._pendingRenownSpend = _loc3_;
         return true;
      }
      
      private function canDecreaseRank(param1:int) : Boolean
      {
         var _loc2_:int = int(this._guiTitles.currentCharacter.stats.titleRank);
         return param1 >= _loc2_;
      }
      
      public function calculateRenownSpend(param1:int) : int
      {
         if(this._guiTitles.currentCharacter == null)
         {
            return 0;
         }
         var _loc2_:int = 0;
         var _loc3_:int = this._guiTitles.currentCharacter.stats.titleRank + 1;
         while(_loc3_ <= param1)
         {
            _loc2_ += context.statCosts.getTitleCost(_loc3_);
            _loc3_++;
         }
         return _loc2_;
      }
   }
}
