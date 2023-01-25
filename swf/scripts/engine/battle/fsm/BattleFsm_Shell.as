package engine.battle.fsm
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.sim.IBattleParty;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.core.util.StringUtil;
   import engine.entity.def.IEntityListDef;
   import engine.saga.ISaga;
   import engine.saga.Saga;
   import engine.saga.SagaInstance;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import flash.desktop.Clipboard;
   import flash.desktop.ClipboardFormats;
   
   public class BattleFsm_Shell
   {
       
      
      public var shell:ShellCmdManager;
      
      public var fsm:BattleFsm;
      
      private var shell_waves:BattleFsmWavesShellCmdManager;
      
      public var logger:ILogger;
      
      public var board:IBattleBoard;
      
      public function BattleFsm_Shell(param1:BattleFsm)
      {
         super();
         this.fsm = param1;
         this.shell = param1.shell;
         this.logger = param1.logger;
         this.board = param1.board;
         this.shell.add("turn",this.shellCmdFuncTurn);
         this.shell.add("ai",this.shellCmdFuncAi,true);
         this.shell.add("flytext",this.shellCmdFuncFlytext);
         this.shell.add("party",this.shellCmdFuncParty);
         this.shell.add("entity",this.shellCmdFuncEntity);
         this.shell.add("stat",this.shellCmdFuncStat,true);
         this.shell.add("buffarmor",this.shellCmdFuncBuffArmor,true);
         this.shell.add("buffstr",this.shellCmdFuncBuffStr,true);
         this.shell.add("order",this.shellCmdFuncOrder);
         this.shell.add("active",this.shellCmdFuncActive);
         this.shell.add("interact",this.shellCmdFuncInteract);
         this.shell.add("roster",this.shellFuncDeployRoster);
         this.shell.add("ability_incompletes",this.shellCmdFuncAbilityIncompletes);
         this.shell.add("walkable",this.shellCmdFuncWalkable);
         this.shell_waves = new BattleFsmWavesShellCmdManager(param1);
         this.shell.addShell("waves",this.shell_waves);
      }
      
      public function cleanup() : void
      {
         this.shell_waves = null;
      }
      
      private function shellCmdFuncTurn(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:BattleTurn = this.fsm._turn;
         if(_loc3_)
         {
            _loc3_.shell.execArgv(param1.cmdline,_loc2_.slice(1));
         }
         else
         {
            this.logger.info("No turn");
         }
      }
      
      private function shellCmdFuncAi(param1:CmdExec) : void
      {
         BattleFsmConfig.globalEnableAi = !BattleFsmConfig.globalEnableAi;
         this.logger.info("BattleFsmConfig.globalEnableAi = " + BattleFsmConfig.globalEnableAi);
      }
      
      private function shellCmdFuncFlytext(param1:CmdExec) : void
      {
         var _loc4_:IBattleEntity = null;
         var _loc2_:Array = param1.param;
         var _loc3_:String = _loc2_.length > 1 ? String(_loc2_[1]) : null;
         for each(_loc4_ in this.board.entities)
         {
            if(!_loc3_ || _loc4_.id.indexOf(_loc3_) >= 0)
            {
               _loc4_.emitFlyText("Testing flytext",16711680,"vinque",20);
            }
         }
      }
      
      private function shellCmdFuncParty(param1:CmdExec) : void
      {
         var _loc4_:IBattleParty = null;
         var _loc6_:int = 0;
         var _loc2_:Array = param1.param;
         var _loc3_:String = _loc2_.length > 1 ? String(_loc2_[1]) : null;
         if(!_loc3_)
         {
            this.logger.info("Usage: party [index]");
            _loc6_ = 0;
            while(_loc6_ < this.board.numParties)
            {
               _loc4_ = this.board.getParty(_loc6_);
               this.logger.info(StringUtil.padLeft(_loc6_.toString()," ",3) + "  " + StringUtil.padRight(_loc4_.id," ",6));
               _loc6_++;
            }
            return;
         }
         var _loc5_:int = int(_loc3_);
         _loc4_ = this.board.getParty(_loc5_);
         this.logger.info(_loc4_.getDebugString());
      }
      
      private function shellCmdFuncAbilityIncompletes(param1:CmdExec) : void
      {
         var _loc2_:String = this.board.abilityManager.debugIncompletes;
         this.logger.info("Debug Incompletes: ");
         this.logger.info(_loc2_);
      }
      
      private function shellCmdFuncActive(param1:CmdExec) : void
      {
         var _loc2_:IBattleEntity = this.fsm.activeEntity;
         var _loc3_:IBattleEntity = _loc2_;
         var _loc4_:String = "ACTIVE:\n" + (!!_loc3_ ? _loc3_.getDebugInfo() : "NONE");
         this.logger.info(_loc4_);
         Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,_loc4_);
      }
      
      private function shellCmdFuncInteract(param1:CmdExec) : void
      {
         var _loc2_:IBattleEntity = this.fsm.interact;
         var _loc3_:String = "INTERACT:\n" + (!!_loc2_ ? _loc2_.getDebugInfo() : "NONE");
         this.logger.info(_loc3_);
         Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,_loc3_);
      }
      
      private function shellCmdFuncOrder(param1:CmdExec) : void
      {
         var _loc3_:int = 0;
         var _loc4_:IBattleEntity = null;
         var _loc5_:BattleTurnTeam = null;
         var _loc6_:BattleTurnParty = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc2_:BattleTurnOrder = this.fsm._order;
         this.logger.info("Alive Order: ");
         _loc3_ = 0;
         while(_loc3_ < _loc2_.aliveOrder.length)
         {
            _loc4_ = _loc2_._aliveOrder[_loc3_];
            this.logger.info("  " + StringUtil.padLeft(_loc3_.toString()," ",2) + "  " + _loc4_);
            _loc3_++;
         }
         this.logger.info("Teams: ");
         for each(_loc5_ in _loc2_.turnTeams)
         {
            this.logger.info("   " + (_loc5_ == _loc2_.currentTeam ? " * " : "   ") + _loc5_);
            this.logger.info("          PARTIES");
            for each(_loc6_ in _loc5_.turnParties)
            {
               this.logger.info("            " + _loc6_);
               _loc3_ = 0;
               for each(_loc4_ in _loc6_.members)
               {
                  _loc7_ = _loc3_ == _loc6_._nextIndex ? " -> " : "    ";
                  _loc8_ = _loc6_.current == _loc4_ ? " * " : "   ";
                  this.logger.info("              " + _loc7_ + _loc8_ + _loc4_);
                  _loc3_++;
               }
            }
            this.logger.info("          TEAM CURRENTS");
            for each(_loc4_ in _loc5_.currents)
            {
               this.logger.info("                 " + _loc4_);
            }
         }
      }
      
      private function shellCmdFuncBuffArmor(param1:CmdExec) : void
      {
         var _loc2_:IBattleEntity = null;
         var _loc3_:Stat = null;
         for each(_loc2_ in this.board.entities)
         {
            if(_loc2_.isPlayer)
            {
               _loc3_ = _loc2_.stats.getStat(StatType.ARMOR,false);
               if(_loc3_)
               {
                  _loc3_.base = 100;
                  _loc3_.internalSetOriginal(100);
               }
            }
         }
      }
      
      private function shellCmdFuncBuffStr(param1:CmdExec) : void
      {
         var _loc2_:IBattleEntity = null;
         var _loc3_:Stat = null;
         for each(_loc2_ in this.board.entities)
         {
            if(_loc2_.isPlayer)
            {
               _loc3_ = _loc2_.stats.getStat(StatType.STRENGTH,false);
               if(_loc3_)
               {
                  _loc3_.base = 100;
                  _loc3_.internalSetOriginal(100);
               }
            }
         }
      }
      
      private function shellCmdFuncStat(param1:CmdExec) : void
      {
         var _loc5_:IBattleEntity = null;
         var _loc6_:Stat = null;
         var _loc7_:StatType = null;
         var _loc8_:int = 0;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            this.logger.info("Usage: stat <entity> [<stat> [value]]");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:IBattleBoard = this.board;
         _loc5_ = _loc4_.getEntityByIdOrByDefId(_loc3_,null,true);
         if(!_loc5_)
         {
            this.logger.info("Unable to find an entity by the id [" + _loc3_ + "]");
            return;
         }
         if(_loc2_.length > 2)
         {
            _loc7_ = Enum.parse(StatType,_loc2_[2]) as StatType;
            _loc6_ = _loc5_.stats.getStat(_loc7_,false);
            if(_loc2_.length > 3)
            {
               _loc8_ = int(_loc2_[3]);
               _loc5_.stats.addStat(_loc7_,_loc8_);
            }
            this.logger.info("  " + _loc7_ + " " + _loc5_.stats.getBase(_loc7_));
            return;
         }
         this.logger.info(_loc5_.getDebugInfo());
      }
      
      private function shellCmdFuncEntity(param1:CmdExec) : void
      {
         var _loc4_:IBattleParty = null;
         var _loc5_:IBattleEntity = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc2_:Array = param1.param;
         var _loc3_:String = _loc2_.length > 1 ? String(_loc2_[1]) : null;
         if(!_loc3_)
         {
            this.logger.info("Usage: entity [index]");
            _loc7_ = 0;
            while(_loc7_ < this.board.numParties)
            {
               _loc4_ = this.board.getParty(_loc7_);
               this.logger.info(StringUtil.padLeft(_loc8_.toString()," ",3) + "  " + StringUtil.padRight(_loc4_.id," ",6));
               _loc8_ = 0;
               while(_loc8_ < _loc4_.numMembers)
               {
                  _loc5_ = _loc4_.getMember(_loc8_);
                  this.logger.info("  " + _loc5_.getSummaryLine());
                  _loc8_++;
               }
               _loc7_++;
            }
            this.logger.info(StringUtil.padLeft("X"," ",3) + "  " + StringUtil.padRight("null"," ",6));
            for each(_loc5_ in this.board.entities)
            {
               if(!_loc5_.party)
               {
                  this.logger.info("  " + _loc5_.getSummaryLine());
               }
            }
            return;
         }
         var _loc6_:IBattleBoard = this.board;
         _loc5_ = _loc6_.getEntityByIdOrByDefId(_loc3_,null,true);
         if(!_loc5_)
         {
            this.logger.info("Unable to find an entity by the id [" + _loc3_ + "]");
            return;
         }
         this.logger.info("\n" + _loc5_.getDebugInfo());
      }
      
      private function shellFuncDeployParty(param1:CmdExec) : void
      {
         var _loc2_:IBattleParty = this.board.getPartyById("0");
         var _loc3_:String = _loc2_.getDebugString();
         this.logger.info(_loc3_);
      }
      
      private function shellFuncDeployRoster(param1:CmdExec) : void
      {
         var _loc2_:Saga = Saga.instance;
         if(!_loc2_.caravan)
         {
            this.logger.info("no caravan?");
            return;
         }
         var _loc3_:IEntityListDef = _loc2_.caravan.roster;
         var _loc4_:String = _loc3_.getDebugString();
         this.logger.info(_loc4_);
      }
      
      private function shellCmdFuncWalkable(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:Number = Number(_loc2_[1]);
         var _loc4_:String = String(_loc2_[2]);
         var _loc5_:ActionDef = new ActionDef(null);
         _loc5_.type = ActionType.BATTLE_WALKABLE;
         _loc5_.varvalue = _loc3_;
         _loc5_.anchor = _loc4_;
         var _loc6_:ISaga = SagaInstance.instance;
         _loc6_.executeActionDef(_loc5_,null,null);
      }
   }
}
