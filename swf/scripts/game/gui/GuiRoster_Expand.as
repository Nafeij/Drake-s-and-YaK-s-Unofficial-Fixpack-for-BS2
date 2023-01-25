package game.gui
{
   import com.greensock.TweenMax;
   import engine.core.http.HttpAction;
   import engine.entity.def.ILegend;
   import engine.gui.GuiButtonState;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.battle.GuiRenownConfirmDialog;
   import game.gui.page.GuiRosterConfig;
   
   public class GuiRoster_Expand
   {
       
      
      private var expandBarracks:MovieClip;
      
      private var expandBarracksButton:ButtonWithIndex;
      
      private var expandBarracksRenownCost:TextField;
      
      private var roster:GuiRoster;
      
      private var context:IGuiContext;
      
      public var guiConfig:GuiRosterConfig;
      
      private var legend:ILegend;
      
      private var guiRenownConfirmDialog:GuiRenownConfirmDialog;
      
      private var unlockingDialog:IGuiDialog;
      
      public function GuiRoster_Expand()
      {
         this.guiRenownConfirmDialog = new GuiRenownConfirmDialog();
         super();
      }
      
      public function cleanup() : void
      {
         if(this.expandBarracks)
         {
            this.expandBarracks = null;
         }
         if(this.expandBarracksButton)
         {
            this.expandBarracksButton.cleanup();
            this.expandBarracksButton = null;
         }
         if(this.guiRenownConfirmDialog)
         {
            this.guiRenownConfirmDialog.cleanup();
            this.guiRenownConfirmDialog = null;
         }
         this.roster = null;
         this.context = null;
         this.guiConfig = null;
         this.legend = null;
      }
      
      public function init(param1:GuiRoster) : void
      {
         this.roster = param1;
         this.context = param1.context;
         this.guiConfig = param1.guiConfig;
         this.legend = this.context.legend;
         this.expandBarracks = param1.getChildByName("expandBarracks") as MovieClip;
         if(!this.guiConfig.allowExpandBarracks)
         {
            this.expandBarracks.stop();
            this.expandBarracks.visible = false;
            this.expandBarracks = null;
         }
         else
         {
            this.expandBarracksButton = this.expandBarracks.getChildByName("expandBarracksButton") as ButtonWithIndex;
            this.expandBarracksButton.setDownFunction(this.onExpandBarracksClick);
            this.expandBarracks.alpha = 0;
            this.expandBarracksRenownCost = this.expandBarracks.getChildByName("renownCostText") as TextField;
            this.expandBarracksRenownCost.text = this.context.statCosts.roster_row_cost.toString();
            this.expandBarracks.visible = false;
         }
         this.guiRenownConfirmDialog.init(this.context);
      }
      
      private function onExpandBarracksClick(param1:ButtonWithIndex) : void
      {
         var _loc2_:String = null;
         if(this.guiConfig.disabled)
         {
            return;
         }
         if(this.legend.renown < this.context.statCosts.roster_row_cost)
         {
            this.context.playSound("ui_players_turn");
            this.roster.renownButton.setStateForCertainTimeframe(GuiButtonState.HOVER,20);
         }
         else
         {
            _loc2_ = String(this.context.translate("renown_confirm_body_expand_roster"));
            _loc2_ = _loc2_.replace("$RENOWN",this.context.statCosts.roster_row_cost.toString());
            this.guiRenownConfirmDialog.display("renown_confirm_title_expand_roster",_loc2_,this.confirmRenownPurchase);
         }
      }
      
      private function onRosterRowDoneUnlocking(param1:HttpAction) : void
      {
         var _loc2_:GuiChitsGroup = this.roster._chitGroup;
         if(_loc2_)
         {
            if(this.legend.rosterRowCount >= 4)
            {
               this.roster._chitGroup.numVisibleChits += 1;
            }
            this.roster.fillRows(this.context.statCosts.roster_slots_per_row * _loc2_.activeChitIndex,1);
         }
         if(this.unlockingDialog)
         {
            this.unlockingDialog.closeDialog(null);
         }
      }
      
      private function confirmRenownPurchase(param1:String) : void
      {
         if(param1 != "Confirm")
         {
            return;
         }
         if(this.unlockingDialog)
         {
            this.unlockingDialog.closeDialog(null);
         }
         this.unlockingDialog = this.context.createDialog();
         var _loc2_:String = String(this.context.translate("pg_expanding_barracks_title"));
         var _loc3_:String = String(this.context.translate("pg_expanding_barracks_body"));
         this.unlockingDialog.openDialog(_loc2_,_loc3_,null,null);
         this.legend.unlockRosterRow(this.onRosterRowDoneUnlocking);
      }
      
      public function fillExpandableRows(param1:int, param2:int) : void
      {
         var _loc5_:GuiCharacterIconSlots = null;
         var _loc6_:int = 0;
         if(!this.legend)
         {
            return;
         }
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         while(_loc4_ < this.roster.rosterRows)
         {
            _loc5_ = this.roster.getRosterRow(_loc4_);
            _loc5_.clearAllGuiCharacterIconSlots();
            _loc6_ = param1 + _loc4_;
            if(_loc6_ == this.legend.rosterRowCount && _loc6_ + 1 < this.context.statCosts.max_num_roster_rows)
            {
               _loc3_ = true;
               if(this.expandBarracks)
               {
                  this.expandBarracks.y = _loc5_.y - this.expandBarracks.height * 0.51;
               }
               _loc5_.collapse();
            }
            else if(_loc6_ > this.legend.rosterRowCount)
            {
               _loc5_.visible = false;
            }
            else
            {
               _loc5_.visible = true;
               _loc5_.expand(param2);
               this.roster.fillRow(_loc5_,false);
            }
            _loc4_++;
         }
         this.expandBarracksVisible(_loc3_);
      }
      
      private function expandBarracksVisible(param1:Boolean) : void
      {
         var visible:Boolean = param1;
         if(!this.expandBarracks)
         {
            return;
         }
         if(visible)
         {
            this.expandBarracks.visible = true;
            this.expandBarracks.alpha = 0;
            TweenMax.to(this.expandBarracks,0.5,{"alpha":1});
         }
         else
         {
            TweenMax.to(this.expandBarracks,0.2,{
               "alpha":0,
               "onComplete":function hide():void
               {
                  if(expandBarracks)
                  {
                     expandBarracks.visible = false;
                  }
               }
            });
         }
      }
   }
}
