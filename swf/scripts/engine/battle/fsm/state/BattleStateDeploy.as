package engine.battle.fsm.state
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattlePartyType;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.IBattleStateUserDeploying;
   import engine.battle.fsm.txn.BattleTxnDeploySend;
   import engine.battle.sim.BattlePartyEvent;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.saga.Saga;
   import engine.tile.TileLocationVars;
   import engine.tile.def.TileLocation;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   import tbs.srv.battle.data.client.BattleDeployData;
   
   public class BattleStateDeploy extends BaseBattleState implements IBattleStateUserDeploying
   {
      
      public static var DEFAULT_PLAYER_DEPLOY_ID:String = "player0";
       
      
      private var txnSends:Dictionary;
      
      private var txnSendsCount:int = 0;
      
      private var txnSendsResponseCount:int = 0;
      
      private var localCount:int = 0;
      
      private var remoteCount:int = 0;
      
      private var deployments:Vector.<Vector.<TileLocation>>;
      
      private var parties:Vector.<IBattleParty>;
      
      public var isLocalDeployed:Boolean;
      
      public function BattleStateDeploy(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         this.txnSends = new Dictionary();
         this.deployments = new Vector.<Vector.<TileLocation>>();
         this.parties = new Vector.<IBattleParty>();
         super(param1,param2,param3,param2.config.deployTimeoutMs);
         this.showDeploymentId = DEFAULT_PLAYER_DEPLOY_ID;
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc4_:IBattleParty = null;
         var _loc5_:String = null;
         battleFsm.stopEatingSubsequent("tbs.srv.battle.data.client.BattleDeployData");
         var _loc1_:BattleBoard = battleFsm.board as BattleBoard;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.numParties)
         {
            _loc4_ = _loc1_.getParty(_loc2_);
            this.parties.push(_loc4_);
            _loc4_.addEventListener(BattlePartyEvent.DEPLOYED,this.partyDeployedHandler);
            if(_loc4_.type == BattlePartyType.LOCAL)
            {
               ++this.localCount;
               if(!_loc4_.deployed)
               {
                  _loc5_ = _loc4_.id;
                  _loc1_.spawnPlayers(_loc5_,DEFAULT_PLAYER_DEPLOY_ID);
                  _loc1_.autoDeployPartyById(_loc5_);
                  this.deployments.push(null);
               }
               else
               {
                  this.deployments.push(new Vector.<TileLocation>());
               }
            }
            else if(_loc4_.type == BattlePartyType.REMOTE)
            {
               this.deployments.push(null);
               ++this.remoteCount;
            }
            _loc2_++;
         }
         timeoutMs = battleFsm.config.deployTimeoutMs;
         super.handleEnteredState();
         this.sendLocalDeployments();
         _loc1_.boardDeploymentStarted = true;
         var _loc3_:Saga = _loc1_.scene.context.saga as Saga;
         if(_loc3_)
         {
            _loc3_.triggerBattleDeploymentStart(_loc1_.scene.def.url);
            if(_loc1_.snapSrc)
            {
               _loc3_.performBattleReady();
            }
         }
      }
      
      override protected function handleCleanup() : void
      {
         var _loc1_:IBattleParty = null;
         for each(_loc1_ in this.parties)
         {
            _loc1_.removeEventListener(BattlePartyEvent.DEPLOYED,this.partyDeployedHandler);
         }
         super.handleCleanup();
         battleFsm.eatAllSubsequent("tbs.srv.battle.data.client.BattleDeployData");
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         advanceTimer(param1);
      }
      
      override protected function handleTimeout() : void
      {
         var _loc3_:IBattleParty = null;
         logger.info("BattleStateDeploy force timeout deploy");
         var _loc1_:IBattleBoard = battleFsm.board;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.numParties)
         {
            _loc3_ = _loc1_.getParty(_loc2_);
            if(_loc3_.type == BattlePartyType.LOCAL)
            {
               _loc1_.autoDeployPartyById(_loc3_.id);
               _loc3_.deployed = true;
            }
            _loc2_++;
         }
      }
      
      protected function partyDeployedHandler(param1:BattlePartyEvent) : void
      {
         var _loc2_:IBattleParty = param1.party;
         if(_loc2_.type == BattlePartyType.LOCAL)
         {
            this.sendLocalDeployment(_loc2_);
         }
      }
      
      private function sendLocalDeployments() : void
      {
         var _loc3_:IBattleParty = null;
         var _loc1_:IBattleBoard = (fsm as BattleFsm).board;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.numParties)
         {
            _loc3_ = _loc1_.getParty(_loc2_);
            if(_loc3_.type == BattlePartyType.LOCAL && _loc3_.deployed)
            {
               this.sendLocalDeployment(_loc3_);
            }
            _loc2_++;
         }
      }
      
      private function sendLocalDeployment(param1:IBattleParty) : void
      {
         var _loc2_:BattleTxnDeploySend = null;
         if(param1.type == BattlePartyType.LOCAL && param1.deployed)
         {
            if(this.txnSends[param1])
            {
               throw new IllegalOperationError("Try to send again?  no.");
            }
            this.isLocalDeployed = true;
            if(battleFsm.isOnline)
            {
               logger.info("SENDING DEPLOYMENT for " + battleFsm.session.credentials.userId + ", index " + battleFsm.localBattleOrder + ", party=" + param1);
               _loc2_ = new BattleTxnDeploySend(battleFsm.battleId,battleFsm.localBattleOrder,param1,battleFsm.session.credentials,this.sendHandler,battleFsm,logger);
               addTxn(_loc2_);
               this.txnSends[param1] = _loc2_;
               _loc2_.send(battleFsm.session.communicator);
            }
            else
            {
               this.txnSends[param1] = null;
               ++this.txnSendsResponseCount;
            }
            this.checkDeploymentComplete();
         }
      }
      
      private function sendHandler(param1:BattleTxnDeploySend) : void
      {
         this.checkDeploymentComplete();
      }
      
      public function get isRemoteWaiting() : Boolean
      {
         return this.isLocalDeployed && Boolean(this.remoteCount);
      }
      
      public function autoDeployLocal() : void
      {
         var _loc2_:IBattleParty = null;
         var _loc3_:int = 0;
         var _loc4_:IBattleEntity = null;
         var _loc1_:int = 0;
         while(_loc1_ < battleFsm.board.numParties)
         {
            _loc2_ = battleFsm.board.getParty(_loc1_);
            if(_loc2_.type == BattlePartyType.LOCAL)
            {
               battleFsm.board.autoDeployPartyById(_loc2_.id);
               _loc3_ = 0;
               while(_loc3_ < _loc2_.numMembers)
               {
                  _loc4_ = _loc2_.getMember(_loc3_);
                  _loc4_.deploymentReady = true;
                  _loc3_++;
               }
               _loc2_.deployed = true;
            }
            _loc1_++;
         }
         this.checkDeploymentComplete();
      }
      
      override public function handleMessage(param1:Object) : Boolean
      {
         var _loc2_:BattleDeployData = null;
         var _loc3_:Vector.<TileLocation> = null;
         var _loc4_:Object = null;
         var _loc5_:IBattleParty = null;
         var _loc6_:TileLocation = null;
         var _loc7_:int = 0;
         if(param1["class"] == "tbs.srv.battle.data.client.BattleDeployData")
         {
            _loc2_ = new BattleDeployData();
            _loc2_.parseJson(param1,logger);
            _loc3_ = new Vector.<TileLocation>();
            for each(_loc4_ in _loc2_.tiles)
            {
               _loc6_ = TileLocationVars.parse(_loc4_,logger);
               _loc3_.push(_loc6_);
            }
            _loc5_ = battleFsm.board.getPartyById(_loc2_.user_id.toString());
            if(_loc5_)
            {
               _loc7_ = battleFsm.board.getPartyIndex(_loc5_);
               logger.info("RECEIVED DEPLOYMENT for " + _loc2_);
               this.deployments[_loc7_] = _loc3_;
               this.checkDeploymentComplete();
            }
            return true;
         }
         logger.info(!!("BattleStateDeploy can\'t handle " + param1) ? param1["class"] : null);
         return false;
      }
      
      private function finishDeployment() : void
      {
         phase = StatePhase.COMPLETED;
      }
      
      private function checkDeploymentComplete() : Boolean
      {
         var _loc3_:IBattleParty = null;
         var _loc4_:Vector.<TileLocation> = null;
         var _loc5_:int = 0;
         var _loc6_:IBattleEntity = null;
         var _loc7_:TileLocation = null;
         if(!this.isLocalDeployed)
         {
            return false;
         }
         var _loc1_:Boolean = true;
         var _loc2_:int = 0;
         while(_loc2_ < battleFsm.board.numParties)
         {
            _loc3_ = battleFsm.board.getParty(_loc2_);
            if(this.deployments.length - 1 < _loc2_)
            {
               this.finishDeployment();
               return true;
            }
            _loc4_ = this.deployments[_loc2_];
            if(_loc4_ == null && !_loc3_.deployed)
            {
               _loc1_ = false;
            }
            else if(_loc3_.type != BattlePartyType.LOCAL && !_loc3_.deployed)
            {
               logger.info("DEPLOYING REMOTE " + _loc2_ + ", party=" + _loc3_);
               _loc5_ = 0;
               while(_loc5_ < _loc3_.numMembers)
               {
                  _loc6_ = _loc3_.getMember(_loc5_);
                  _loc7_ = _loc4_[_loc5_];
                  _loc6_.setPos(_loc7_.x,_loc7_.y);
                  _loc6_.deploymentReady = true;
                  _loc5_++;
               }
               _loc3_.deployed = true;
            }
            _loc2_++;
         }
         if(_loc1_)
         {
            this.finishDeployment();
            return true;
         }
         return false;
      }
   }
}
