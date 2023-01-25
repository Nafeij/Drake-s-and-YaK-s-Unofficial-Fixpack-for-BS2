package engine.battle.ability.phantasm.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.model.IEffectTagProvider;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.ability.event.TargetAnimEvent;
   import engine.battle.ability.phantasm.def.ChainPhantasmsDef;
   import engine.battle.ability.phantasm.def.PhantasmAnimTriggerDef;
   import engine.battle.ability.phantasm.def.PhantasmDef;
   import engine.battle.ability.phantasm.def.PhantasmTargetMode;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.math.MathUtil;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class ChainPhantasms extends EventDispatcher implements IChainPhantasms
   {
      
      public static var DEBUG:Boolean = true;
      
      private static var _lastId:int;
      
      public static var FAST_ATTACK:Boolean;
       
      
      private var cursor:int;
      
      private var startTimer:Timer;
      
      private var timer:Timer;
      
      private var applyTimer:Timer;
      
      private var endTimer:Timer;
      
      private var startedTime:int = 0;
      
      private var _ended:Boolean;
      
      private var _applied:Boolean;
      
      public var effect:Effect;
      
      public var def:ChainPhantasmsDef;
      
      private var started:Boolean;
      
      private var starting:Boolean;
      
      private var allowRotation:Boolean = true;
      
      private var allowTargetRotation:Boolean = true;
      
      private var waitingForEffectPhase:Boolean;
      
      private var waitingForAbilityComplete:Boolean;
      
      public var logger:ILogger;
      
      private var _id:int;
      
      private var cleanedup:Boolean;
      
      private var hasTriggeredPhantasms:Dictionary;
      
      private var delayedPhantasms:Dictionary;
      
      public function ChainPhantasms(param1:Effect, param2:ChainPhantasmsDef, param3:ILogger)
      {
         this.startTimer = new Timer(0,1);
         this.timer = new Timer(0,1);
         this.applyTimer = new Timer(0,1);
         this.endTimer = new Timer(0,1);
         this.hasTriggeredPhantasms = new Dictionary();
         this.delayedPhantasms = new Dictionary();
         super();
         if(param1._def.phantasms == null)
         {
            throw new ArgumentError("no def for chain phantasms");
         }
         this._id = ++_lastId;
         this.logger = param3;
         this.effect = param1;
         this.def = param2;
         param1.chain = this;
         var _loc4_:IBattleEntity = param1.ability.caster;
         _loc4_.animEventDispatcher.addEventListener(TargetAnimEvent.EVENT,this.animEvent);
         var _loc5_:IBattleEntity = param1.target;
         _loc5_.animEventDispatcher.addEventListener(TargetAnimEvent.EVENT,this.animEvent);
         this.timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
         this.applyTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.applyTimerCompleteHandler);
         this.endTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.endTimerCompleteHandler);
         this.startTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.startTimerCompleteHandler);
      }
      
      override public function toString() : String
      {
         return this._id.toString() + "/" + this.effect.ability.def.id + ":" + this.effect._def.name;
      }
      
      public function cleanup() : void
      {
         if(!this.effect || !this.effect.ability || this.cleanedup)
         {
            return;
         }
         this.cleanedup = true;
         if(DEBUG)
         {
            this.logger.debug("ChainPhantasms.cleanup " + this);
         }
         var _loc1_:IBattleEntity = this.effect.ability.caster;
         var _loc2_:IBattleEntity = this.effect.target;
         _loc1_.animEventDispatcher.removeEventListener(TargetAnimEvent.EVENT,this.animEvent);
         _loc2_.animEventDispatcher.removeEventListener(TargetAnimEvent.EVENT,this.animEvent);
         this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
         this.applyTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.applyTimerCompleteHandler);
         this.endTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.endTimerCompleteHandler);
         this.startTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.startTimerCompleteHandler);
         this.delayedPhantasms = null;
         this.hasTriggeredPhantasms = null;
         if(this.effect)
         {
            this.effect.chain = null;
         }
         this.startTimer.stop();
         this.endTimer.stop();
         this.applyTimer.stop();
         this.applyTimer = null;
         this.startTimer = null;
         this.timer = null;
         this.effect = null;
         this.def = null;
      }
      
      public function animEvent(param1:TargetAnimEvent) : void
      {
         var _loc4_:PhantasmAnimTriggerDef = null;
         var _loc5_:PhantasmAnimTriggerDef = null;
         var _loc6_:PhantasmDef = null;
         var _loc7_:int = 0;
         var _loc2_:String = "";
         if(param1.entity == this.effect.ability.caster)
         {
            _loc2_ = PhantasmAnimTriggerDef.getKey(PhantasmTargetMode.CASTER,param1.animId,param1.eventId);
         }
         else
         {
            _loc2_ = PhantasmAnimTriggerDef.getKey(PhantasmTargetMode.TARGET,param1.animId,param1.eventId);
         }
         var _loc3_:Vector.<PhantasmDef> = this.def.animTriggerEntriesMap[_loc2_];
         if(_loc3_)
         {
            for each(_loc6_ in _loc3_)
            {
               if(DEBUG)
               {
                  this.logger.debug("ChainPhantasms.animEvent " + _loc2_ + " triggered " + _loc6_);
               }
               _loc7_ = !!_loc6_.animTrigger ? _loc6_.animTrigger.deltaMs : 0;
               this.executePhantasm(_loc6_,_loc7_,true);
            }
         }
         for each(_loc4_ in this.def.applyTriggers)
         {
            if(_loc4_.key == _loc2_)
            {
               if(DEBUG)
               {
                  this.logger.debug("ChainPhantasms.animEvent " + _loc2_ + " applyTrigger delta " + _loc4_.deltaMs);
               }
               this.applyTimer.stop();
               this.applyTimer.reset();
               this.applyTimer.delay = _loc4_.deltaMs;
               this.applyTimer.start();
               break;
            }
         }
         for each(_loc5_ in this.def.endTriggers)
         {
            if(_loc5_.key == _loc2_)
            {
               if(DEBUG)
               {
                  this.logger.debug("ChainPhantasms.animEvent " + _loc2_ + " endTrigger delta " + _loc5_.deltaMs);
               }
               this.endTimer.stop();
               this.endTimer.reset();
               this.endTimer.delay = _loc5_.deltaMs;
               this.endTimer.start();
               break;
            }
         }
      }
      
      public function get applied() : Boolean
      {
         return this._applied;
      }
      
      public function set applied(param1:Boolean) : void
      {
         var _loc2_:String = null;
         if(this._applied != param1)
         {
            this._applied = param1;
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("ChainPhantasms.applied " + this + " " + this._applied);
            }
            _loc2_ = "apply";
            this.executeSynced(_loc2_,null);
            dispatchEvent(new ChainPhantasmsEvent(ChainPhantasmsEvent.APPLIED,this,null));
         }
      }
      
      private function executeSynced(param1:String, param2:PhantasmDef) : void
      {
         var _loc3_:PhantasmDef = null;
         var _loc4_:IBattleEntity = null;
         var _loc5_:IBattleEntity = null;
         if(!param1)
         {
            return;
         }
         if(DEBUG)
         {
            this.logger.debug("ChainPhantasms.executeSynced " + param1 + " from " + param2);
         }
         if(this.def.rotation && this.allowTargetRotation && param1 == "apply")
         {
            if(this.effect.target)
            {
               _loc4_ = this.effect.target;
               _loc5_ = this.effect.ability.caster;
               if(_loc5_ != _loc4_)
               {
                  if(!_loc4_.mobility.moving)
                  {
                     if(!_loc4_.ignoreTargetRotation)
                     {
                        if(!_loc4_.effects || !_loc4_.effects.hasTag(EffectTag.NO_ROTATE_ON_HIT))
                        {
                           _loc4_.turnToFace(_loc5_.rect,false);
                        }
                     }
                  }
               }
            }
         }
         for each(_loc3_ in this.def.entries)
         {
            if(_loc3_ == param2)
            {
               return;
            }
            if(_loc3_.sync == param1)
            {
               this.executePhantasm(_loc3_,0,false);
            }
         }
      }
      
      private function executePhantasm(param1:PhantasmDef, param2:int, param3:Boolean) : void
      {
         var _loc4_:IPersistedEffects = null;
         var _loc5_:IPersistedEffects = null;
         var _loc6_:IEffectTagProvider = null;
         var _loc7_:Timer = null;
         if(param1.directionalFlags != 0)
         {
            if((this.effect.directionalFlags & param1.directionalFlags) == 0)
            {
               return;
            }
         }
         if(param1.casterTagReqs != null)
         {
            _loc4_ = this.effect.ability.caster.effects;
            if(param1.casterTagReqs.checkTags(_loc4_,this.logger) == false)
            {
               return;
            }
         }
         if(!this.targetSizeReqValid(param1))
         {
            return;
         }
         if(param1.targetTagReqs != null)
         {
            _loc5_ = this.effect.target.effects;
            if(param1.targetTagReqs.checkTags(_loc5_,this.logger) == false)
            {
               return;
            }
         }
         if(param1.effectTagReqs != null)
         {
            _loc6_ = this.effect;
            if(param1.effectTagReqs.checkTags(_loc6_,this.logger) == false)
            {
               return;
            }
         }
         if(param2 > 0)
         {
            _loc7_ = new Timer(param2,1);
            _loc7_.addEventListener(TimerEvent.TIMER_COMPLETE,this.phantasmDelayTimerCompleteHandler);
            this.delayedPhantasms[_loc7_] = {
               "pd":param1,
               "delay":param2,
               "doSync":param3
            };
            _loc7_.start();
            return;
         }
         this.hasTriggeredPhantasms[param1] = param1;
         if(DEBUG)
         {
            this.logger.debug("ChainPhantasms.executePhantasm [" + param1 + "] sync=" + param1.sync);
         }
         dispatchEvent(new ChainPhantasmsEvent(ChainPhantasmsEvent.PHANTASM,this,param1));
         if(param3 && Boolean(param1.sync))
         {
            if(param1.sync != "apply" && param1.sync != "end")
            {
               this.executeSynced(param1.sync,param1);
            }
         }
      }
      
      private function phantasmDelayTimerCompleteHandler(param1:TimerEvent) : void
      {
         var _loc2_:Timer = null;
         var _loc3_:Object = null;
         _loc2_ = param1.target as Timer;
         _loc2_.removeEventListener(TimerEvent.TIMER_COMPLETE,this.phantasmDelayTimerCompleteHandler);
         _loc3_ = this.delayedPhantasms[_loc2_];
         var _loc4_:PhantasmDef = _loc3_.pd;
         var _loc5_:Boolean = Boolean(_loc3_.doSync);
         delete this.delayedPhantasms[_loc2_];
         this.executePhantasm(_loc4_,0,_loc5_);
      }
      
      public function get ended() : Boolean
      {
         return this._ended;
      }
      
      public function set ended(param1:Boolean) : void
      {
         var _loc2_:Boolean = false;
         if(this._ended != param1)
         {
            if(DEBUG)
            {
               this.logger.debug("ChainPhantasms.ending... " + this);
            }
            _loc2_ = this._applied;
            if(param1 && !_loc2_)
            {
               this.logger.info("ChainPhantasms.ended force-APPLY " + this);
               this.applied = true;
            }
            if(DEBUG)
            {
               this.logger.debug("ChainPhantasms.ended " + this);
            }
            this._ended = param1;
            this.handleGuaranteedTriggers();
            dispatchEvent(new ChainPhantasmsEvent(ChainPhantasmsEvent.ENDED,this,null));
         }
      }
      
      private function handleGuaranteedTriggers() : void
      {
         var _loc1_:Object = null;
         var _loc2_:PhantasmDef = null;
         var _loc3_:Timer = null;
         var _loc4_:Object = null;
         var _loc5_:PhantasmDef = null;
         for(_loc1_ in this.delayedPhantasms)
         {
            _loc3_ = _loc1_ as Timer;
            _loc3_.stop();
            _loc3_.removeEventListener(TimerEvent.TIMER_COMPLETE,this.phantasmDelayTimerCompleteHandler);
            _loc4_ = this.delayedPhantasms[_loc3_];
            _loc5_ = _loc4_.pd;
            this.executePhantasm(_loc5_,0,false);
         }
         for each(_loc2_ in this.def.entries)
         {
            if(_loc2_.guaranteed || _loc2_.animTrigger && _loc2_.animTrigger.guaranteed)
            {
               if(!(_loc2_ in this.hasTriggeredPhantasms))
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.debug("ChainPhantasms.handleGuaranteedTriggers FULFILLING GUARANTEE for " + _loc2_);
                  }
                  this.executePhantasm(_loc2_,0,false);
               }
            }
         }
      }
      
      protected function timerCompleteHandler(param1:TimerEvent) : void
      {
         this.process();
      }
      
      protected function applyTimerCompleteHandler(param1:TimerEvent) : void
      {
         this.applied = true;
      }
      
      protected function endTimerCompleteHandler(param1:TimerEvent) : void
      {
         this.ended = true;
      }
      
      protected function startTimerCompleteHandler(param1:TimerEvent) : void
      {
         this.startTimer.stop();
         this.internalStart();
      }
      
      public function start(param1:int, param2:Boolean, param3:Boolean) : void
      {
         var _loc4_:IEffect = null;
         if(this.started)
         {
            throw new IllegalOperationError("already started");
         }
         param1 += this.def.startDelay;
         this.allowRotation = param2;
         this.allowTargetRotation = param3;
         this.timer.stop();
         this.timer.reset();
         this.cursor = 0;
         this.starting = true;
         if(param1 > 0)
         {
            this.startTimer.delay = param1;
            this.startTimer.start();
            return;
         }
         if(this.def.waitEffect)
         {
            _loc4_ = this.effect.ability.getEffectByDef(this.def.waitEffect);
            if(!_loc4_ || _loc4_.phase.index < this.def.waitEffectPhase.index)
            {
               this.waitingForEffectPhase = true;
            }
         }
         if(this.effect.waitForAbility)
         {
            if(!this.effect.waitForAbility.completed)
            {
               this.logger.info("Chain waiting for ability " + this.effect.waitForAbility);
               this.waitingForAbilityComplete = true;
            }
         }
         this.internalStart();
      }
      
      private function internalStart() : void
      {
         var _loc3_:IBattleEntity = null;
         if(this.started)
         {
            throw new IllegalOperationError("already started");
         }
         if(!this.starting)
         {
            throw new IllegalOperationError("not starting");
         }
         if(this.startTimer.running)
         {
            return;
         }
         if(this.waitingForAbilityComplete || this.waitingForEffectPhase)
         {
            return;
         }
         this.starting = false;
         this.started = true;
         this.startedTime = getTimer();
         dispatchEvent(new ChainPhantasmsEvent(ChainPhantasmsEvent.STARTED,this,null));
         var _loc1_:int = this.def.applyTime;
         if(this.def.applyTimeVariance)
         {
            _loc1_ += MathUtil.randomInt(-this.def.applyTimeVariance,this.def.applyTimeVariance);
            _loc1_ = Math.max(0,_loc1_);
            this.logger.info("ChainPhantasm variance apply changed " + this.def.applyTime + " to " + _loc1_ + " for " + this);
         }
         var _loc2_:int = this.def.endTime;
         _loc2_ = Math.max(_loc2_,_loc1_);
         this.applyTimer.delay = _loc1_;
         this.endTimer.delay = _loc2_;
         if(this.def.rotation)
         {
            if(this.allowRotation)
            {
               _loc3_ = this.effect.ability.caster;
               if(this.allowRotation)
               {
                  if(Boolean(this.effect.target) && _loc3_ != this.effect.target)
                  {
                     _loc3_.turnToFace(this.effect.target.rect,this.def.reverseRotation);
                  }
                  else if(this.effect.tile)
                  {
                     _loc3_.turnToFace(this.effect.tile.rect,this.def.reverseRotation);
                  }
               }
            }
         }
         this.process();
         if(_loc1_ == 0)
         {
            this.applied = true;
         }
         else
         {
            if(FAST_ATTACK)
            {
               this.applyTimer.delay = Math.min(_loc1_,10);
            }
            this.applyTimer.start();
         }
         if(!this.def || this.cleanedup)
         {
            return;
         }
         if(_loc2_ == 0)
         {
            this.ended = true;
         }
         else
         {
            if(FAST_ATTACK)
            {
               this.endTimer.delay = Math.min(_loc2_,30);
            }
            this.endTimer.start();
         }
      }
      
      public function process() : void
      {
         var _loc3_:PhantasmDef = null;
         var _loc4_:PhantasmDef = null;
         var _loc5_:int = 0;
         var _loc1_:int = getTimer();
         var _loc2_:Number = _loc1_ - this.startedTime;
         while(this.cursor < this.def.timedEntries.length)
         {
            _loc3_ = this.def.timedEntries[this.cursor];
            if(!(_loc3_.time >= 0 && _loc3_.time <= _loc2_))
            {
               break;
            }
            this.executePhantasm(_loc3_,0,true);
            ++this.cursor;
         }
         if(this.cursor < this.def.timedEntries.length)
         {
            _loc4_ = this.def.timedEntries[this.cursor];
            _loc5_ = Math.max(_loc4_.time - _loc2_);
            this.timer.reset();
            this.timer.delay = _loc5_;
            this.timer.start();
         }
      }
      
      public function onEffectPhaseChange(param1:IEffect) : void
      {
         if(!this.starting)
         {
            return;
         }
         if(this.def.waitEffect == param1.def)
         {
            if(param1.phase.index >= this.def.waitEffectPhase.index)
            {
               this.waitingForEffectPhase = false;
               this.internalStart();
            }
         }
      }
      
      public function onWaitAbilityComplete() : void
      {
         if(!this.starting)
         {
            return;
         }
         this.logger.info("Chain ability complete " + this.effect.waitForAbility);
         this.waitingForAbilityComplete = false;
         this.internalStart();
      }
      
      private function targetSizeReqValid(param1:PhantasmDef) : Boolean
      {
         var _loc2_:IBattleEntity = null;
         if(!param1 || !param1.largeTargetReq)
         {
            return true;
         }
         switch(param1.targetMode)
         {
            case PhantasmTargetMode.CASTER:
               _loc2_ = this.effect.ability.caster;
               break;
            case PhantasmTargetMode.TARGET:
               _loc2_ = this.effect.target;
         }
         if(!_loc2_)
         {
            this.logger.info("ChainPhantasms.executePhantasms ignoring requirement " + param1.largeTargetReq + " because tgt is null");
            return true;
         }
         if(_loc2_)
         {
            if(param1.largeTargetReq.value)
            {
               if(_loc2_.rect.area < 4)
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.debug("ChainPhantasms.executePhantasms not executing phantasm [" + param1.toString() + "] because pd.largetTargetReq.true && tgt.rect.area < 4");
                  }
                  return false;
               }
            }
            else if(_loc2_.rect.area > 3)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("ChainPhantasms.executePhantasms not executing phantasm [" + param1.toString() + "] because pd.largetTargetReq.false && tgt.rect.area > 3");
               }
               return false;
            }
         }
         return true;
      }
   }
}
