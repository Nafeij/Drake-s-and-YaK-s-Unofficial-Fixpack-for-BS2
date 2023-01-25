package engine.battle.wave
{
   import engine.battle.wave.def.BattleWaveDef;
   import engine.battle.wave.def.GuaranteedSpawnDef;
   import engine.battle.wave.def.WaveSpawnEntryDef;
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.entity.def.IEntityDef;
   import engine.saga.ISaga;
   import flash.errors.IllegalOperationError;
   
   public class BattleWave
   {
       
      
      public var waves:BattleWaves;
      
      public var def:BattleWaveDef;
      
      public var turnCount:int;
      
      public var logger:ILogger;
      
      private var _injuries:Vector.<String>;
      
      public var charsSwapped:int = 0;
      
      private var _saga:ISaga;
      
      private var _lowTurnWarningGiven:Boolean = false;
      
      public var waveNumber:int;
      
      public function BattleWave(param1:BattleWaves, param2:BattleWaveDef, param3:int)
      {
         var _loc4_:GuaranteedSpawnDef = null;
         var _loc5_:IEntityDef = null;
         var _loc6_:int = 0;
         var _loc7_:WaveSpawnEntryDef = null;
         var _loc9_:int = 0;
         this._injuries = new Vector.<String>();
         super();
         this.waves = param1;
         this.def = param2;
         this.logger = param1.logger;
         this.waveNumber = param3;
         this._saga = param1.board.getSaga();
         if(Boolean(param2.bucket) && Boolean(param2.bucket.guaranteedSpawns))
         {
            _loc6_ = int(param2.bucket.guaranteedSpawns.length);
         }
         var _loc8_:int = 0;
         while(_loc8_ < _loc6_)
         {
            _loc4_ = param2.bucket.guaranteedSpawns[_loc8_];
            BattleWave_Utils.VerifyLootTable(_loc4_.lootTable,this._saga.itemDefs,this._saga.logger);
            if(_loc4_.entityList.length < 1)
            {
               this.logger.error("ERROR: GuaranteedSpawnDef contained empty entity list!");
               ArrayUtil.removeAt(param2.bucket.guaranteedSpawns,_loc8_);
               _loc8_--;
            }
            else
            {
               _loc9_ = 0;
               while(_loc9_ < _loc4_.entityList.length)
               {
                  _loc7_ = _loc4_.entityList[_loc9_];
                  _loc5_ = this._saga.cast.getEntityDefById(_loc7_.entityId);
                  if(!_loc5_)
                  {
                     this.logger.error("ERROR: Invalid EntityDef for entity " + _loc7_.entityId + ". Removing from spawn list");
                     ArrayUtil.removeAt(_loc4_.entityList,_loc9_);
                     _loc9_--;
                  }
                  else
                  {
                     BattleWave_Utils.VerifyLootTable(_loc7_.lootTableOverride,this._saga.itemDefs,this._saga.logger);
                  }
                  _loc9_++;
               }
            }
            _loc8_++;
         }
         this.updateVars(this.turnsRemaining);
      }
      
      public function get injuryCount() : int
      {
         if(!this._injuries)
         {
            return 0;
         }
         return this._injuries.length;
      }
      
      public function getDebugString() : String
      {
         return this.toString();
      }
      
      public function toString() : String
      {
         var _loc1_:String = this.isComplete ? "COMPLETE" : "";
         return this.def + " number=" + this.waveNumber + " turn=" + this.turnCount + "/" + this.turnsPerWave + " " + _loc1_;
      }
      
      internal function advanceAll() : void
      {
         this.turnCount = this.turnsPerWave;
      }
      
      public function advanceTurn() : void
      {
         if(this.isComplete)
         {
            throw new IllegalOperationError("Cannot advance a completed turn");
         }
         ++this.turnCount;
         this.updateVars(this.turnsRemaining);
         if(this.turnsRemaining <= this.lowTurnWarning && !this._lowTurnWarningGiven)
         {
            this._lowTurnWarningGiven = true;
            this._saga.triggerBattleWaveLowTurnWarning();
         }
         this.logger.i("WAVE","advanceTurn " + this);
      }
      
      public function cleanup() : void
      {
         this.updateVars(-1);
         this._injuries.length = 0;
         this.charsSwapped = 0;
      }
      
      public function noticeInjury(param1:String) : void
      {
         if(this._injuries.indexOf(param1) < 0)
         {
            this._injuries.push(param1);
         }
      }
      
      private function updateVars(param1:int) : void
      {
         this._saga.setVar("wave_turns_remaining",param1);
      }
      
      public function get isComplete() : Boolean
      {
         return this.turnCount >= this.turnsPerWave;
      }
      
      public function get turnsRemaining() : int
      {
         return this.turnsPerWave - this.turnCount;
      }
      
      public function get isFinalWave() : Boolean
      {
         return this.waves.waveNumber >= this.waves.def.waves.length;
      }
      
      public function get turnsPerWave() : int
      {
         var _loc1_:BattleWaveDef = this.waves.previewNextWave();
         if(Boolean(_loc1_) && _loc1_.turnsPerWaveOverridden)
         {
            return _loc1_.turnsPerWave;
         }
         return this.waves.def.turnsPerWave;
      }
      
      public function get lowTurnWarning() : int
      {
         if(this.def.lowTurnWarningOverridden)
         {
            return this.def.lowTurnWarning;
         }
         return this.waves.def.lowTurnWarning;
      }
      
      public function get lowTurnColor() : String
      {
         if(this.def.lowTurnColorOverridden)
         {
            return this.def.lowTurnColor;
         }
         return this.waves.def.lowTurnColor;
      }
      
      public function get lossDangerAdjustment() : int
      {
         if(this.def.loseDangerAdjustmentOverridden)
         {
            return this.def.loseDangerAdjustment;
         }
         return this.waves.def.loseDangerAdjustment;
      }
   }
}
