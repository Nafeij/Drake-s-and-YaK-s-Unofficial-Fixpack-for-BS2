package engine.entity.def
{
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.def.BattleAbilityDefLevels;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.entity.UnitStatCosts;
   import engine.saga.Saga;
   import engine.stat.def.StatPurchaseInfo;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatRanges;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.Stats;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import tbs.srv.util.UnitAddData;
   
   public class Legend extends EventDispatcher implements ILegend
   {
       
      
      private var _renown:int;
      
      protected var _roster:EntityListDef;
      
      protected var _party:PartyDef = null;
      
      protected var _rosterRowCount:int = 1;
      
      public var _rosterSlotsPerRow:int;
      
      public var statCosts:UnitStatCosts;
      
      public var classes:EntityClassDefList;
      
      public var logger:ILogger;
      
      public var abilityFactory:BattleAbilityDefFactory;
      
      public var _itemDefs:ItemListDef;
      
      public var locale:Locale;
      
      public var _items:ItemList;
      
      public function Legend(param1:int, param2:ILogger, param3:Locale, param4:EntityClassDefList, param5:UnitStatCosts, param6:BattleAbilityDefFactory, param7:ItemListDef)
      {
         this._items = new ItemList();
         super();
         this._roster = new EntityListDef(param3,param4,param2);
         this.locale = param3;
         this.classes = param4;
         this.abilityFactory = param6;
         this._rosterSlotsPerRow = param1;
         this.logger = param2;
         this._itemDefs = param7;
         this.statCosts = param5;
         this._party = new PartyDef(this._roster);
      }
      
      public function cleanup() : void
      {
         this._roster.cleanup();
         this._roster = null;
         this.locale = null;
         this.classes = null;
         this.abilityFactory = null;
         this._rosterSlotsPerRow = 0;
         this.logger = null;
         this._itemDefs = null;
         this.statCosts = null;
         this._party.cleanup();
         this._party = null;
      }
      
      public function get items() : ItemList
      {
         return this._items;
      }
      
      public function get itemDefs() : ItemListDef
      {
         return this._itemDefs;
      }
      
      public function dismissEntity(param1:IEntityDef) : void
      {
         param1.partyRequired = false;
         this._party.removeMember(param1.id);
         this._roster.removeEntityDef(param1);
         this.computeRosterRowCount();
      }
      
      public function computeRosterRowCount() : void
      {
         var _loc1_:int = this.roster.numCombatants;
         var _loc2_:int = Math.max(3,Math.ceil(_loc1_ / 9));
         this.rosterRowCount = _loc2_;
      }
      
      public function get rosterSlotAvailable() : Boolean
      {
         return this._roster.numEntityDefs < this.rosterSlotCount;
      }
      
      public function get rosterRowCount() : int
      {
         return this._rosterRowCount;
      }
      
      public function set rosterRowCount(param1:int) : void
      {
         if(param1 == this._rosterRowCount)
         {
            return;
         }
         this._rosterRowCount = param1;
         dispatchEvent(new Event(LegendEvent.ROSTERROWS));
      }
      
      public function get rosterSlotCount() : int
      {
         return this._rosterSlotsPerRow * this._rosterRowCount;
      }
      
      public function get rosterSlotsPerRow() : int
      {
         return this._rosterSlotsPerRow;
      }
      
      public function unlockRosterRow(param1:Function) : Boolean
      {
         ++this._rosterRowCount;
         param1(null);
         return true;
      }
      
      public function get roster() : IEntityListDef
      {
         return this._roster;
      }
      
      public function get party() : IPartyDef
      {
         return this._party;
      }
      
      public function set roster(param1:IEntityListDef) : void
      {
         this._roster = param1 as EntityListDef;
         this._roster.sortEntities();
         this._party = new PartyDef(this._roster);
      }
      
      public function set party(param1:IPartyDef) : void
      {
         var _loc2_:String = null;
         if(param1.roster != this._roster)
         {
            throw new ArgumentError("invalide roster");
         }
         this._party = param1 as PartyDef;
         for each(_loc2_ in (this._party as PartyDef).memberIds)
         {
            if(!this.roster.getEntityDefById(_loc2_))
            {
               this.logger.error("Error Loading Account party character def: " + _loc2_);
            }
         }
      }
      
      public function hireRosterUnit(param1:IPurchasableUnit, param2:Boolean, param3:Function) : void
      {
      }
      
      public function handleUnitAdd(param1:UnitAddData) : void
      {
      }
      
      public function purchaseStat(param1:String, param2:StatType, param3:int) : void
      {
      }
      
      public function purchaseStats(param1:String, param2:Vector.<StatPurchaseInfo>) : void
      {
      }
      
      public function rename(param1:String, param2:String) : void
      {
      }
      
      public function promote(param1:String, param2:String, param3:String, param4:Function) : void
      {
      }
      
      public function get renown() : int
      {
         return this._renown;
      }
      
      public function set renown(param1:int) : void
      {
         if(this._renown != param1)
         {
            this._renown = param1;
            dispatchEvent(new Event(LegendEvent.RENOWN));
         }
      }
      
      public function purchaseVariation(param1:IEntityDef, param2:int) : void
      {
      }
      
      protected function internalPurchaseStat(param1:String, param2:StatType, param3:int) : void
      {
         var _loc6_:Stat = null;
         var _loc7_:int = 0;
         var _loc4_:EntityDef = this.roster.getEntityDefById(param1) as EntityDef;
         if(!_loc4_)
         {
            throw new ArgumentError("No such character for purchaseStat: " + param1);
         }
         var _loc5_:StatRange = _loc4_.statRanges.getStatRange(param2);
         _loc6_ = _loc4_.stats.getStat(param2);
         _loc7_ = _loc4_.stats.getValue(StatType.RANK);
         var _loc8_:int = this.statCosts.getTotalCost(_loc7_,param3);
         var _loc9_:int = _loc6_.base + param3;
         if(_loc9_ > _loc5_.max)
         {
            throw new ArgumentError("Stat " + param2 + " doesn\'t go that high " + _loc9_ + "/" + _loc5_.max);
         }
         if(_loc8_ > this.renown)
         {
            throw new ArgumentError("Not enough renown " + _loc8_ + "/" + this.renown);
         }
         this.renown -= _loc8_;
         _loc6_.base = _loc9_;
      }
      
      protected function internalPromote(param1:String, param2:String, param3:String) : void
      {
         var _loc10_:IEntityClassDef = null;
         var _loc11_:Stats = null;
         var _loc12_:StatRanges = null;
         var _loc13_:Stat = null;
         var _loc4_:EntityDef = this.roster.getEntityDefById(param1) as EntityDef;
         if(!_loc4_)
         {
            throw new ArgumentError("No such character for promote: " + param1);
         }
         if(!this.classes)
         {
            throw new IllegalOperationError("No character classes");
         }
         var _loc5_:int = _loc4_.stats.getValue(StatType.RANK);
         var _loc6_:int = this.statCosts.getPromotionCost(_loc5_);
         if(!_loc4_.readyToPromote(this.statCosts.getKillsRequiredToPromote(_loc5_)))
         {
            throw new IllegalOperationError(_loc4_.name + _loc4_.entityClass.name + " not ready to promote.");
         }
         if(_loc6_ > this.renown)
         {
            throw new IllegalOperationError("Not enough renown " + _loc6_ + "/" + _loc5_);
         }
         if(Boolean(param2) && param2 != _loc4_.entityClass.id)
         {
            _loc10_ = this.classes.fetch(param2);
            if(!_loc10_)
            {
               throw new ArgumentError("Unknown class " + param2);
            }
            _loc4_.entityClass = _loc10_;
            _loc4_.stats.setBase(StatType.RANK,_loc4_.statRanges.getStatRange(StatType.RANK).min);
         }
         else
         {
            _loc4_.stats.setBase(StatType.RANK,_loc5_ + 1);
         }
         var _loc7_:int = 0;
         if(UnitStatCosts.USE_REBUILD_STATS)
         {
            if(this.statCosts.RANK_REBUILD == _loc5_ + 1)
            {
               _loc11_ = _loc4_.stats;
               _loc12_ = _loc4_.statRanges;
               _loc7_ = 0;
               while(_loc7_ < _loc11_.numStats)
               {
                  _loc13_ = _loc11_.getStatByIndex(_loc7_);
                  this.minimizeStat(_loc11_,_loc12_,StatType.STRENGTH);
                  this.minimizeStat(_loc11_,_loc12_,StatType.ARMOR);
                  this.minimizeStat(_loc11_,_loc12_,StatType.ARMOR_BREAK);
                  this.minimizeStat(_loc11_,_loc12_,StatType.WILLPOWER);
                  this.minimizeStat(_loc11_,_loc12_,StatType.EXERTION);
                  _loc7_++;
               }
            }
         }
         var _loc8_:BattleAbilityDefLevels = _loc4_.actives as BattleAbilityDefLevels;
         _loc8_.updateFromRank(_loc5_ + 1,this.statCosts);
         _loc4_.setupClassAbilities(this.abilityFactory,this.logger,this.statCosts);
         if(param3 != null)
         {
            _loc4_.name = param3;
         }
         var _loc9_:Saga = Saga.instance;
         if(_loc9_)
         {
            if(_loc9_.caravan)
            {
               _loc9_.caravan.vars.incrementVar("tot_renown_promote",_loc6_);
            }
            _loc9_.setMaxGlobalVar("prg_promote_rank",_loc5_ + 1);
         }
         this.renown -= _loc6_;
         this.roster.sortEntities();
         this.party.notifyChange();
      }
      
      private function minimizeStat(param1:Stats, param2:StatRanges, param3:StatType) : void
      {
         var _loc4_:StatRange = param2.getStatRange(param3);
         if(_loc4_)
         {
            param1.setBase(param3,_loc4_.min);
         }
      }
      
      public function getAllSortedItems(param1:Item) : Vector.<Item>
      {
         var _loc3_:Item = null;
         var _loc4_:int = 0;
         var _loc5_:IEntityDef = null;
         var _loc2_:Vector.<Item> = new Vector.<Item>();
         for each(_loc3_ in this._items.items)
         {
            if(_loc3_ != param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         _loc4_ = 0;
         while(_loc4_ < this.roster.numCombatants)
         {
            _loc5_ = this.roster.getEntityDef(_loc4_);
            if(_loc5_.defItem)
            {
               if(_loc5_.defItem != param1)
               {
                  _loc2_.push(_loc5_.defItem);
               }
            }
            _loc4_++;
         }
         _loc2_.sort(this.itemSorter);
         return _loc2_;
      }
      
      public function getAllNumItems(param1:Item) : int
      {
         var _loc3_:Item = null;
         var _loc4_:int = 0;
         var _loc5_:IEntityDef = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this._items.items)
         {
            if(_loc3_ != param1)
            {
               _loc2_++;
            }
         }
         _loc4_ = 0;
         while(_loc4_ < this.roster.numCombatants)
         {
            _loc5_ = this.roster.getEntityDef(_loc4_);
            if(_loc5_.defItem)
            {
               if(_loc5_.defItem != param1)
               {
                  _loc2_++;
               }
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      private function itemSorter(param1:Item, param2:Item) : int
      {
         if(!param1 || !param2)
         {
            throw new ArgumentError("invalid sort items");
         }
         if(!param1.def || !param2.def)
         {
            throw new ArgumentError("invalid sort item defs");
         }
         if(param1.def.rank != param2.def.rank)
         {
            return param1.def.rank - param2.def.rank;
         }
         var _loc3_:String = param1.def.name;
         var _loc4_:String = param2.def.name;
         return _loc3_.localeCompare(_loc4_);
      }
      
      public function putItemOnEntity(param1:IEntityDef, param2:Item) : void
      {
         if(param1.defItem)
         {
            param1.defItem.owner = null;
            this._items.addItem(param1.defItem);
            param1.defItem = null;
         }
         if(param2.owner)
         {
            param2.owner.defItem = null;
         }
         this._items.removeItemById(param2.id);
         param2.owner = param1;
         param2.owner.defItem = param2;
      }
      
      public function ensureUnitInParty(param1:IEntityDef) : void
      {
         var _loc2_:int = 0;
         var _loc3_:IEntityDef = null;
         if(!param1)
         {
            return;
         }
         if(this.roster.getEntityDefById(param1.id))
         {
            if(!this.party.hasMemberId(param1.id))
            {
               if(this.party.numMembers < 6)
               {
                  this.party.addMember(param1.id);
                  this.logger.info("Legend.ensureUnitInParty adding [" + param1 + "]");
               }
               else
               {
                  _loc2_ = 0;
                  while(_loc2_ < this.party.numMembers)
                  {
                     _loc3_ = this.party.getMember(_loc2_);
                     if(!_loc3_ || !_loc3_.partyRequired)
                     {
                        this.logger.info("Legend.ensureUnitInParty replacing [" + _loc3_ + "] with [" + param1 + "]");
                        this.party.updateMemberSlotPosition(param1,_loc3_);
                        return;
                     }
                     _loc2_++;
                  }
               }
            }
         }
      }
   }
}
