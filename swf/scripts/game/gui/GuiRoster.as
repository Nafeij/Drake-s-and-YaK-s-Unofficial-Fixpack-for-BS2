package game.gui
{
   import com.greensock.TweenMax;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.locale.LocaleCategory;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ILegend;
   import engine.entity.def.Item;
   import engine.saga.Saga;
   import engine.stat.def.StatType;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import game.gui.page.GuiRosterConfig;
   import game.gui.page.IGuiRoster;
   
   public class GuiRoster extends GuiBase implements IGuiRoster
   {
       
      
      public const rosterRows:int = 3;
      
      private var rosterIndex:int = 0;
      
      private var numberOfCharacterIcons:int = 6;
      
      private var selectedCharacter:IEntityDef;
      
      public var partyRow:GuiCharacterIconSlots;
      
      public var partyPointTotal:TextField;
      
      private var top_banner:MovieClip;
      
      private var limits_display:MovieClip;
      
      private var textPartyLimitCount:TextField;
      
      private var textPartyLimitTotal:TextField;
      
      private var textPartyLimitName:TextField;
      
      public var _item_slots:GuiItemSlots;
      
      public var _labelOrder:MovieClip;
      
      public var _labelRoster:MovieClip;
      
      public var _labelParty:MovieClip;
      
      private var partyLimitNameDict:Dictionary;
      
      public var _upArrow:ButtonWithIndex;
      
      public var _downArrow:ButtonWithIndex;
      
      private var readyPanel:MovieClip;
      
      private var button$ready_for_battle:ButtonWithIndex;
      
      private var button$ready_for_survival:ButtonWithIndex;
      
      public var button_ready:ButtonWithIndex;
      
      public var _chitGroup:GuiChitsGroup;
      
      private var iconSlotByEntityDefDict:Dictionary;
      
      public var renownButton:MovieClip;
      
      public var guiConfig:GuiRosterConfig;
      
      private var roster:IEntityListDef;
      
      private var _gp:GuiRoster_Gp;
      
      private var _expand:GuiRoster_Expand;
      
      private var _animator_in:GuiRoster_Animator_In;
      
      private var _animator_out:GuiRoster_Animator_Out;
      
      private var legend:ILegend;
      
      private var powerDisplay:MovieClip;
      
      private var _tooltip_id:int;
      
      private var _itemDragging:GuiItemSlot;
      
      private var _lastItemDropOk:GuiItemSlot;
      
      private var _draggedUnit:GuiCharacterIconSlot;
      
      private var _survivalAnimatedIn:Boolean;
      
      public function GuiRoster()
      {
         this.iconSlotByEntityDefDict = new Dictionary();
         this._gp = new GuiRoster_Gp();
         this._expand = new GuiRoster_Expand();
         super();
         this.partyLimitNameDict = new Dictionary();
         this._item_slots = getChildByName("item_slots") as GuiItemSlots;
         this._labelOrder = getChildByName("labelOrder") as MovieClip;
         this._labelRoster = getChildByName("labelRoster") as MovieClip;
         this._labelParty = getChildByName("labelParty") as MovieClip;
      }
      
      private static function updateItemDropTargets(param1:GuiCharacterIconSlots, param2:Item) : void
      {
         var _loc5_:GuiCharacterIconSlot = null;
         var _loc6_:IEntityDef = null;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc3_:int = param2.def.rank;
         var _loc4_:int = 0;
         while(_loc4_ < param1.numSlots)
         {
            _loc5_ = param1.getGuiCharacterIconSlot(_loc4_) as GuiCharacterIconSlot;
            _loc6_ = _loc5_.character;
            _loc7_ = false;
            if(_loc5_.iconEnabled)
            {
               if(_loc6_)
               {
                  if(_loc6_.defItem != param2)
                  {
                     _loc8_ = int(_loc6_.stats.getValue(StatType.RANK));
                     if(_loc8_ > _loc3_)
                     {
                        _loc7_ = true;
                     }
                  }
               }
            }
            _loc5_.dropglowVisible = _loc7_;
            _loc5_.mouseEnabled = _loc7_;
            _loc4_++;
         }
      }
      
      private static function updateRowDropTargetsMouseEnabled(param1:GuiCharacterIconSlots, param2:Boolean) : void
      {
         var _loc4_:GuiCharacterIconSlot = null;
         var _loc3_:int = 0;
         while(_loc3_ < param1.numSlots)
         {
            _loc4_ = param1.getGuiCharacterIconSlot(_loc3_) as GuiCharacterIconSlot;
            _loc4_.dropglowVisible = false;
            _loc4_.mouseEnabled = param2;
            _loc3_++;
         }
      }
      
      public function cleanup() : void
      {
         var _loc2_:GuiCharacterIconSlots = null;
         this.visible = false;
         this.killRosterTweens();
         if(this._animator_in)
         {
            this._animator_in.cleanup();
            this._animator_in = null;
         }
         if(this._animator_out)
         {
            this._animator_out.cleanup();
            this._animator_out = null;
         }
         this._expand.cleanup();
         this._expand = null;
         this._gp.cleanup();
         this._gp = null;
         if(this._itemDragging)
         {
            this._itemDragging.cancelDrag();
            this._itemDragging = null;
         }
         this._item_slots.removeIconEventListener(GuiIconSlotEvent.DRAG_START,this.onGuiItemIconDragStart);
         this._item_slots.removeIconEventListener(GuiIconSlotEvent.DRAG_END,this.onGuiItemIconDragEnd);
         this.guiConfig.removeEventListener(GuiRosterConfig.EVENT_CHANGED,this.configHandler);
         this.guiConfig = null;
         this.roster.removeEventListener(Event.CHANGE,this.rosterChangeHandler);
         this.roster = null;
         this.partyRow.removeIconEventListener(GuiIconSlotEvent.DROP,this.onGuiIconDrop);
         this.partyRow.removeIconEventListener(GuiIconSlotEvent.DRAG_START,this.onGuiCharacterIconMove);
         this.partyRow.removeIconEventListener(GuiIconSlotEvent.DRAG_END,this.onGuiCharacterIconMoveEnd);
         this.partyRow.removeIconEventListener(GuiIconSlotEvent.CLICKED,this.onGuiIconClicked);
         var _loc1_:int = 0;
         while(_loc1_ < this.rosterRows)
         {
            _loc2_ = this.getRosterRow(_loc1_);
            _loc2_.clearAllGuiCharacterIconSlots();
            _loc2_.removeIconEventListener(GuiIconSlotEvent.DROP,this.onGuiIconDrop);
            _loc2_.removeIconEventListener(GuiIconSlotEvent.DRAG_START,this.onGuiCharacterIconMove);
            _loc2_.removeIconEventListener(GuiIconSlotEvent.DRAG_END,this.onGuiCharacterIconMoveEnd);
            _loc2_.removeIconEventListener(GuiIconSlotEvent.CLICKED,this.onGuiIconClicked);
            _loc2_.cleanup();
            _loc1_++;
         }
         this.partyRow.cleanup();
         this.partyRow = null;
         if(this.button$ready_for_battle)
         {
            this.button$ready_for_battle.cleanup();
            this.button$ready_for_battle = null;
         }
         if(this.button$ready_for_survival)
         {
            this.button$ready_for_survival.cleanup();
            this.button$ready_for_survival = null;
         }
         if(this.readyPanel)
         {
            this.readyPanel = null;
         }
         if(this._upArrow)
         {
            this._upArrow.cleanup();
            this._upArrow = null;
         }
         if(this._downArrow)
         {
            this._downArrow.cleanup();
            this._downArrow = null;
         }
         if(this._item_slots)
         {
            this._item_slots.cleanup();
         }
         this._chitGroup = null;
         this.roster = null;
         this.partyRow = null;
         this.legend = null;
         while(numChildren > 0)
         {
            removeChildAt(numChildren - 1);
         }
      }
      
      public function init(param1:IGuiContext, param2:GuiRosterConfig, param3:MovieClip, param4:MovieClip, param5:Function) : void
      {
         var _loc7_:GuiCharacterIconSlots = null;
         var _loc8_:String = null;
         super.initGuiBase(param1);
         this.guiConfig = param2;
         this.legend = param1.legend;
         this._item_slots.init(param1,this.itemSlotsActivationHandler,this.itemSlotsGiveHandler,this.itemSlotsRemoveHandler);
         this._item_slots.visible = param2.enableItems;
         this._item_slots.addIconEventListener(GuiIconSlotEvent.DRAG_START,this.onGuiItemIconDragStart);
         this._item_slots.addIconEventListener(GuiIconSlotEvent.DRAG_END,this.onGuiItemIconDragEnd);
         this.partyRow = getChildByName("iconRowParty") as GuiCharacterIconSlots;
         this.partyRow.statsTooltips = true;
         this.partyRow.init(param1);
         this.partyRow.addIconEventListener(GuiIconSlotEvent.DROP,this.onGuiIconDrop);
         this.partyRow.addIconEventListener(GuiIconSlotEvent.DRAG_START,this.onGuiCharacterIconMove);
         this.partyRow.addIconEventListener(GuiIconSlotEvent.DRAG_END,this.onGuiCharacterIconMoveEnd);
         this.partyRow.addIconEventListener(GuiIconSlotEvent.CLICKED,this.onGuiIconClicked);
         this._labelOrder = getChildByName("labelOrder") as MovieClip;
         this._labelRoster = getChildByName("labelRoster") as MovieClip;
         this._labelParty = getChildByName("labelParty") as MovieClip;
         this.limits_display = getChildByName("limits_display") as MovieClip;
         this.textPartyLimitName = this.limits_display.getChildByName("text$limits") as TextField;
         this.textPartyLimitCount = this.limits_display.getChildByName("textPartyLimitCount") as TextField;
         this.textPartyLimitTotal = this.limits_display.getChildByName("textPartyLimitTotal") as TextField;
         this.limits_display.visible = param2.showLimits;
         registerScalableTextfield(this.textPartyLimitName);
         registerScalableTextfield(this._labelOrder.getChildByName("text$turn_order") as TextField);
         registerScalableTextfield(this._labelRoster.getChildByName("text$roster") as TextField);
         registerScalableTextfield(this._labelParty.getChildByName("text$party") as TextField);
         this._labelParty.visible = !this.limits_display.visible;
         this.powerDisplay = getChildByName("powerDisplay") as MovieClip;
         this.partyPointTotal = this.powerDisplay.getChildByName("textPartyPointTotal") as TextField;
         this.partyPointTotal.text = "0";
         this.powerDisplay.visible = param2.showPower;
         this._labelOrder.visible = !this.powerDisplay.visible;
         this.updateParty();
         this._upArrow = getChildByName("upArrow") as ButtonWithIndex;
         this._downArrow = getChildByName("downArrow") as ButtonWithIndex;
         this._chitGroup = getChildByName("chitGroup") as GuiChitsGroup;
         if(!param2.allowScrolling)
         {
            this._upArrow.stop();
            this._downArrow.stop();
            this._chitGroup.stop();
            this._upArrow.visible = false;
            this._downArrow.visible = false;
            this._chitGroup.visible = false;
            this._upArrow = null;
            this._downArrow = null;
            this._chitGroup = null;
         }
         else
         {
            this._upArrow.guiButtonContext = _context;
            this._downArrow.guiButtonContext = _context;
            this._upArrow.setDownFunction(this.on_upArrow);
            this._downArrow.setDownFunction(this.on_downArrow);
            this._chitGroup.init(param1);
            this._chitGroup.numVisibleChits = Math.max(this.legend.rosterRowCount - 2,1);
            this._chitGroup.activeChitIndex = 0;
         }
         this.readyPanel = param4;
         if(!param2.allowReady)
         {
            param4.stop();
            param4.visible = false;
            param4 = null;
            if(param3)
            {
               param3.visible = true;
            }
         }
         else
         {
            if(param3)
            {
               param3.visible = false;
            }
            this.button$ready_for_survival = param4.getChildByName("button$ready_for_survival") as ButtonWithIndex;
            this.button$ready_for_battle = param4.getChildByName("button$ready_for_battle") as ButtonWithIndex;
            this.button$ready_for_battle.visible = false;
            this.button$ready_for_survival.visible = false;
            if(_context.saga.isSurvivalSettingUp)
            {
               this.button_ready = this.button$ready_for_survival;
            }
            else
            {
               this.button_ready = this.button$ready_for_battle;
            }
            this.button_ready.visible = true;
            this.button_ready.guiButtonContext = param1;
            this.button_ready.setDownFunction(this.button$readyClick);
         }
         var _loc6_:int = 0;
         while(_loc6_ < this.rosterRows)
         {
            _loc7_ = this.getRosterRow(_loc6_);
            _loc7_.statsTooltips = true;
            _loc7_.init(param1);
            _loc6_++;
         }
         if(this.legend)
         {
            this.roster = this.legend.roster;
            this.roster.addEventListener(Event.CHANGE,this.rosterChangeHandler);
         }
         else
         {
            param1.logger.error("GuiRoster no legend available");
         }
         this.renownButton = param3;
         this.fillRows(0);
         param2.addEventListener(GuiRosterConfig.EVENT_CHANGED,this.configHandler);
         this.fillItemSlots();
         if(param2.showTutorialDetails)
         {
            _loc8_ = String(param1.translateCategory("tut_heroes_details",LocaleCategory.TUTORIAL));
            this._tooltip_id = param1.createTutorialPopup(this.partyRow,_loc8_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,true,false,null);
         }
         this._expand.init(this);
         this._gp.init(this,param5);
         this.visible = true;
      }
      
      private function fillItemSlots() : void
      {
         if(!this.legend)
         {
            return;
         }
         var _loc1_:Vector.<Item> = this.legend.getAllSortedItems(null);
         this._item_slots.setItems(_loc1_,1000);
      }
      
      private function configHandler(param1:Event) : void
      {
         this.fillRows(0);
         this.updateParty();
      }
      
      private function rosterChangeHandler(param1:Event) : void
      {
         if(!this.partyRow)
         {
            return;
         }
         this.fillRows(0);
      }
      
      public function fillRows(param1:int, param2:int = 0) : void
      {
         this.rosterIndex = param1;
         var _loc3_:int = 0;
         if(this._chitGroup)
         {
            this._chitGroup.activeChitIndex = this.rosterIndex / context.statCosts.roster_slots_per_row;
            _loc3_ = this._chitGroup.activeChitIndex;
         }
         if(this.guiConfig.allowReady || this.guiConfig.croppedRows)
         {
            this.fillCroppedRows(_loc3_);
            if(this._gp)
            {
               this._gp.resetSlots();
            }
            return;
         }
         this._expand.fillExpandableRows(_loc3_,param2);
      }
      
      public function getRosterRow(param1:int) : GuiCharacterIconSlots
      {
         return getChildByName("_" + param1) as GuiCharacterIconSlots;
      }
      
      private function fillCroppedRows(param1:int) : void
      {
         var _loc2_:GuiCharacterIconSlots = null;
         var _loc5_:GuiCharacterIconSlots = null;
         var _loc6_:int = 0;
         if(!this.legend)
         {
            return;
         }
         var _loc3_:int = Math.ceil(Number(this.legend.roster.numCombatants) / this.legend.rosterSlotsPerRow);
         var _loc4_:int = 0;
         while(_loc4_ < this.rosterRows)
         {
            _loc5_ = this.getRosterRow(_loc4_);
            _loc5_.clearAllGuiCharacterIconSlots();
            _loc6_ = param1 + _loc4_;
            if(_loc6_ >= _loc3_)
            {
               _loc5_.visible = false;
            }
            else
            {
               _loc2_ = _loc5_;
               _loc5_.visible = true;
               _loc5_.expand(0);
               this.fillRow(_loc5_,true);
            }
            _loc4_++;
         }
      }
      
      public function fillRow(param1:GuiCharacterIconSlots, param2:Boolean) : void
      {
         var _loc5_:IGuiCharacterIconSlot = null;
         var _loc6_:IEntityDef = null;
         if(!this.partyRow || !this.legend.roster)
         {
            return;
         }
         param1.addIconEventListener(GuiIconSlotEvent.DROP,this.onGuiIconDrop);
         param1.addIconEventListener(GuiIconSlotEvent.DRAG_START,this.onGuiCharacterIconMove);
         param1.addIconEventListener(GuiIconSlotEvent.DRAG_END,this.onGuiCharacterIconMoveEnd);
         param1.addIconEventListener(GuiIconSlotEvent.CLICKED,this.onGuiIconClicked);
         var _loc3_:Saga = Saga.instance;
         var _loc4_:int = 0;
         while(_loc4_ < param1.numSlots)
         {
            _loc5_ = param1.getGuiCharacterIconSlot(_loc4_);
            _loc5_.context = context;
            if(_loc5_ == null)
            {
               context.logger.error("Reached the end of the race row too early=" + _loc4_);
               break;
            }
            if(this.legend.roster.numCombatants <= this.rosterIndex)
            {
               _loc5_.setCharacter(null,EntityIconType.ROSTER);
               (_loc5_ as MovieClip).visible = !param2;
            }
            else
            {
               (_loc5_ as MovieClip).visible = true;
               _loc6_ = this.legend.roster.getEntityDef(this.rosterIndex);
               if(!_loc6_.combatant)
               {
                  _loc5_.movieClip.visible = false;
               }
               else
               {
                  this.iconSlotByEntityDefDict[_loc6_] = _loc5_;
                  _loc5_.setCharacter(_loc6_,EntityIconType.ROSTER);
                  this.updateRosterCharacterIcon(_loc6_);
                  ++this.rosterIndex;
                  if(this.guiConfig.disabled)
                  {
                     _loc5_.dragEnabled = false;
                  }
                  else if(_context.saga.isSurvival && (_loc6_.isSurvivalDead || !_loc6_.isSurvivalRecruited))
                  {
                     _loc5_.dragEnabled = false;
                  }
                  else
                  {
                     _loc5_.dragEnabled = true;
                  }
               }
            }
            _loc4_++;
         }
      }
      
      private function updateRosterCharacterIcon(param1:IEntityDef) : void
      {
         if(this.iconSlotByEntityDefDict[param1])
         {
            if(this.legend.party.hasMemberId(param1.id))
            {
               this.iconSlotByEntityDefDict[param1].iconEnabled = false;
            }
            else
            {
               this.iconSlotByEntityDefDict[param1].iconEnabled = true;
            }
         }
      }
      
      public function updateParty() : void
      {
         var _loc2_:IGuiCharacterIconSlot = null;
         var _loc3_:IEntityDef = null;
         if(!this.legend || !this.legend.party)
         {
            return;
         }
         this.partyPointTotal.text = "0";
         this.partyLimitNameDict = new Dictionary();
         var _loc1_:int = 0;
         while(_loc1_ < this.partyRow.numSlots)
         {
            _loc2_ = this.partyRow.getGuiCharacterIconSlot(_loc1_);
            _loc3_ = null;
            if(_loc1_ < this.legend.party.numMembers)
            {
               _loc3_ = this.legend.party.getMember(_loc1_);
               if(_loc3_ != null)
               {
                  this.partyPointTotal.text = (int(this.partyPointTotal.text) + _loc3_.power).toString();
                  if(this.partyLimitNameDict[_loc3_.entityClass.partyTagDisplay] == null)
                  {
                     this.partyLimitNameDict[_loc3_.entityClass.partyTagDisplay] = [];
                  }
                  this.partyLimitNameDict[_loc3_.entityClass.partyTagDisplay].push(_loc3_);
               }
               if(this.guiConfig.disabled)
               {
                  _loc2_.dragEnabled = false;
               }
            }
            else
            {
               _loc3_ = null;
            }
            _loc2_.setCharacter(_loc3_,EntityIconType.PARTY);
            _loc1_++;
         }
      }
      
      private function showPartyRequiredDialog(param1:IEntityDef) : void
      {
         if(!param1 || !param1.partyRequired)
         {
            return;
         }
         var _loc2_:IGuiDialog = context.createDialog();
         var _loc3_:String = String(context.translate("party_required_title"));
         var _loc4_:String = String(context.translate("party_required_body"));
         var _loc5_:String = String(context.translate("ok"));
         _loc4_ = _loc4_.replace("$NAME",param1.name);
         _loc2_.openDialog(_loc3_,_loc4_,_loc5_,null);
      }
      
      public function addPartyCharacter(param1:IEntityDef, param2:IEntityDef) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         var _loc3_:Boolean = this.legend.party.updateMemberSlotPosition(param1,param2);
         if(!_loc3_ && param2 && param2.partyRequired)
         {
            this.showPartyRequiredDialog(param2);
            return false;
         }
         this.updateRosterCharacterIcon(param1);
         this.updateRosterCharacterIcon(param2);
         this.updateParty();
         return true;
      }
      
      public function removePartyCharacter(param1:IEntityDef) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         if(param1.partyRequired)
         {
            this.showPartyRequiredDialog(param1);
            return false;
         }
         this.legend.party.removeMember(param1.id);
         this.updateParty();
         this.updateRosterCharacterIcon(param1);
         this.updateLimitCount(param1);
         return true;
      }
      
      private function onGuiIconClicked(param1:GuiIconSlotEvent) : void
      {
         var _loc3_:IEntityDef = null;
         if(this.guiConfig.disabled && !this.guiConfig.allowCharacterDetails)
         {
            return;
         }
         var _loc2_:GuiCharacterIconSlot = param1.target as GuiCharacterIconSlot;
         if(this.guiConfig.disabled)
         {
            _loc3_ = this.legend.party.getMember(this.guiConfig.partyClickSlot);
            if(_loc2_.character != _loc3_)
            {
               return;
            }
         }
         context.setPref(GuiGamePrefs.PREF_PG_ROSTER_FIRST_TIME,false);
         this.selectedCharacter = _loc2_.character;
         if(this.selectedCharacter)
         {
            if(this._tooltip_id)
            {
               context.removeAllTooltips();
               this._tooltip_id = 0;
            }
            this.guiConfig.shownTutorialDetails = true;
            this.dispatchEvent(new GuiRosterEvent(GuiRosterEvent.DISPLAY_CHARACTER_DETAILS,this.selectedCharacter,_loc2_));
         }
      }
      
      private function onGuiItemIconDragStart(param1:GuiIconSlotEvent) : void
      {
         var _loc2_:GuiItemSlot = param1.target as GuiItemSlot;
         this._itemDragging = _loc2_;
         this.updateItemDropGlows(_loc2_.item);
      }
      
      public function startItemGive(param1:GuiItemSlot) : void
      {
         this._lastItemDropOk = null;
         context.playSound("ui_stats_wipes_minor");
         this.updateItemDropGlows(param1.item);
      }
      
      private function onGuiItemIconDragEnd(param1:GuiIconSlotEvent) : void
      {
         this._itemDragging = null;
         var _loc2_:GuiItemSlot = param1.target as GuiItemSlot;
         if(_loc2_ != this._lastItemDropOk)
         {
            context.playSound("ui_error");
         }
         this.clearPartyDropTargets();
         this.clearRosterDropTargets();
         this._item_slots.mouseChildren = true;
      }
      
      private function updateItemDropGlows(param1:Item) : void
      {
         var _loc3_:GuiCharacterIconSlots = null;
         updateItemDropTargets(this.partyRow,param1);
         var _loc2_:int = 0;
         while(_loc2_ < this.rosterRows)
         {
            _loc3_ = this.getRosterRow(_loc2_);
            updateItemDropTargets(_loc3_,param1);
            _loc2_++;
         }
         this._item_slots.mouseEnabled = this._item_slots.mouseChildren = false;
      }
      
      private function onGuiCharacterIconMove(param1:GuiIconSlotEvent) : void
      {
         var _loc2_:GuiCharacterIconSlot = param1.target as GuiCharacterIconSlot;
         this._draggedUnit = _loc2_;
         this.startUnitMove(_loc2_);
      }
      
      public function startUnitMove(param1:IGuiCharacterIconSlot) : IEntityDef
      {
         var _loc2_:IEntityDef = param1.character;
         this.updateLimitCount(_loc2_);
         this.updatePartyDropGlows(param1);
         var _loc3_:int = _loc2_.entityClass.getPartyTagLimit(this.legend.roster.classes.meta);
         this.textPartyLimitTotal.text = "/" + _loc3_;
         this.textPartyLimitName.text = _loc2_.entityClass.partyTagDisplay;
         context.playSound("ui_movement_button");
         return param1.character;
      }
      
      public function updateLimitCount(param1:IEntityDef) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = param1.entityClass.partyTagDisplay;
         if(this.partyLimitNameDict[_loc3_])
         {
            _loc2_ = int(this.partyLimitNameDict[_loc3_].length);
         }
         this.textPartyLimitCount.text = _loc2_.toString();
      }
      
      private function updatePartyDropGlows(param1:IGuiCharacterIconSlot) : void
      {
         var _loc2_:IEntityDef = param1.character;
         var _loc3_:int = 0;
         var _loc4_:String = _loc2_.entityClass.partyTagDisplay;
         if(this.partyLimitNameDict[_loc4_])
         {
            _loc3_ = int(this.partyLimitNameDict[_loc4_].length);
         }
         var _loc5_:int = _loc2_.entityClass.getPartyTagLimit(this.legend.roster.classes.meta);
         var _loc6_:Boolean = this.legend.party.hasMemberId(_loc2_.id);
         var _loc7_:Boolean = _loc3_ < _loc5_ && !_loc6_;
         var _loc8_:Boolean = _loc3_ < _loc5_ || _loc6_;
         this.showPartyDropTargetsForUnit(_loc2_,_loc8_,_loc7_);
         this.suppressRosterDropTargets();
         this._item_slots.mouseEnabled = this._item_slots.mouseChildren = false;
      }
      
      public function clearRosterDropTargets() : void
      {
         var _loc2_:GuiCharacterIconSlots = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.rosterRows)
         {
            _loc2_ = this.getRosterRow(_loc1_);
            updateRowDropTargetsMouseEnabled(_loc2_,true);
            _loc1_++;
         }
      }
      
      private function suppressRosterDropTargets() : void
      {
         var _loc2_:GuiCharacterIconSlots = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.rosterRows)
         {
            _loc2_ = this.getRosterRow(_loc1_);
            updateRowDropTargetsMouseEnabled(_loc2_,false);
            _loc1_++;
         }
      }
      
      public function clearPartyDropTargets() : void
      {
         updateRowDropTargetsMouseEnabled(this.partyRow,true);
      }
      
      private function showPartyDropTargetsForUnit(param1:IEntityDef, param2:Boolean, param3:Boolean) : void
      {
         var _loc6_:GuiCharacterIconSlot = null;
         var _loc7_:IEntityDef = null;
         var _loc8_:String = null;
         var _loc9_:Boolean = false;
         var _loc4_:String = param1.entityClass.partyTagDisplay;
         var _loc5_:int = 0;
         while(_loc5_ < this.partyRow.numSlots)
         {
            _loc6_ = this.partyRow.getGuiCharacterIconSlot(_loc5_) as GuiCharacterIconSlot;
            _loc7_ = _loc6_.character;
            _loc8_ = !!_loc7_ ? _loc7_.entityClass.partyTagDisplay : null;
            _loc9_ = false;
            if(!_loc7_)
            {
               _loc9_ = param3;
            }
            else if(_loc7_ == param1 || param2 || _loc8_ == _loc4_)
            {
               _loc9_ = true;
            }
            _loc6_.dropglowVisible = _loc9_;
            _loc6_.mouseEnabled = _loc9_;
            _loc6_.glowVisible = _loc9_ && _loc6_.glowVisible;
            _loc5_++;
         }
      }
      
      public function onGuiItemDrop(param1:GuiCharacterIconSlot, param2:GuiItemSlot) : void
      {
         this._lastItemDropOk = null;
         var _loc3_:Item = param2.item;
         var _loc4_:IEntityDef = param1.character;
         if(!(!_loc3_ || !_loc4_ || _loc4_.defItem == _loc3_))
         {
            this._lastItemDropOk = param2;
            context.playSound("ui_travel_press");
            this.legend.putItemOnEntity(_loc4_,_loc3_);
            this._item_slots.mouseChildren = true;
            this.clearPartyDropTargets();
            this.clearRosterDropTargets();
         }
      }
      
      private function onGuiCharacterIconMoveEnd(param1:GuiIconSlotEvent) : void
      {
         if(this._draggedUnit)
         {
            this._draggedUnit = null;
            this.clearPartyDropTargets();
            this.clearRosterDropTargets();
            this._item_slots.mouseChildren = true;
         }
      }
      
      private function onGuiIconDrop(param1:GuiIconSlotEvent) : void
      {
         var _loc2_:GuiCharacterIconSlot = GuiIconSlot.draggedTargetIconSlot as GuiCharacterIconSlot;
         if(GuiIconSlot.draggedSourceIconSlot is GuiItemSlot)
         {
            this.onGuiItemDrop(_loc2_,GuiIconSlot.draggedSourceIconSlot as GuiItemSlot);
            return;
         }
         this._draggedUnit = null;
         var _loc3_:GuiCharacterIconSlot = GuiIconSlot.draggedSourceIconSlot as GuiCharacterIconSlot;
         if(!_loc3_)
         {
            context.playSound("ui_error");
            return;
         }
         if(Boolean(GuiIconSlot.draggedTargetIconSlot) && _loc2_.parent.name == "iconRowParty")
         {
            if(_loc2_.dropglowVisible)
            {
               this.addPartyCharacter(_loc3_.character,_loc2_.character);
               if(_loc3_.parent.name != "iconRowParty")
               {
                  this.updateLimitCount(_loc3_.character);
               }
               context.playSound("ui_attack_button");
            }
            else
            {
               context.playSound("ui_error");
            }
         }
         else if(_loc3_.parent.name == "iconRowParty")
         {
            this.removePartyCharacter(_loc3_.character);
            context.playSound("ui_dismiss");
         }
         this.clearPartyDropTargets();
         this.clearRosterDropTargets();
         this._item_slots.mouseChildren = true;
      }
      
      private function GetCharacterFromSlot(param1:GuiCharacterIconSlot) : IEntityDef
      {
         if(param1 == null)
         {
            return null;
         }
         return param1.character;
      }
      
      public function addGuiRosterEvent(param1:String, param2:Function) : void
      {
         var _loc3_:EventDispatcher = this as EventDispatcher;
         if(_loc3_)
         {
            _loc3_.addEventListener(param1,param2);
         }
      }
      
      public function removeGuiRosterEvent(param1:String, param2:Function) : void
      {
         var _loc3_:EventDispatcher = this as EventDispatcher;
         if(_loc3_)
         {
            _loc3_.removeEventListener(param1,param2);
         }
      }
      
      private function on_upArrow(param1:ButtonWithIndex) : void
      {
         if(this.guiConfig.disabled)
         {
            return;
         }
         if(this._chitGroup)
         {
            --this._chitGroup.activeChitIndex;
            if(this._chitGroup.activeChitIndex - 1 < 0)
            {
               this._chitGroup.activeChitIndex = this._chitGroup.numVisibleChits;
            }
            this.fillRows(context.statCosts.roster_slots_per_row * this._chitGroup.activeChitIndex);
         }
      }
      
      private function on_downArrow(param1:ButtonWithIndex) : void
      {
         if(this.guiConfig.disabled)
         {
            return;
         }
         if(this._chitGroup)
         {
            ++this._chitGroup.activeChitIndex;
            if(this._chitGroup.activeChitIndex + 1 > this._chitGroup.numVisibleChits)
            {
               this._chitGroup.activeChitIndex = 0;
            }
            this.fillRows(context.statCosts.roster_slots_per_row * this._chitGroup.activeChitIndex);
         }
      }
      
      public function button$readyClick(param1:ButtonWithIndex) : void
      {
         if(!_context)
         {
            return;
         }
         if(!mouseEnabled && !mouseChildren)
         {
            return;
         }
         var _loc2_:int = this.legend.party.numMembers;
         var _loc3_:int = this.legend.roster.numCombatants;
         if(_context.saga.isSurvival)
         {
            _loc3_ = this.legend.roster.numSurvivalAvailable;
         }
         if(_loc2_ <= 0)
         {
            this.showDialog("heroes_ready_no_party_title","heroes_ready_no_party_body");
            return;
         }
         if(_loc2_ < 6 && _loc2_ < _loc3_)
         {
            if(_context.saga)
            {
               if(_context.saga.isSurvivalSettingUp)
               {
                  if(this.showDialog("survival_heroes_unfull_party_title","survival_heroes_unfull_party_body"))
                  {
                     return;
                  }
               }
               if(Boolean(_context.saga) && !_context.saga.getVarBool("tip_assemble_unfull"))
               {
                  _context.saga.setVar("tip_assemble_unfull",true);
                  if(this.showDialog("heroes_ready_unfull_party_title","heroes_ready_unfull_party_body"))
                  {
                     return;
                  }
               }
            }
         }
         if(_context.saga.isSurvivalSettingUp)
         {
            this.survivalAnimateOut();
            return;
         }
         this.setMouseEnabled(false);
         this.dispatchEvent(new GuiRosterEvent(GuiRosterEvent.READY,null,null));
      }
      
      private function showDialog(param1:String, param2:String) : IGuiDialog
      {
         var _loc3_:String = String(context.translateRaw(param1));
         if(!_loc3_)
         {
            return null;
         }
         this.setMouseEnabled(false);
         var _loc4_:IGuiDialog = context.createDialog();
         var _loc5_:String = String(context.translate(param2));
         var _loc6_:String = String(context.translate("ok"));
         _loc4_.openDialog(_loc3_,_loc5_,_loc6_,this.handleDialogClose);
         return _loc4_;
      }
      
      private function handleDialogClose(param1:*) : void
      {
         this.setMouseEnabled(true);
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(param1)
         {
            this.fillItemSlots();
            this._item_slots.refreshGui();
         }
         if(this.readyPanel)
         {
            this.readyPanel.visible = this.visible && this.guiConfig.allowReady;
         }
         var _loc2_:Saga = _context.saga;
         if(this.renownButton)
         {
            this.renownButton.visible = !this.readyPanel.visible || _loc2_ && _loc2_.isSurvival && !_loc2_.isSurvivalSettingUp;
         }
         this._gp.visible = param1;
         this.setMouseEnabled(param1);
         if(param1)
         {
            this.configHandler(null);
         }
      }
      
      public function handleLocaleChanged() : void
      {
         var _loc2_:GuiCharacterIconSlots = null;
         super.scaleTextfields();
         if(this.partyRow)
         {
            this.partyRow.handleLocaleChange();
         }
         var _loc1_:int = 0;
         while(_loc1_ < this.rosterRows)
         {
            _loc2_ = this.getRosterRow(_loc1_);
            _loc2_.handleLocaleChange();
            _loc1_++;
         }
         if(this._item_slots)
         {
            this._item_slots.handleLocaleChanged();
         }
      }
      
      public function handleGpCancel() : Boolean
      {
         GuiIconSlot.cancelAllDrags();
         return this._gp.handleGpCancel();
      }
      
      private function itemSlotsActivationHandler() : void
      {
         this._gp.itemSlotsActivationHandler();
      }
      
      private function itemSlotsGiveHandler(param1:GuiItemSlot) : Boolean
      {
         if(!this._itemDragging)
         {
            this._gp.itemSlotsGiveHandler(param1);
            return false;
         }
         return true;
      }
      
      private function itemSlotsRemoveHandler(param1:GuiItemSlot) : void
      {
         if(!this._itemDragging)
         {
            this._gp.itemSlotsRemoveHandler(param1);
         }
      }
      
      public function doReadyButton() : void
      {
         if(Boolean(this.button_ready) && this.button_ready.visible)
         {
            this.button_ready.press();
         }
      }
      
      public function handleSurvivalAnimatorComplete_In() : void
      {
         this.mouseEnabled = this.mouseChildren = true;
         if(this._animator_in)
         {
            this._animator_in.cleanup();
            this._animator_in = null;
         }
         this._gp.visible = visible;
         this._gp.resetSlots();
         context.removeAllTooltips();
         this.showDialog("survival_tip_starting_roster_title","survival_tip_starting_roster_body");
      }
      
      public function handleSurvivalAnimatorComplete_Out() : void
      {
         this.setMouseEnabled(false);
         if(this._animator_out)
         {
            this._animator_out.cleanup();
            this._animator_out = null;
         }
         this._gp.visible = false;
         this.showDialogWarnAssemble("survival_warn_assemble_title","survival_warn_assemble_body");
      }
      
      private function showDialogWarnAssemble(param1:String, param2:String) : void
      {
         if(Boolean(_context.saga) && !_context.saga.getMasterSaveKeyBool("setup_assembled"))
         {
            _context.saga.setMasterSaveKey("setup_assembled",true);
            var _loc3_:IGuiDialog = context.createDialog();
            var _loc4_:String = String(context.translate(param1));
            var _loc5_:String = String(context.translate(param2));
            var _loc6_:String = String(context.translate("yes"));
            var _loc7_:String = String(context.translate("no"));
            _loc3_.openTwoBtnDialog(_loc4_,_loc5_,_loc6_,_loc7_,this.dialogWarnAssembleCompleteHandler);
            return;
         }
         this.dispatchEvent(new GuiRosterEvent(GuiRosterEvent.READY,null,null));
      }
      
      private function dialogWarnAssembleCompleteHandler(param1:String) : void
      {
         var _loc2_:String = String(context.translate("yes"));
         if(param1 != _loc2_)
         {
            this.survivalAnimateOut_recoverState();
            return;
         }
         this.dispatchEvent(new GuiRosterEvent(GuiRosterEvent.READY,null,null));
      }
      
      public function survivalAnimateIn() : void
      {
         if(!_context.saga.isSurvivalSettingUp)
         {
            return;
         }
         if(this._survivalAnimatedIn)
         {
            this._gp.visible = visible;
            return;
         }
         this._gp.visible = false;
         this._survivalAnimatedIn = true;
         if(this._animator_in)
         {
            this._animator_in.cleanup();
            this._animator_in = null;
         }
         this.mouseEnabled = this.mouseChildren = false;
         this._animator_in = new GuiRoster_Animator_In(this);
         this._animator_in.startSurvivalAnimating_In();
      }
      
      public function survivalAnimateOut() : void
      {
         if(!_context.saga.isSurvivalSettingUp)
         {
            return;
         }
         this.button$ready_for_survival.enabled = false;
         this._gp.visible = false;
         if(this._animator_out)
         {
            this._animator_out.cleanup();
            this._animator_out = null;
         }
         this.readyPanel.visible = false;
         this.mouseEnabled = this.mouseChildren = false;
         this._animator_out = new GuiRoster_Animator_Out(this);
         this._animator_out.startSurvivalAnimating_Out();
      }
      
      public function survivalAnimateOut_recoverState() : void
      {
         if(!_context.saga.isSurvivalSettingUp)
         {
            return;
         }
         if(this._animator_out)
         {
            this._animator_out.cleanup();
            this._animator_out = null;
         }
         this._gp.visible = true;
         this.readyPanel.visible = true;
         this.button$ready_for_survival.enabled = true;
         this.mouseEnabled = this.mouseChildren = true;
         this._animator_out = new GuiRoster_Animator_Out(this);
         this._animator_out.recoverState();
      }
      
      public function setMouseEnabled(param1:Boolean) : void
      {
         this.mouseEnabled = this.mouseChildren = param1;
      }
      
      public function fadeRoster(param1:Number) : void
      {
         var _loc3_:GuiCharacterIconSlots = null;
         this.setMouseEnabled(false);
         this._gp.visible = false;
         var _loc2_:int = 0;
         while(_loc2_ < this.rosterRows)
         {
            _loc3_ = this.getRosterRow(_loc2_);
            TweenMax.to(_loc3_,param1,{"alpha":0});
            _loc2_++;
         }
         TweenMax.to(this._chitGroup,param1,{"alpha":0});
         TweenMax.to(this._upArrow,param1,{"alpha":0});
         TweenMax.to(this._downArrow,param1,{"alpha":0});
         TweenMax.to(this._labelRoster,param1,{"alpha":0});
      }
      
      public function showRoster(param1:Number) : void
      {
         var _loc3_:GuiCharacterIconSlots = null;
         this.setMouseEnabled(true);
         this._gp.visible = visible;
         var _loc2_:int = 0;
         while(_loc2_ < this.rosterRows)
         {
            _loc3_ = this.getRosterRow(_loc2_);
            TweenMax.to(_loc3_,param1,{"alpha":1});
            _loc2_++;
         }
         TweenMax.to(this._chitGroup,param1,{"alpha":1});
         TweenMax.to(this._upArrow,param1,{"alpha":1});
         TweenMax.to(this._downArrow,param1,{"alpha":1});
         TweenMax.to(this._labelRoster,param1,{"alpha":1});
      }
      
      private function killRosterTweens() : void
      {
         var _loc2_:GuiCharacterIconSlots = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.rosterRows)
         {
            _loc2_ = this.getRosterRow(_loc1_);
            TweenMax.killTweensOf(_loc2_);
            _loc1_++;
         }
         TweenMax.killTweensOf(this._chitGroup);
         TweenMax.killTweensOf(this._upArrow);
         TweenMax.killTweensOf(this._downArrow);
         TweenMax.killTweensOf(this._labelRoster);
      }
   }
}
