package engine.battle.music
{
   import engine.anim.AnimDispatcherEvent;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.sound.ISoundDriver;
   import engine.sound.ISoundEventId;
   import engine.sound.config.ISoundSystem;
   import engine.sound.view.ISound;
   import flash.events.IEventDispatcher;
   import flash.utils.getTimer;
   
   public class BattleMusic
   {
       
      
      public var system:ISoundSystem;
      
      public var driver:ISoundDriver;
      
      public var def:BattleMusicDef;
      
      public var cur:BattleMusicStateDef;
      
      public var next:BattleMusicStateDef;
      
      public var systemid:ISoundEventId;
      
      public var completing:Boolean;
      
      public var preloader:BattleMusicPreloader;
      
      public var started:Boolean;
      
      private var logger:ILogger;
      
      private var animDispatcher:IEventDispatcher;
      
      private var traumaHigh:Number = 0;
      
      private var shortUrl:String;
      
      private var curStartTime:int;
      
      private var curUseCompleteParam:Boolean;
      
      private var curUseTraumaParam:Boolean;
      
      private var _lastWinning:Boolean = true;
      
      public function BattleMusic(param1:BattleMusicDef, param2:ISoundSystem, param3:ILogger, param4:IEventDispatcher)
      {
         super();
         this.def = param1;
         this.system = param2;
         this.driver = !!param2 ? param2.driver : null;
         this.logger = param3;
         this.animDispatcher = param4;
         if(param1)
         {
            this.shortUrl = StringUtil.getBasename(param1.url);
         }
         this.preloader = new BattleMusicPreloader(this);
      }
      
      public function cleanup() : void
      {
         this.next = null;
         this.terminateCur();
         this.preloader.cleanup();
         this.preloader = null;
      }
      
      public function stop() : void
      {
         this.next = null;
         this.terminateCur();
         this.started = false;
      }
      
      public function start() : void
      {
         if(this.started)
         {
            return;
         }
         this.started = true;
         if(this.def.killMusic)
         {
            this.system.music = null;
         }
         var _loc1_:BattleMusicStateDef = this.def.getStateById(this.def.start);
         this.play(_loc1_);
         this.queueNext();
      }
      
      private function checkOutro() : Boolean
      {
         var _loc1_:BattleMusicStateDef = null;
         if(!this.isCurPlaying)
         {
            if(Boolean(this.cur) && Boolean(this.cur.outro))
            {
               _loc1_ = this.def.getStateById(this.cur.outro);
               if(_loc1_)
               {
                  this.play(_loc1_);
                  return true;
               }
               this.logger.error("BattleMusic " + this.def.url + " [" + this.cur.id + "] failed to outro [" + this.cur.outro + "]");
            }
         }
         return false;
      }
      
      public function updateBattleMusic() : void
      {
         if(this.checkOutro())
         {
            return;
         }
         if(this.next)
         {
            if(!this.isCurPlaying || this.isCurDurationExpired)
            {
               this.play(this.next);
               this.queueNext();
            }
            else if(this.next.event == this.cur.event && !this.next.allowQueueDuplicate)
            {
               this.updateParam(this.next);
               this.queueNext();
            }
         }
      }
      
      private function queueNext() : void
      {
         if(Boolean(this.cur) && Boolean(this.cur.queueNext))
         {
            this.next = this.def.getStateById(this.cur.queueNext);
            if(!this.next)
            {
               this.logger.error("BattleMusic [" + this.cur.id + "] failed to queueNext [" + this.cur.queueNext + "]");
            }
            else if(this.logger.isDebugEnabled)
            {
               this.logger.debug("BattleMusic [" + this.cur.id + "] queued next [" + this.next.id + "]");
            }
         }
         else
         {
            this.next = null;
         }
         this.notifyAnimDispatcher();
      }
      
      public function respawnTrauma(param1:IBattleParty) : void
      {
         this.traumaHigh = -1;
         var _loc2_:Number = param1.trauma;
         this.internal_handleTraumaChange(_loc2_,false);
         this.triggerRespawn(true);
      }
      
      public function handleTraumaChange(param1:IBattleParty) : void
      {
         var _loc2_:Number = param1.trauma;
         this.internal_handleTraumaChange(_loc2_,!param1.isPlayer);
      }
      
      public function internal_handleTraumaChange(param1:Number, param2:Boolean) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:BattleMusicTriggerDef = null;
         if(param1 > this.traumaHigh)
         {
            _loc3_ = this.traumaHigh;
            this.traumaHigh = param1;
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("BattleMusic TRAUMA " + param1);
            }
            if(this.curUseTraumaParam)
            {
               if(this.systemid)
               {
                  this.driver.setEventParameterValueByName(this.systemid,"trauma",param1);
               }
            }
            this._lastWinning = param2;
            _loc4_ = this.def.findTraumaTrigger(_loc3_,param1,param2);
            this.handleTrigger(_loc4_);
            this.notifyAnimDispatcher();
         }
      }
      
      private function notifyAnimDispatcher() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(this.animDispatcher)
         {
            if(this.cur)
            {
               _loc1_ = StringUtil.padLeft(this.cur.id," ",10) + ": " + this.cur.event;
            }
            if(this.next)
            {
               _loc2_ = StringUtil.padLeft(this.next.id," ",10) + ": " + this.next.event;
            }
            _loc3_ = "";
            if(this.completing)
            {
               if(this.curUseCompleteParam)
               {
                  _loc3_ = "WAIT FOR COMPLETION...";
               }
               else
               {
                  _loc3_ = "WAIT FOR FINISH...";
               }
            }
            this.animDispatcher.dispatchEvent(new AnimDispatcherEvent(AnimDispatcherEvent.BATTLE_TRAUMA,null,_loc1_,_loc2_,_loc3_,this._lastWinning ? "PLAYER" : "ENEMY",this.traumaHigh,this.shortUrl));
         }
      }
      
      public function handleBattleFinished(param1:Boolean) : void
      {
         if(param1)
         {
            this.triggerWin();
         }
         else
         {
            this.triggerLose();
         }
      }
      
      public function handleBattleWaveIncrease(param1:Boolean) : void
      {
         var _loc2_:BattleMusicTriggerDef = this.def.findTriggerByType(BattleMusicTriggerType.WAVE,param1);
         if(_loc2_)
         {
            this.traumaHigh = -1;
            this.handleTrigger(_loc2_);
         }
      }
      
      public function handleBattlePillage(param1:Boolean) : void
      {
         var _loc2_:BattleMusicTriggerDef = this.def.findTriggerByType(BattleMusicTriggerType.PILLAGE,param1);
         if(_loc2_)
         {
            this.handleTrigger(_loc2_);
         }
      }
      
      private function triggerWin() : void
      {
         var _loc1_:BattleMusicTriggerDef = this.def.findTriggerByType(BattleMusicTriggerType.WIN,true);
         if(_loc1_)
         {
            this.handleTrigger(_loc1_);
         }
      }
      
      private function triggerLose() : void
      {
         var _loc1_:BattleMusicTriggerDef = this.def.findTriggerByType(BattleMusicTriggerType.LOSE,false);
         this.handleTrigger(_loc1_);
      }
      
      private function triggerRespawn(param1:Boolean) : void
      {
         var _loc2_:BattleMusicTriggerDef = this.def.findTriggerByType(BattleMusicTriggerType.RESPAWN,param1);
         this.handleTrigger(_loc2_);
      }
      
      private function handleTrigger(param1:BattleMusicTriggerDef) : void
      {
         if(!param1)
         {
            return;
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("BattleMusic.handleTrigger " + param1);
         }
         var _loc2_:BattleMusicStateDef = this.def.getStateById(param1.target);
         if(!_loc2_)
         {
            return;
         }
         if(_loc2_ == this.cur && !_loc2_.allowQueueDuplicate)
         {
            return;
         }
         if(_loc2_ == this.next && !param1.clobber && !_loc2_.allowQueueDuplicate)
         {
            return;
         }
         this.next = _loc2_;
         if(Boolean(this.cur) && (this.next.event != this.cur.event || _loc2_.allowQueueDuplicate))
         {
            this.completeCur(param1.clobber);
         }
         this.updateBattleMusic();
         this.notifyAnimDispatcher();
      }
      
      private function updateParam(param1:BattleMusicStateDef) : void
      {
         var ccc:BattleMusicStateDef = param1;
         this.cur = ccc;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("BattleMusic.updateParam cur= [" + (!!this.cur ? this.cur.id : "null") + "]");
         }
         if(Boolean(this.systemid) && Boolean(ccc.paramName))
         {
            try
            {
               this.driver.setEventParameterValueByName(this.systemid,this.cur.paramName,this.cur.paramValue);
            }
            catch(err:Error)
            {
               logger.error("BattleMusic.updateParam " + def.url + " failed");
               logger.error(err.getStackTrace());
            }
         }
         this.notifyAnimDispatcher();
      }
      
      private function play(param1:BattleMusicStateDef) : void
      {
         var m:ISound = null;
         var s:ISound = null;
         var ccc:BattleMusicStateDef = param1;
         if(!ccc || this.cur && (ccc.event != this.cur.event || ccc.allowQueueDuplicate))
         {
            this.stopCur();
         }
         if(!ccc)
         {
            return;
         }
         if(!this.cur || ccc.event != this.cur.event || ccc.allowQueueDuplicate)
         {
            this.curUseCompleteParam = false;
            this.curUseTraumaParam = false;
            this.cur = ccc;
            this.curStartTime = getTimer();
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("BattleMusic.play cur= [" + (!!this.cur ? this.cur.id : "null") + "]");
            }
            try
            {
               m = this.driver.system.music;
               if(m && m.playing && m.def.eventName == this.cur.event)
               {
                  this.systemid = m.systemid;
               }
               else
               {
                  if(this.preloader.ok)
                  {
                     s = this.driver.system.playMusicEvent(this.cur.sku,this.cur.event,ccc.allowQueueDuplicate);
                  }
                  this.systemid = !!s ? s.systemid : null;
               }
               if(this.systemid)
               {
                  this.curUseCompleteParam = this.driver.hasEventParameter(this.cur.event,"complete");
                  this.curUseTraumaParam = this.driver.hasEventParameter(this.cur.event,"trauma");
                  if(this.curUseTraumaParam)
                  {
                     this.driver.setEventParameter(this.cur.event,"trauma",this.traumaHigh);
                  }
               }
               if(Boolean(this.systemid) && Boolean(this.cur.paramName))
               {
                  this.driver.setEventParameterValueByName(this.systemid,this.cur.paramName,this.cur.paramValue);
               }
            }
            catch(err:Error)
            {
               logger.error("BattleMusic.play [" + cur.id + "] failed");
               cur = null;
               curStartTime = 0;
               logger.error(err.getStackTrace());
            }
            this.completing = false;
            this.notifyAnimDispatcher();
         }
      }
      
      private function get isCurPlaying() : Boolean
      {
         var _loc1_:Boolean = false;
         if(this.systemid)
         {
            _loc1_ = this.driver.isPlaying(this.systemid);
            if(_loc1_)
            {
               return true;
            }
         }
         return false;
      }
      
      private function get isCurDurationExpired() : Boolean
      {
         var _loc1_:int = 0;
         if(this.cur)
         {
            if(Boolean(this.curStartTime) && this.cur.durationMs > 0)
            {
               _loc1_ = getTimer() - this.curStartTime;
               if(_loc1_ >= this.cur.durationMs)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function terminateCur() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         if(!this.cur || !this.isCurPlaying)
         {
            return;
         }
         if(this.cur.ringout)
         {
            if(this.curUseCompleteParam)
            {
               if(!this.completing)
               {
                  _loc1_ = this.driver.getEventParameterValueByName(this.systemid,"complete");
                  _loc2_ = Math.max(1,_loc1_);
                  this.driver.setEventParameterValueByName(this.systemid,"complete",_loc2_);
               }
            }
         }
         else if(!this.cur.retain)
         {
            this.stopCur();
         }
      }
      
      public function stopCur() : void
      {
         if(!this.cur)
         {
            return;
         }
         this.curUseCompleteParam = false;
         if(Boolean(this.systemid) && this.driver.isPlaying(this.systemid))
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("BattleMusic.stop [" + this.cur.id + "]");
            }
            try
            {
               if(!this.cur.ringout)
               {
                  this.driver.stopEvent(this.systemid,false);
               }
            }
            catch(err:Error)
            {
               logger.error("BattleMusic.stopCur " + def.url + " failed");
               logger.error(err.getStackTrace());
            }
         }
         this.curStartTime = 0;
         this.cur = null;
         this.systemid = null;
         this.completing = false;
         this.notifyAnimDispatcher();
      }
      
      private function completeCur(param1:Boolean) : void
      {
         var error:Boolean = false;
         var nv:int = 0;
         var cv:Number = NaN;
         var clobber:Boolean = param1;
         if(clobber)
         {
            this.stopCur();
            return;
         }
         if(this.completing || !this.cur)
         {
            return;
         }
         if(this.curUseCompleteParam)
         {
            if(this.isCurPlaying)
            {
               try
               {
                  nv = !!this.next ? 2 : 1;
                  cv = this.driver.getEventParameterValueByName(this.systemid,"complete");
                  nv = Math.max(cv,nv);
                  if(!this.driver.setEventParameterValueByName(this.systemid,"complete",nv))
                  {
                     error = true;
                  }
               }
               catch(err:Error)
               {
                  logger.error("BattleMusic.completeCur " + def.url + " failed");
                  logger.error(err.getStackTrace());
                  error = true;
               }
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("BattleMusic.completeCur cur= [" + this.cur.id + "]");
               }
               this.completing = true;
               if(error)
               {
                  this.stopCur();
               }
            }
         }
         else if(this.isCurPlaying && !this.driver.isLooping(this.systemid))
         {
            this.completing = true;
         }
         else
         {
            this.stopCur();
         }
      }
   }
}
