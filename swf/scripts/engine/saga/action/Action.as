package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattleObjective;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.entity.def.IEntityDef;
   import engine.entity.model.IEntity;
   import engine.saga.Saga;
   import engine.saga.happening.Happening;
   import engine.saga.happening.IHappeningDefProvider;
   import engine.saga.vars.Variable;
   import flash.errors.IllegalOperationError;
   import flash.utils.getTimer;
   
   public class Action
   {
      
      public static var lastId:int = 0;
       
      
      public var def:ActionDef;
      
      public var saga:Saga;
      
      private var _started:Boolean;
      
      private var _ended:Boolean;
      
      private var _paused:Boolean;
      
      protected var savedScene:Boolean;
      
      protected var curScene:String;
      
      private var restoringScene:String;
      
      private var restoredScene:Boolean;
      
      public var happening:Happening;
      
      public var id:int;
      
      public var logger:ILogger;
      
      public var startTime:int = 0;
      
      public var endTime:int = 0;
      
      public var listener:IActionListener;
      
      private var _ending:Boolean;
      
      public function Action(param1:ActionDef, param2:Saga)
      {
         super();
         this.def = param1;
         this.saga = param2;
         this.logger = param2.logger;
         this.id = ++lastId;
      }
      
      public static function factory(param1:ActionDef, param2:Saga, param3:Happening, param4:IActionListener) : Action
      {
         var _loc5_:Action = internal_factory(param1,param2);
         if(_loc5_)
         {
            _loc5_.happening = param3;
            _loc5_.listener = param4;
         }
         return _loc5_;
      }
      
      private static function internal_factory(param1:ActionDef, param2:Saga) : Action
      {
         return ActionCtor.ctor(param1,param2);
      }
      
      public function toString() : String
      {
         if(!this.def)
         {
            return "UNKNOWN";
         }
         if(this.happening)
         {
            return this.def.labelString + " (" + this.id + ") happening=" + this.happening.def.id + " bag=" + this.happening.def.bag;
         }
         if(this.def.parentHappeningDef)
         {
            return this.def.labelString + " (" + this.id + ") hapdef=" + this.def.parentHappeningDef;
         }
         return this.def.labelString + " (" + this.id + ")";
      }
      
      public function toStringNoId() : String
      {
         if(!this.def)
         {
            return "UNKNOWN";
         }
         if(this.happening)
         {
            return this.def.labelString + " happening=" + this.happening.def.id + " bag=" + this.happening.def.bag;
         }
         return this.def.labelString;
      }
      
      public function get ended() : Boolean
      {
         return this._ended;
      }
      
      final protected function sceneStateSave() : void
      {
         if(this.savedScene)
         {
            return;
         }
         this.saga.sceneStateSave();
         this.savedScene = true;
      }
      
      final public function end(param1:Boolean = false) : void
      {
         var delta:int;
         var force:Boolean = param1;
         if(this._ended)
         {
            return;
         }
         if(!this._started)
         {
            throw new IllegalOperationError("not started");
         }
         if(this.savedScene && this.saga && !this.saga.cleanedup && !force)
         {
            if(!this.restoringScene)
            {
               if(this._ending)
               {
                  return;
               }
               this._ending = true;
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("   ***    ACTION RESTORING [" + this + "]");
               }
               this.paused = false;
               this.restoringScene = this.saga.sceneStateRestore();
               if(!this.restoringScene)
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.debug("   ***    ACTION NO-RESTORE [" + this + "]");
                  }
                  this.restoredScene = true;
               }
               else if(this.curScene == this.restoringScene)
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.debug("   ***    ACTION QUICK-RESTORED [" + this + "] scene " + this.restoringScene);
                  }
                  this.restoredScene = true;
               }
            }
            if(!this.restoredScene)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("   ***    ACTION RESTORE-END-WAIT [" + this + "] for scene " + this.restoringScene);
               }
               return;
            }
         }
         this.endTime = getTimer();
         delta = this.endTime - this.startTime;
         this._ending = true;
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("SAGA","    <-    action end    (" + this.id + ") [" + this.toStringNoId() + "]");
         }
         this.saga.slog.appendItemEnd(this);
         this._ended = true;
         this.paused = false;
         this.handleEnded();
         try
         {
            if(this.listener)
            {
               this.listener.actionListenerHandleActionEnded(this);
            }
            if(Boolean(this.happening) && this.happening != this.listener)
            {
               this.happening.handleActionEnd(this);
            }
            if(this.saga)
            {
               this.saga.handleActionEnded(this);
            }
            if(Boolean(this.happening) && !this.happening.ended)
            {
               this.happening.execute();
            }
         }
         catch(err:Error)
         {
            logger.error("Failed to dispatch Action " + this + " END:");
            logger.error(err.getStackTrace());
         }
      }
      
      public function get started() : Boolean
      {
         return this._started;
      }
      
      public function start() : void
      {
         var st:String = null;
         if(this._started)
         {
            return;
         }
         if(this._ended)
         {
            throw new IllegalOperationError("already ended");
         }
         this.startTime = getTimer();
         this.saga.slog.appendItemStart(this,this.happening);
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("SAGA","    ->    ACTION START  (" + this.id + ") [" + this.toStringNoId() + "]");
         }
         this._started = true;
         try
         {
            this.handleStarted();
         }
         catch(err:Error)
         {
            logger.error("Failed to start action: (" + id + ") [" + this.toStringNoId() + "]");
            st = err.getStackTrace();
            if(!logger.isDebugEnabled && !saga.appinfo.isDebugger)
            {
               st = StringUtil.truncateLines(st,3,1000);
            }
            logger.error(st);
            end();
         }
      }
      
      protected function handleStarted() : void
      {
      }
      
      protected function handleEnded() : void
      {
      }
      
      public function handleTriggerSceneVisible(param1:String, param2:int) : void
      {
      }
      
      public function handleTriggerTravelFallComplete() : void
      {
      }
      
      final public function triggerSceneLoaded(param1:String, param2:int) : void
      {
         this.handleTriggerSceneLoaded(param1,param2);
         this.curScene = param1;
         if(this.curScene == this.restoringScene)
         {
            if(!this.restoredScene)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("   ***    ACTION RESTORED [" + this + "] scene " + this.curScene);
               }
               this.restoredScene = true;
               this.end();
               return;
            }
         }
      }
      
      public function triggerFlashPageReady(param1:String) : void
      {
      }
      
      public function triggerCameraAnchorReached() : void
      {
      }
      
      public function triggerCameraSplineComplete(param1:String) : void
      {
      }
      
      protected function handleTriggerSceneLoaded(param1:String, param2:int) : void
      {
      }
      
      public function triggerMapCampExit() : void
      {
      }
      
      public function triggerSceneExit(param1:String, param2:int) : void
      {
      }
      
      public function triggerFlashPageFinished(param1:String) : void
      {
      }
      
      public function triggerVideoFinished(param1:String) : void
      {
      }
      
      public function triggerAssembleHeroesComplete() : void
      {
      }
      
      public function triggerBattleFinished(param1:String) : void
      {
      }
      
      public function triggerWarResolutionClosed() : void
      {
      }
      
      public function triggerBattleResolutionClosed() : void
      {
      }
      
      public function triggerBattleSetup(param1:String) : void
      {
      }
      
      public function triggerBattleDeploymentStart(param1:String) : void
      {
      }
      
      public function get paused() : Boolean
      {
         return this._paused;
      }
      
      public function set paused(param1:Boolean) : void
      {
         if(this._paused == param1)
         {
            return;
         }
         this._paused = param1;
         if(this._paused)
         {
            this.saga.pause(this);
            this.saga.setHalting(null,"action paused [" + this + "]");
            this.saga.forceFinishHalt();
         }
         else
         {
            this.saga.unpause(this);
            this.saga.cancelHalting("action unpaused [" + this + "]");
         }
      }
      
      public function get happeningDefProvider() : IHappeningDefProvider
      {
         if(this.happening)
         {
            return this.happening.def.bag;
         }
         return null;
      }
      
      protected function translateMsg(param1:String, param2:Boolean = false) : String
      {
         var _loc3_:String = null;
         if(Boolean(param1) && param1.indexOf("$") == 0)
         {
            _loc3_ = param1.substr(1);
            param1 = this.saga.locale.translateEncodedToken(_loc3_,param2);
         }
         return param1;
      }
      
      public function findBattleEntityFromList(param1:String, param2:Boolean, param3:String = null) : IBattleEntity
      {
         var _loc7_:String = null;
         var _loc8_:IBattleEntity = null;
         var _loc4_:Array = param1.split(",");
         var _loc5_:Array = !!param3 ? param3.split(",") : null;
         var _loc6_:BattleBoard = this.saga.getBattleBoard();
         if(!_loc6_)
         {
            return null;
         }
         for each(_loc7_ in _loc4_)
         {
            _loc8_ = this.findBattleEntity(_loc7_,param2);
            if(!(_loc8_ && _loc8_.def && _loc8_.def.entityClass && _loc5_ && _loc5_.indexOf(_loc8_.def.entityClass.race) == -1))
            {
               if(_loc8_)
               {
                  return _loc8_;
               }
            }
         }
         return null;
      }
      
      public function findBattleEntity(param1:String, param2:Boolean) : IBattleEntity
      {
         var _loc3_:BattleBoard = this.saga.getBattleBoard();
         if(!_loc3_)
         {
            return null;
         }
         param1 = this.saga.performStringReplacement_SagaVar(param1);
         var _loc4_:IEntityDef = this.saga.getCastMember(param1);
         if(_loc4_)
         {
            param1 = _loc4_.id;
         }
         return _loc3_.getEntityByIdOrByDefId(param1,null,param2);
      }
      
      public function extractEntities(param1:String, param2:Boolean, param3:Vector.<String> = null) : Vector.<IEntity>
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:IEntityDef = null;
         var _loc10_:IBattleEntity = null;
         if(!this.saga)
         {
            throw new IllegalOperationError("No Saga for extractEntities");
         }
         var _loc4_:Vector.<IEntity> = new Vector.<IEntity>();
         var _loc5_:BattleBoard = this.saga.getBattleBoard();
         if(!_loc5_)
         {
            return _loc4_;
         }
         if(!param1)
         {
            return _loc4_;
         }
         if(param1.charAt(0) == "*")
         {
            return this._extractWildcardEntities(_loc4_,param1,param2);
         }
         var _loc6_:Array = param1.split(",");
         for each(_loc7_ in _loc6_)
         {
            _loc8_ = _loc7_;
            _loc8_ = this.saga.performStringReplacement_SagaVar(_loc8_);
            _loc9_ = this.saga.getCastMember(_loc8_);
            if(_loc9_)
            {
               _loc8_ = _loc9_.id;
            }
            _loc10_ = _loc5_.getEntityByIdOrByDefId(_loc8_,null,param2);
            if(_loc10_)
            {
               _loc4_.push(_loc10_);
            }
            else if(param3)
            {
               param3.push(_loc7_);
            }
         }
         return _loc4_;
      }
      
      private function _extractWildcardEntities(param1:Vector.<IEntity>, param2:String, param3:Boolean) : Vector.<IEntity>
      {
         var _loc7_:IBattleEntity = null;
         var _loc4_:Boolean = StringUtil.startsWith(param2,"*{isPlayer}");
         var _loc5_:Boolean = !_loc4_ && StringUtil.startsWith(param2,"*{isEnemy}");
         var _loc6_:BattleBoard = this.saga.getBattleBoard();
         for each(_loc7_ in _loc6_.entities)
         {
            if(!(!_loc7_.alive && !param3))
            {
               if(!(_loc4_ && !_loc7_.isPlayer))
               {
                  if(!(_loc5_ && !_loc7_.isEnemy))
                  {
                     param1.push(_loc7_);
                  }
               }
            }
         }
         return param1;
      }
      
      public function fastForward() : Boolean
      {
         return false;
      }
      
      public function triggerBattleObjectiveOpened(param1:BattleObjective) : void
      {
      }
      
      public function triggerVariableIncrement(param1:Variable, param2:int) : void
      {
      }
      
      public function triggerCreditsComplete() : void
      {
      }
      
      public function triggerPageStarted(param1:String) : void
      {
      }
      
      public function triggerMapInfo(param1:String) : void
      {
      }
      
      public function triggerClick(param1:String) : Boolean
      {
         return false;
      }
      
      public function triggerOptionsShowing(param1:Boolean) : void
      {
      }
   }
}
