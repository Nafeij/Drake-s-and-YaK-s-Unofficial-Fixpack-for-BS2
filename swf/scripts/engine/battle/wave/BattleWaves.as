package engine.battle.wave
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.wave.def.BattleWaveDef;
   import engine.battle.wave.def.BattleWavesDef;
   import engine.battle.wave.def.GuaranteedSpawnDef;
   import engine.battle.wave.def.LootTableEntryDef;
   import engine.battle.wave.def.WaveSpawnEntryDef;
   import engine.core.analytic.Ga;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityAssetBundleManager;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.ItemDef;
   import engine.resource.BitmapResource;
   import engine.resource.ResourceCollector;
   import engine.saga.ISaga;
   import engine.saga.SagaBucket;
   import engine.saga.SagaInstance;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BattleWaves extends EventDispatcher
   {
      
      public static const TURNS_REMAINING_UPDATED:String = "BattleWaves.TURNS_REMAINING_UPDATED";
       
      
      public var board:IBattleBoard;
      
      public var def:BattleWavesDef;
      
      public var fsm:IBattleFsm;
      
      public var waveNumber:int;
      
      public var wave:BattleWave;
      
      public var logger:ILogger;
      
      public var lostAWave:Boolean = false;
      
      public var _isPlayerVictorious:Boolean;
      
      public function BattleWaves(param1:IBattleBoard, param2:BattleWavesDef)
      {
         super();
         this.board = param1;
         this.def = param2;
         this.fsm = param1.fsm;
         this.logger = param1.logger;
      }
      
      public function getDebugString() : String
      {
         var _loc1_:* = "";
         _loc1_ += "WAVES: " + this.waveNumber + "/" + this.def.numWaves + "\n";
         _loc1_ += "       isWaveComplete=" + this.isWaveComplete + "\n";
         _loc1_ += "       hasMoreWaves=" + this.hasMoreWaves + "\n";
         _loc1_ += "       isPlayerVictorious=" + this.isPlayerVictorious + "\n";
         _loc1_ += "WAVE:\n";
         return _loc1_ + (!!this.wave ? this.wave.getDebugString() : "NULL");
      }
      
      public function cleanup() : void
      {
         this.board = null;
         this.def = null;
      }
      
      public function handleBattleEnabled() : void
      {
         if(!this.def.waves || this.def.waves.length < 1)
         {
            throw new IllegalOperationError("BattleWaves enabled with bad definition, disabling Waves.");
         }
         this.nextWave();
      }
      
      public function advanceAll() : void
      {
         this.logger.i("WAVE","advanceAll");
         if(!this.wave || this.wave.isComplete)
         {
            return;
         }
         this.wave.advanceAll();
         dispatchEvent(new Event(TURNS_REMAINING_UPDATED));
      }
      
      public function handlePlayerTurnEnd() : void
      {
         this.logger.i("WAVE","handlePlayerTurn");
         if(!this.wave || this.wave.isComplete)
         {
            return;
         }
         this.wave.advanceTurn();
         dispatchEvent(new Event(TURNS_REMAINING_UPDATED));
      }
      
      public function nextWave() : void
      {
         if(this.wave)
         {
            this.reportWaveAnalytics(this.wave);
            this.wave.cleanup();
            this.wave = null;
         }
         this.isPlayerVictorious = false;
         if(this.waveNumber < 0 || this.waveNumber >= this.def.numWaves)
         {
            throw new RangeError("Next Wave called with invalid waveNumber: " + this.waveNumber);
         }
         this.wave = new BattleWave(this,this.def.waves[this.waveNumber],this.waveNumber);
         ++this.waveNumber;
         this.logger.i("WAVE","nextWave " + this.wave);
         dispatchEvent(new Event(TURNS_REMAINING_UPDATED));
      }
      
      public function set isPlayerVictorious(param1:Boolean) : void
      {
         this._isPlayerVictorious = param1;
      }
      
      public function get isPlayerVictorious() : Boolean
      {
         return this._isPlayerVictorious;
      }
      
      public function get isWaveComplete() : Boolean
      {
         if(!this.wave || !this.wave.isComplete)
         {
            return false;
         }
         return true;
      }
      
      public function get hasMoreWaves() : Boolean
      {
         if(this.waveNumber >= this.def.numWaves)
         {
            return false;
         }
         return true;
      }
      
      public function get readyToSpawnWave() : Boolean
      {
         if(!this.wave || !this.wave.isComplete)
         {
            return false;
         }
         if(this.waveNumber >= this.def.numWaves)
         {
            return false;
         }
         return true;
      }
      
      public function previewNextWave() : BattleWaveDef
      {
         if(this.waveNumber >= this.def.numWaves)
         {
            return null;
         }
         return this.def.waves[this.waveNumber];
      }
      
      public function performResourceCollection() : void
      {
         var _loc2_:BattleWaveDef = null;
         var _loc3_:String = null;
         var _loc4_:IEntityAssetBundleManager = null;
         var _loc5_:SagaBucket = null;
         var _loc6_:GuaranteedSpawnDef = null;
         var _loc7_:LootTableEntryDef = null;
         var _loc8_:ItemDef = null;
         var _loc9_:WaveSpawnEntryDef = null;
         var _loc10_:IEntityDef = null;
         if(!ResourceCollector.ENABLED)
         {
            return;
         }
         var _loc1_:ISaga = SagaInstance.instance;
         for each(_loc2_ in this.def.waves)
         {
            _loc3_ = _loc2_.bucket.bucketId;
            if(_loc3_)
            {
               _loc5_ = _loc1_.getSagaBucket(_loc3_);
               this.board.performResourceCollectionBucket(_loc5_);
            }
            _loc4_ = this.board.entityAssetBundleManager;
            if(_loc2_.bucket.guaranteedSpawns)
            {
               for each(_loc6_ in _loc2_.bucket.guaranteedSpawns)
               {
                  if(_loc6_.lootTable)
                  {
                     for each(_loc7_ in _loc6_.lootTable)
                     {
                        _loc8_ = _loc1_.itemDefs.getItemDef(_loc7_.itemId);
                        if(Boolean(_loc8_) && Boolean(_loc8_.icon))
                        {
                           this.board.resman.getResource(_loc8_.icon,BitmapResource);
                        }
                     }
                  }
                  if(_loc6_.entityList)
                  {
                     for each(_loc9_ in _loc6_.entityList)
                     {
                        _loc10_ = _loc1_.cast.getEntityDefById(_loc9_.entityId);
                        if(_loc10_)
                        {
                           _loc4_.getEntityPreloadById(_loc10_.id,null,false,false,true);
                        }
                        if(_loc9_.lootTableOverride)
                        {
                           for each(_loc7_ in _loc9_.lootTableOverride)
                           {
                              _loc8_ = _loc1_.itemDefs.getItemDef(_loc7_.itemId);
                              if(Boolean(_loc8_) && Boolean(_loc8_.icon))
                              {
                                 this.board.resman.getResource(_loc8_.icon,BitmapResource);
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function reportWaveAnalytics(param1:BattleWave) : void
      {
         var _loc2_:String = "wave";
         var _loc3_:String = this.board.scene.def.id + ":" + this.board.def.id;
         var _loc4_:* = (this.waveNumber - 1).toString() + "_";
         Ga.normal(_loc2_,_loc3_,_loc4_ + "turns_remaining",param1.turnsRemaining);
         Ga.normal(_loc2_,_loc3_,_loc4_ + "injuries",param1.injuryCount);
         Ga.normal(_loc2_,_loc3_,_loc4_ + "characters_swapped",param1.charsSwapped);
         Ga.normal(_loc2_,_loc3_,_loc4_ + "complete",int(this.isPlayerVictorious));
      }
      
      public function noticeInjury(param1:String) : void
      {
         if(this.wave)
         {
            this.wave.noticeInjury(param1);
         }
      }
   }
}
