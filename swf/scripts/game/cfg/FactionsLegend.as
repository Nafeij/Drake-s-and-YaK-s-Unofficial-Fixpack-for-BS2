package game.cfg
{
   import engine.entity.def.EntityDef;
   import engine.entity.def.EntityDefVars;
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IPurchasableUnit;
   import engine.entity.def.Legend;
   import engine.entity.def.LegendEvent;
   import engine.stat.def.StatPurchaseInfo;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import game.session.actions.PromoteUnitTxn;
   import game.session.actions.PurchaseRosterUnitTxn;
   import game.session.actions.PurchaseStatsTxn;
   import game.session.actions.RenameUnitTxn;
   import game.session.actions.ResetStatsTxn;
   import game.session.actions.RetireRosterUnitTxn;
   import game.session.actions.RosterRowUnlockTxn;
   import game.session.actions.UnitVariationTxn;
   import tbs.srv.util.UnitAddData;
   
   public class FactionsLegend extends Legend
   {
       
      
      private var factions:FactionsConfig;
      
      private var _ai:AccountInfoDef;
      
      public function FactionsLegend(param1:int, param2:FactionsConfig)
      {
         super(param1,param2.logger,param2.config.context.locale,param2.config.classes,param2.config.statCosts,param2.config.abilityFactory,param2.config.itemDefs);
         this.factions = param2;
         param2.config.addEventListener(GameConfig.EVENT_ACCOUNT_INFO,this.accountInfoHandler);
         this.accountInfoHandler(null);
      }
      
      public function get ai() : AccountInfoDef
      {
         return this._ai;
      }
      
      public function set ai(param1:AccountInfoDef) : void
      {
         if(this._ai == param1)
         {
            return;
         }
         if(this._ai)
         {
            this._ai.legend.removeEventListener(LegendEvent.ROSTERROWS,this.aiRosterRowsHandler);
         }
         this._ai = param1;
         if(this._ai)
         {
            this._ai.legend.addEventListener(LegendEvent.ROSTERROWS,this.aiRosterRowsHandler);
         }
         this.aiRosterRowsHandler(null);
         this.readRosterFromAccount();
         this.readRenownFromAccount();
      }
      
      private function aiRosterRowsHandler(param1:Event) : void
      {
         if(this._ai)
         {
            _rosterRowCount = this.ai.legend.rosterRowCount;
         }
      }
      
      private function readRosterFromAccount() : void
      {
         if(this._ai)
         {
            roster.copyFrom(this._ai.legend.roster);
            party.reset(this._ai.legend.party.copyMemberIds);
            _rosterRowCount = this.factions.config.accountInfo.legend.rosterRowCount;
         }
      }
      
      private function readRenownFromAccount() : void
      {
         if(this._ai)
         {
            renown = this._ai.legend.renown;
         }
      }
      
      private function accountInfoHandler(param1:Event) : void
      {
         this.ai = this.factions.config.accountInfo;
      }
      
      override public function unlockRosterRow(param1:Function) : Boolean
      {
         if(_rosterRowCount >= this.factions.config.statCosts.max_num_roster_rows)
         {
            return false;
         }
         var _loc2_:RosterRowUnlockTxn = new RosterRowUnlockTxn(this.factions.config.fsm.session.credentials,param1,logger,this.factions.config.accountInfo);
         _loc2_.send(this.factions.config.fsm.communicator);
         return true;
      }
      
      override public function dismissEntity(param1:IEntityDef) : void
      {
         this.removeEntityFromRoster(param1);
      }
      
      override public function promote(param1:String, param2:String, param3:String, param4:Function) : void
      {
         var _loc5_:PromoteUnitTxn = null;
         internalPromote(param1,param2,param3);
         if(!this.factions.config.accountInfo.tutorial)
         {
            _loc5_ = new PromoteUnitTxn(this.factions.config.fsm.session.credentials,param4,logger,param1,param2,param3);
            _loc5_.send(this.factions.config.fsm.communicator);
         }
         else if(param4 != null)
         {
            param4(null);
         }
      }
      
      override public function rename(param1:String, param2:String) : void
      {
         var _loc3_:EntityDef = roster.getEntityDefById(param1) as EntityDef;
         if(!_loc3_)
         {
            throw new ArgumentError("No such character for promote: " + param1);
         }
         var _loc4_:int = this.factions.config.statCosts.getRenameCost();
         if(_loc4_ > renown)
         {
            throw new IllegalOperationError("Not enough renown " + _loc4_);
         }
         if(param2 != null)
         {
            _loc3_.name = param2;
         }
         renown -= _loc4_;
         roster.sortEntities();
         var _loc5_:RenameUnitTxn = new RenameUnitTxn(this.factions.config.fsm.session.credentials,null,logger,param1,param2);
         _loc5_.send(this.factions.config.fsm.communicator);
      }
      
      public function setStatsToMinimum(param1:String, param2:Vector.<StatType>) : void
      {
         var _loc4_:StatType = null;
         var _loc5_:ResetStatsTxn = null;
         var _loc6_:StatRange = null;
         var _loc7_:Stat = null;
         var _loc3_:EntityDef = roster.getEntityDefById(param1) as EntityDef;
         if(!_loc3_)
         {
            throw new ArgumentError("No such character for purchaseStat: " + param1);
         }
         for each(_loc4_ in param2)
         {
            _loc6_ = _loc3_.statRanges.getStatRange(_loc4_);
            _loc7_ = _loc3_.stats.getStat(_loc4_);
            _loc7_.base = _loc6_.min;
         }
         _loc5_ = new ResetStatsTxn(this.factions.config.fsm.session.credentials,null,logger,param1);
         _loc5_.send(this.factions.config.fsm.communicator);
      }
      
      override public function purchaseStat(param1:String, param2:StatType, param3:int) : void
      {
         internalPurchaseStat(param1,param2,param3);
         var _loc4_:PurchaseStatsTxn = new PurchaseStatsTxn(this.factions.config.fsm.session.credentials,null,logger,param1,[param2.name],[param3]);
         _loc4_.send(this.factions.config.fsm.communicator);
      }
      
      override public function purchaseStats(param1:String, param2:Vector.<StatPurchaseInfo>) : void
      {
         var _loc5_:StatPurchaseInfo = null;
         var _loc6_:EntityDef = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc3_:Array = [];
         var _loc4_:Array = [];
         for each(_loc5_ in param2)
         {
            internalPurchaseStat(param1,_loc5_.stat,_loc5_.delta);
            _loc3_.push(_loc5_.stat.name);
            _loc4_.push(_loc5_.delta);
         }
         _loc6_ = roster.getEntityDefById(param1) as EntityDef;
         _loc7_ = _loc6_.getMaxUpgrades(classes.meta,this.factions.config.statCosts);
         _loc8_ = _loc6_.upgrades;
         if(_loc8_ > _loc7_)
         {
            throw new ArgumentError("Attempt to upgrade past maximum " + _loc8_ + "/" + _loc7_);
         }
         var _loc9_:PurchaseStatsTxn = new PurchaseStatsTxn(this.factions.config.fsm.session.credentials,null,logger,param1,_loc3_,_loc4_);
         _loc9_.send(this.factions.config.fsm.communicator);
      }
      
      private function generateIdForUnit(param1:String) : String
      {
         var _loc2_:* = param1 + "_";
         var _loc3_:String = null;
         var _loc4_:int = 0;
         while(_loc4_ < 1000)
         {
            _loc3_ = _loc2_ + _loc4_;
            if(!roster.getEntityDefById(_loc3_))
            {
               break;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      override public function hireRosterUnit(param1:IPurchasableUnit, param2:Boolean, param3:Function) : void
      {
         var slots:int;
         var id:String = null;
         var txn:PurchaseRosterUnitTxn = null;
         var pu:IPurchasableUnit = param1;
         var fake:Boolean = param2;
         var callback:Function = param3;
         if(!this.factions.config.factions)
         {
            return;
         }
         slots = this.factions.config.factions.legend.rosterSlotCount;
         if(roster.numCombatants >= slots)
         {
            throw new ArgumentError("Not enough roster slots " + slots);
         }
         id = this.generateIdForUnit(pu.def.id);
         if(!id)
         {
            throw new ArgumentError("Unable to generate id for unit " + pu);
         }
         if(renown < pu.cost)
         {
            throw new ArgumentError("Not enough renown + " + pu.cost + "/" + renown);
         }
         if(!fake)
         {
            txn = new PurchaseRosterUnitTxn(this.factions.config.fsm.session.credentials,function(param1:PurchaseRosterUnitTxn):void
            {
               if(param1.success)
               {
                  finishPurchaseRosterUnit(id,pu,callback);
               }
               else if(!param1.canRetry)
               {
                  if(callback != null)
                  {
                     callback(null);
                  }
               }
            },logger,pu.def.id,id,pu.def.name);
            txn.send(this.factions.config.fsm.communicator);
         }
         else
         {
            this.finishPurchaseRosterUnit(id,pu,callback);
         }
      }
      
      private function finishPurchaseRosterUnit(param1:String, param2:IPurchasableUnit, param3:Function) : void
      {
         var _loc4_:EntityDef = param2.def.duplicate(param1,logger) as EntityDef;
         _loc4_.startDate = new Date().time;
         _loc4_.name = param2.def.entityClass.name;
         roster.addEntityDef(_loc4_);
         roster.sortEntities();
         renown -= param2.cost;
         if(param3 != null)
         {
            param3(_loc4_);
         }
      }
      
      public function removeEntityFromRoster(param1:IEntityDef) : void
      {
         var _loc2_:RetireRosterUnitTxn = new RetireRosterUnitTxn(this.factions.config.fsm.session.credentials,null,logger,param1.id);
         _loc2_.send(this.factions.config.fsm.communicator);
         party.removeMember(param1.id);
         roster.removeEntityDef(param1);
      }
      
      override public function handleUnitAdd(param1:UnitAddData) : void
      {
         var _loc2_:IEntityDef = new EntityDefVars(this.factions.config.context.locale).fromJson(param1.unitv,logger,this.factions.config.abilityFactory,this.factions.config.classes,this.factions.config,true,this.factions.config.itemDefs,this.factions.config.statCosts);
         roster.addEntityDef(_loc2_);
         roster.sortEntities();
         dispatchEvent(new Event(LegendEvent.ROSTER_ADD));
      }
      
      override public function purchaseVariation(param1:IEntityDef, param2:int) : void
      {
         var _loc3_:IEntityAppearanceDef = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:UnitVariationTxn = null;
         if(!param1)
         {
            throw new ArgumentError("Bad entity " + param1);
         }
         if(param1.appearanceIndex == param2)
         {
            return;
         }
         if(param1.entityClass.appearanceDefs.length < param2 || param2 < 0)
         {
            throw new ArgumentError("variationIndex is out of range " + param2);
         }
         if(!param1.isAppearanceAcquired(param2))
         {
            _loc3_ = param1.entityClass.getEntityClassAppearanceDef(param2);
            if(Boolean(_loc3_.unlock_id) && !this.ai.hasUnlock(_loc3_.unlock_id))
            {
               throw new ArgumentError("variation is not unlocked");
            }
            if(!_loc3_.acquire_id || !this.ai.hasUnlock(_loc3_.acquire_id))
            {
               _loc4_ = this.factions.config.statCosts.variation;
               if(_loc4_ > renown)
               {
                  throw new IllegalOperationError("Not enough renown " + _loc4_);
               }
               renown -= _loc4_;
            }
            param1.acquireAppearance(param2);
         }
         param1.appearanceIndex = param2;
         if(!this.ai.tutorial)
         {
            _loc5_ = this.factions.lobbyManager.current.options.lobby_id;
            _loc6_ = new UnitVariationTxn(this.factions.config.fsm.session.credentials,null,logger,param1,param2,_loc5_);
            _loc6_.send(this.factions.config.fsm.communicator);
         }
      }
   }
}
