package game.gui
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.ILegend;
   import engine.entity.def.Item;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import engine.saga.Saga;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import game.gui.page.GuiRosterConfig;
   
   public class GuiRoster_Gp
   {
       
      
      private var roster:GuiRoster;
      
      private var context:IGuiContext;
      
      public var guiConfig:GuiRosterConfig;
      
      private var legend:ILegend;
      
      public var _item_slots:GuiItemSlots;
      
      private var navSelect:GuiGpNav;
      
      private var navMove:GuiGpNav;
      
      private var navGive:GuiGpNav;
      
      private var gp_y:GuiGpBitmap;
      
      private var gp_l1:GuiGpBitmap;
      
      private var gp_r1:GuiGpBitmap;
      
      private var cmd_pg_roster_items:Cmd;
      
      private var cmd_prev:Cmd;
      
      private var cmd_next:Cmd;
      
      private var gpGlobalsUpdateCallback:Function;
      
      private var unitMoving:IGuiCharacterIconSlot;
      
      private var itemGiving:GuiItemSlot;
      
      private var firstRosterSlotIndex:int = -1;
      
      public function GuiRoster_Gp()
      {
         this.cmd_pg_roster_items = new Cmd("cmd_pg_roster_items",this.cmdfunc_roster_items);
         this.cmd_prev = new Cmd("cmd_roster_prev",this.cmdfunc_prev);
         this.cmd_next = new Cmd("cmd_roster_next",this.cmdfunc_next);
         super();
      }
      
      public function init(param1:GuiRoster, param2:Function) : void
      {
         this.roster = param1;
         this.context = param1.context;
         this.guiConfig = param1.guiConfig;
         this.legend = this.context.legend;
         this._item_slots = param1._item_slots;
         this.gpGlobalsUpdateCallback = param2;
         PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.platformLastInputHandler);
         this.updateNavSelectSlots();
      }
      
      public function cleanup() : void
      {
         PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.platformLastInputHandler);
         this.visible = false;
         this.cmd_pg_roster_items.cleanup();
         this.cmd_pg_roster_items = null;
         this.cleanupNavs();
         this.gp_y = null;
      }
      
      private function stopUnitMove() : void
      {
         this.unitMoving = null;
         this.roster.clearPartyDropTargets();
         this.roster.clearRosterDropTargets();
         this._item_slots.mouseChildren = true;
         this.updateNavSelectSlots();
      }
      
      private function stopItemGive() : void
      {
         if(this.itemGiving)
         {
            this.itemGiving = null;
            this.roster.clearPartyDropTargets();
            this.roster.clearRosterDropTargets();
            this._item_slots.mouseChildren = true;
            this.updateNavSelectSlots();
         }
      }
      
      public function resetSlots() : void
      {
         if(this.itemGiving)
         {
            this.stopItemGive();
         }
         else if(this.unitMoving)
         {
            this.stopUnitMove();
         }
         else
         {
            this.updateNavSelectSlots();
         }
      }
      
      private function cmdfunc_prev(param1:CmdExec) : void
      {
         this.roster._upArrow.press();
      }
      
      private function cmdfunc_next(param1:CmdExec) : void
      {
         this.roster._downArrow.press();
      }
      
      private function cmdfunc_roster_items(param1:CmdExec) : void
      {
         if(!this._item_slots.isActivatedGp)
         {
            if(Boolean(this._item_slots.items) && Boolean(this._item_slots.items.length))
            {
               this.stopUnitMove();
               this.stopItemGive();
               this.activateItemSlotsGp();
            }
         }
         else
         {
            this._item_slots.deactivateGp();
         }
      }
      
      private function activateItemSlotsGp() : void
      {
         this._item_slots.activateGp(null);
         GpBinder.gpbinder.elevate(this.cmd_pg_roster_items);
      }
      
      public function handleGpCancel() : Boolean
      {
         if(this.navGive)
         {
            this.stopItemGive();
            this.activateItemSlotsGp();
            return true;
         }
         if(this.navMove)
         {
            this.context.playSound("ui_dismiss");
            this.roster.clearPartyDropTargets();
            this.roster.clearRosterDropTargets();
            this._item_slots.mouseChildren = true;
            this.updateNavSelectSlots();
            return true;
         }
         if(this._item_slots.isActivatedGp)
         {
            this._item_slots.deactivateGp();
            return true;
         }
         return false;
      }
      
      private function navSelectClickAlternateHandler(param1:DisplayObject) : void
      {
         var _loc3_:IEntityDef = null;
         var _loc4_:GuiIcon = null;
         var _loc2_:IGuiCharacterIconSlot = param1 as IGuiCharacterIconSlot;
         if(_loc2_)
         {
            this.unitMoving = _loc2_;
            _loc3_ = this.roster.startUnitMove(_loc2_);
            this.updateNavMoveSlots();
            _loc4_ = this.context.getEntityIcon(_loc3_,EntityIconType.PARTY);
            if(this.navMove)
            {
               this.navMove.setDecoration(_loc4_,1);
            }
         }
      }
      
      private function navMoveClickAlternateHandler(param1:DisplayObject) : void
      {
         if(Boolean(this.unitMoving) && Boolean(this.unitMoving.character))
         {
            this.context.playSound("ui_dismiss");
            if(!this.roster.removePartyCharacter(this.unitMoving.character))
            {
               return;
            }
         }
         this.stopUnitMove();
      }
      
      private function navMoveClickControlHandler(param1:DisplayObject, param2:Boolean) : Boolean
      {
         var _loc4_:IEntityDef = null;
         var _loc5_:Saga = null;
         var _loc6_:Boolean = false;
         if(!this.context)
         {
            return false;
         }
         var _loc3_:IGuiCharacterIconSlot = param1 as IGuiCharacterIconSlot;
         if(Boolean(_loc3_) && Boolean(this.unitMoving) && Boolean(this.unitMoving.character))
         {
            _loc4_ = this.unitMoving.character;
            _loc5_ = this.context.saga;
            if(_loc5_)
            {
               if(_loc5_.isSurvival)
               {
                  if(_loc4_.isSurvivalDead || !_loc4_.isSurvivalRecruited)
                  {
                     this.context.playSound("ui_error");
                     return true;
                  }
               }
            }
            if(this.unitMoving.character == _loc3_.character)
            {
               this.context.playSound("ui_dismiss");
            }
            else
            {
               _loc6_ = this.legend.party.hasMemberId(this.unitMoving.character.id);
               if(!this.roster.addPartyCharacter(this.unitMoving.character,_loc3_.character))
               {
                  return true;
               }
               if(!_loc6_)
               {
                  this.roster.updateLimitCount(this.unitMoving.character);
               }
               this.context.playSound("ui_attack_button");
            }
            this.stopUnitMove();
            return true;
         }
         return false;
      }
      
      private function updateNavMoveSlots() : void
      {
         var _loc3_:GuiCharacterIconSlot = null;
         var _loc4_:Boolean = false;
         var _loc5_:* = false;
         if(!this.unitMoving || !this.unitMoving.character)
         {
            return;
         }
         var _loc1_:GuiCharacterIconSlot = this.cleanupNavs();
         this.navMove = new GuiGpNav(this.context,"roster_move",this.roster);
         this.navMove.alwaysHintControls = true;
         this.navMove.setCallbackPress(this.navMoveClickControlHandler);
         this.navMove.setAlternateButton(GpControlButton.X,this.navMoveClickAlternateHandler);
         this.navMove.setAlignNavDefault(GuiGpAlignH.C,GuiGpAlignV.N_DOWN);
         this.navMove.setAlignControlDefault(GuiGpAlignH.C,GuiGpAlignV.N);
         this.navMove.scale = 1.5;
         var _loc2_:int = 0;
         while(_loc2_ < this.roster.partyRow.numSlots)
         {
            _loc3_ = this.roster.partyRow.getGuiCharacterIconSlot(_loc2_) as GuiCharacterIconSlot;
            if(_loc3_.dropglowVisible)
            {
               if(Boolean(_loc1_) && _loc1_.character == _loc3_.character)
               {
                  _loc1_ = _loc3_;
               }
               _loc4_ = this.legend.party.hasMemberId(this.unitMoving.character.id);
               _loc5_ = _loc3_ != this.unitMoving;
               this.navMove.add(_loc3_ as DisplayObject,_loc4_,_loc5_);
               if(!_loc3_.character)
               {
                  this.navMove.setCaptionTokenControl(_loc3_,"pg_roster_add");
               }
               else if(this.legend.party.numMembers == 6)
               {
                  this.navMove.setCaptionTokenControl(_loc3_,"pg_roster_swap");
               }
               else
               {
                  this.navMove.setCaptionTokenControl(_loc3_,"pg_roster_insert");
               }
               this.navMove.setCaptionTokenAlt(_loc3_,"pg_roster_remove");
            }
            _loc2_++;
         }
         if(Boolean(_loc1_) && this.navMove.canSelect(_loc1_))
         {
            this.navMove.selected = _loc1_;
         }
         else
         {
            this.navMove.autoSelect();
         }
         if(this.roster.visible)
         {
            this.navMove.activate();
         }
      }
      
      private function navGiveClickControlHandler(param1:DisplayObject, param2:Boolean) : Boolean
      {
         var _loc3_:GuiCharacterIconSlot = param1 as GuiCharacterIconSlot;
         if(_loc3_ && this.itemGiving && Boolean(this.itemGiving.item))
         {
            this.roster.onGuiItemDrop(_loc3_,this.itemGiving);
            this.stopItemGive();
            this.activateItemSlotsGp();
            return true;
         }
         return false;
      }
      
      private function cleanupNavs() : GuiCharacterIconSlot
      {
         var _loc1_:GuiCharacterIconSlot = null;
         if(this.navSelect)
         {
            _loc1_ = this.navSelect.selected as GuiCharacterIconSlot;
            this.navSelect.cleanup();
            this.navSelect = null;
         }
         if(this.navMove)
         {
            _loc1_ = !!_loc1_ ? _loc1_ : this.navMove.selected as GuiCharacterIconSlot;
            this.navMove.cleanup();
            this.navMove = null;
         }
         if(this.navGive)
         {
            _loc1_ = !!_loc1_ ? _loc1_ : this.navGive.selected as GuiCharacterIconSlot;
            this.navGive.cleanup();
            this.navGive = null;
         }
         return _loc1_;
      }
      
      private function addNavGiveSlot(param1:GuiCharacterIconSlot, param2:GuiCharacterIconSlot) : GuiCharacterIconSlot
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         if(Boolean(param1.character) && param1.dropglowVisible)
         {
            if(Boolean(param2) && param2.character == param1.character)
            {
               param2 = param1;
            }
            _loc3_ = false;
            _loc4_ = true;
            this.navGive.add(param1 as DisplayObject,_loc3_,_loc4_);
            if(param1.character.defItem != null)
            {
               this.navGive.setCaptionTokenControl(param1,"pg_item_swap");
            }
            else
            {
               this.navGive.setCaptionTokenControl(param1,"pg_item_give");
            }
         }
         return param2;
      }
      
      private function updateNavGiveSlots() : void
      {
         var _loc4_:GuiCharacterIconSlot = null;
         var _loc5_:GuiCharacterIconSlots = null;
         if(!this.itemGiving || !this.itemGiving.item)
         {
            return;
         }
         var _loc1_:GuiCharacterIconSlot = this.cleanupNavs();
         this.navGive = new GuiGpNav(this.context,"roster_give",this.roster);
         this.navGive.alwaysHintControls = true;
         this.navGive.setCallbackPress(this.navGiveClickControlHandler);
         this.navGive.setAlternateButton(GpControlButton.X,null);
         this.navGive.setAlignControlDefault(GuiGpAlignH.C,GuiGpAlignV.N_DOWN);
         this.navGive.setAlignNavDefault(GuiGpAlignH.C,GuiGpAlignV.S_UP);
         this.navGive.scale = 1.5;
         var _loc2_:int = 0;
         while(_loc2_ < this.roster.partyRow.numSlots)
         {
            _loc4_ = this.roster.partyRow.getGuiCharacterIconSlot(_loc2_) as GuiCharacterIconSlot;
            _loc1_ = this.addNavGiveSlot(_loc4_,_loc1_);
            _loc2_++;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.roster.rosterRows)
         {
            _loc5_ = this.roster.getRosterRow(_loc3_);
            _loc2_ = 0;
            while(_loc2_ < _loc5_.numSlots)
            {
               _loc4_ = _loc5_.getGuiCharacterIconSlot(_loc2_) as GuiCharacterIconSlot;
               _loc1_ = this.addNavGiveSlot(_loc4_,_loc1_);
               this.navGive.setDecorationScale(_loc4_,0.75);
               _loc2_++;
            }
            _loc3_++;
         }
         if(Boolean(_loc1_) && this.navGive.canSelect(_loc1_))
         {
            this.navGive.selected = _loc1_;
         }
         else
         {
            this.navGive.autoSelect();
         }
         if(this.roster.visible)
         {
            this.navGive.activate();
         }
      }
      
      private function updateNavSelectSlots() : void
      {
         var _loc5_:IGuiCharacterIconSlot = null;
         var _loc6_:GuiCharacterIconSlots = null;
         var _loc7_:IEntityDef = null;
         if(!this.context)
         {
            return;
         }
         var _loc1_:GuiCharacterIconSlot = this.cleanupNavs();
         this.navSelect = new GuiGpNav(this.context,"roster_sel",this.roster.parent);
         this.navSelect.alwaysHintControls = true;
         this.navSelect.setAlternateButton(GpControlButton.X,this.navSelectClickAlternateHandler);
         this.navSelect.setAlignNavDefault(GuiGpAlignH.C,GuiGpAlignV.N_DOWN);
         this.navSelect.setAlignControlDefault(GuiGpAlignH.C,GuiGpAlignV.N);
         this.navSelect.setCallbackNavigate(this.navSelectNavigateHandler);
         this.navSelect.scale = 1.5;
         if(this.roster.button_ready)
         {
            this.navSelect.add(this.roster.button_ready,false,true);
            this.navSelect.setAlignControl(this.roster.button_ready,GuiGpAlignH.E,GuiGpAlignV.C);
            this.navSelect.setAlignNav(this.roster.button_ready,GuiGpAlignH.C,GuiGpAlignV.S);
            this.navSelect.setCaptionTokenControl(this.roster.button_ready,"pg_ready");
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.roster.partyRow.numSlots)
         {
            _loc5_ = this.roster.partyRow.getGuiCharacterIconSlot(_loc2_);
            if(_loc5_.character)
            {
               this.navSelect.add(_loc5_ as DisplayObject,true,true);
               this.navSelect.setCaptionTokenControl(_loc5_ as DisplayObject,"pg_roster_view");
               this.navSelect.setCaptionTokenAlt(_loc5_ as DisplayObject,"pg_roster_move");
               this.navSelect.setAlignControl(_loc5_,GuiGpAlignH.W,GuiGpAlignV.C);
            }
            _loc2_++;
         }
         var _loc3_:Saga = this.context.saga;
         var _loc4_:int = 0;
         while(_loc4_ < this.roster.rosterRows)
         {
            _loc6_ = this.roster.getRosterRow(_loc4_);
            _loc2_ = 0;
            while(_loc2_ < _loc6_.numSlots)
            {
               _loc5_ = _loc6_.getGuiCharacterIconSlot(_loc2_);
               _loc7_ = _loc5_.character;
               if(_loc7_)
               {
                  this.navSelect.add(_loc5_ as DisplayObject,true,true);
                  this.navSelect.setCaptionTokenControl(_loc5_,"pg_roster_view");
                  this.navSelect.setCaptionTokenAlt(_loc5_,"pg_roster_move");
                  this.navSelect.setAlignControl(_loc5_,GuiGpAlignH.W,GuiGpAlignV.C);
                  this.navSelect.setShowAlt(_loc5_,true);
                  if(Boolean(_loc3_) && _loc3_.isSurvival)
                  {
                     if(_loc7_.isSurvivalDead || !_loc7_.isSurvivalRecruited)
                     {
                        this.navSelect.setShowAlt(_loc5_,false);
                     }
                  }
                  if(this.firstRosterSlotIndex == -1)
                  {
                     this.firstRosterSlotIndex = this.navSelect.getIndexOfObject(_loc5_);
                  }
               }
               _loc2_++;
            }
            _loc4_++;
         }
         if(Boolean(_loc1_) && this.navSelect.canSelect(_loc1_))
         {
            this.navSelect.selected = _loc1_;
         }
         else
         {
            this.navSelect.autoSelect();
         }
         if(this.roster.visible)
         {
            this.navSelect.activate();
         }
      }
      
      private function navSelectNavigateHandler(param1:int, param2:int, param3:Boolean) : Boolean
      {
         if(!this.roster || !this.roster._chitGroup)
         {
            return false;
         }
         if(this.firstRosterSlotIndex > -1)
         {
            param2 -= this.firstRosterSlotIndex;
         }
         var _loc4_:int = param2 / this.context.statCosts.roster_slots_per_row;
         if(param1 == 2)
         {
            if(_loc4_ == this.roster.rosterRows - 1)
            {
               if(this.roster._chitGroup.activeChitIndex < this.roster._chitGroup.numVisibleChits - 1)
               {
                  if(Boolean(this.gp_r1) && Boolean(this.roster._downArrow))
                  {
                     this.gp_r1.pulse();
                     this.roster._downArrow.press();
                     return true;
                  }
               }
            }
         }
         else if(param1 == 0)
         {
            if(_loc4_ == 0)
            {
               if(this.roster._chitGroup.activeChitIndex > 0)
               {
                  if(Boolean(this.gp_l1) && Boolean(this.roster._upArrow))
                  {
                     this.gp_l1.pulse();
                     this.roster._upArrow.press();
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      private function activateNav() : void
      {
         if(this.navSelect)
         {
            this.navSelect.activate();
         }
         if(this.navMove)
         {
            this.navMove.activate();
         }
         if(this.navGive)
         {
            this.navGive.activate();
         }
      }
      
      private function deactivateNav() : void
      {
         if(this.navSelect)
         {
            this.navSelect.deactivate();
         }
         if(this.navMove)
         {
            this.navMove.deactivate();
         }
         if(this.navGive)
         {
            this.navGive.deactivate();
         }
      }
      
      public function set visible(param1:Boolean) : void
      {
         if(param1)
         {
            if(this.gp_y)
            {
               return;
            }
            if(this.roster._upArrow)
            {
               this.gp_l1 = GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_prev,null,true).gpbmp;
               this.gp_l1.alwaysHint = true;
               this.gp_l1.scale = 1.5;
               this.roster.addChild(this.gp_l1);
               GuiGp.placeIcon(this.roster._upArrow,null,this.gp_l1,GuiGpAlignH.C,GuiGpAlignV.S);
            }
            if(this.roster._downArrow)
            {
               this.gp_r1 = GpBinder.gpbinder.bindPress(GpControlButton.R1,this.cmd_next,null,true).gpbmp;
               this.gp_r1.alwaysHint = true;
               this.gp_r1.scale = 1.5;
               this.roster.addChild(this.gp_r1);
               GuiGp.placeIcon(this.roster._downArrow,null,this.gp_r1,GuiGpAlignH.C,GuiGpAlignV.N);
            }
            this.gp_y = GpBinder.gpbinder.bindPress(GpControlButton.Y,this.cmd_pg_roster_items,null,true).gpbmp;
            this.gp_y.alwaysHint = true;
            this.gp_y.scale = 1.5;
            this.gp_y.visible = Boolean(this._item_slots.items) && Boolean(this._item_slots.items.length);
            this.roster.addChild(this.gp_y);
            GuiGp.placeIcon(this._item_slots._$items,null,this.gp_y,GuiGpAlignH.C,GuiGpAlignV.S_DOWN);
            if(!this._item_slots || !this._item_slots.isActivatedGp)
            {
               this.activateNav();
            }
         }
         else
         {
            GpBinder.gpbinder.unbind(this.cmd_pg_roster_items);
            GpBinder.gpbinder.unbind(this.cmd_prev);
            GpBinder.gpbinder.unbind(this.cmd_next);
            this.gp_y = null;
            this.gp_r1 = null;
            this.gp_l1 = null;
            this.deactivateNav();
         }
      }
      
      public function itemSlotsRemoveHandler(param1:GuiItemSlot) : void
      {
         if(!param1 || !param1.item || !param1.item.owner)
         {
            return;
         }
         this.context.playSound("ui_stats_wipes_minor");
         var _loc2_:Item = param1.item;
         var _loc3_:IEntityDef = _loc2_.owner;
         _loc2_.owner = null;
         _loc3_.defItem = null;
         this.context.legend.items.addItem(_loc2_);
      }
      
      public function itemSlotsGiveHandler(param1:GuiItemSlot) : void
      {
         if(!param1 || !param1.item)
         {
            return;
         }
         this.itemGiving = param1;
         this.roster.startItemGive(param1);
         this.updateNavGiveSlots();
         var _loc2_:GuiIcon = this.context.getIcon(param1.item.def.icon);
         if(Boolean(this.navGive) && this.navGive.selected != null)
         {
            this.navGive.setDecoration(_loc2_,1);
         }
      }
      
      public function itemSlotsActivationHandler() : void
      {
         if(!this._item_slots)
         {
            return;
         }
         if(!this._item_slots.isActivatedGp)
         {
            this.activateNav();
         }
         else
         {
            this.deactivateNav();
         }
         if(this.gpGlobalsUpdateCallback != null)
         {
            this.gpGlobalsUpdateCallback();
         }
      }
      
      private function platformLastInputHandler(param1:Event) : void
      {
         if(!PlatformInput.lastInputGp)
         {
            if(this.unitMoving)
            {
               this.stopUnitMove();
            }
            else if(this.itemGiving)
            {
               this.stopItemGive();
            }
         }
         this.visible = this.roster.visible && PlatformInput.lastInputGp;
      }
   }
}
