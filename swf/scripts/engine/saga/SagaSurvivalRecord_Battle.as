package engine.saga
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.sim.IBattleParty;
   
   public class SagaSurvivalRecord_Battle
   {
       
      
      public var progress:int;
      
      public var board_id:String;
      
      public var deaths:Array;
      
      public var party:Vector.<SagaSurvivalRecord_Ent>;
      
      public var enemies:Vector.<SagaSurvivalRecord_Ent>;
      
      public var enemies2:Vector.<SagaSurvivalRecord_Ent>;
      
      public var total_reloads:int;
      
      public var total_kills:int;
      
      public var total_deaths:int;
      
      public var total_minutes:int;
      
      public var total_recruits:int;
      
      public var renown:int;
      
      public function SagaSurvivalRecord_Battle()
      {
         this.deaths = [];
         this.party = new Vector.<SagaSurvivalRecord_Ent>();
         this.enemies = new Vector.<SagaSurvivalRecord_Ent>();
         this.enemies2 = new Vector.<SagaSurvivalRecord_Ent>();
         super();
      }
      
      private static function fromJson_entities(param1:Array, param2:Vector.<SagaSurvivalRecord_Ent>) : void
      {
         var _loc3_:Object = null;
         var _loc4_:SagaSurvivalRecord_Ent = null;
         if(!param1)
         {
            return;
         }
         for each(_loc3_ in param1)
         {
            _loc4_ = new SagaSurvivalRecord_Ent().fromJson(_loc3_);
            param2.push(_loc4_);
         }
      }
      
      private static function toJson_entities(param1:Vector.<SagaSurvivalRecord_Ent>) : Array
      {
         var _loc3_:SagaSurvivalRecord_Ent = null;
         var _loc4_:Object = null;
         var _loc2_:Array = [];
         for each(_loc3_ in param1)
         {
            _loc4_ = _loc3_.toJson();
            _loc2_.push(_loc4_);
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object) : SagaSurvivalRecord_Battle
      {
         this.progress = param1.progress;
         this.total_reloads = param1.total_reloads;
         this.total_kills = param1.total_kills;
         this.total_deaths = param1.total_deaths;
         this.total_minutes = param1.total_minutes;
         this.total_recruits = param1.total_recruits;
         this.renown = param1.renown;
         this.deaths = param1.deaths;
         this.board_id = param1.board_id;
         fromJson_entities(param1.party,this.party);
         fromJson_entities(param1.enemies,this.enemies);
         fromJson_entities(param1.enemies2,this.enemies2);
         return this;
      }
      
      public function toJson() : Object
      {
         return {
            "progress":this.progress,
            "total_reloads":this.total_reloads,
            "total_kills":this.total_kills,
            "total_deaths":this.total_deaths,
            "total_minutes":this.total_minutes,
            "total_recruits":this.total_recruits,
            "renown":this.renown,
            "deaths":this.deaths,
            "board_id":this.board_id,
            "party":toJson_entities(this.party),
            "enemies":toJson_entities(this.enemies),
            "enemies2":toJson_entities(this.enemies2)
         };
      }
      
      public function storeStart(param1:IBattleBoard) : void
      {
         this.storeParty(param1);
         this.storeEnemies(param1);
         this.board_id = param1.def.id;
         var _loc2_:Saga = Saga.instance;
         this.progress = _loc2_.survivalProgress;
      }
      
      public function storeRespawn(param1:IBattleBoard) : void
      {
         this.storeEnemies(param1);
      }
      
      public function storeEnd(param1:IBattleBoard) : void
      {
         var _loc3_:String = null;
         if(param1.fsm.unitsInjured)
         {
            for each(_loc3_ in param1.fsm.unitsInjured)
            {
               this.deaths.push(_loc3_);
            }
         }
         var _loc2_:Saga = Saga.instance;
         this.total_reloads = _loc2_.survivalReloadCount;
         this.total_deaths = _loc2_.getVarInt(SagaVar.VAR_SURVIVAL_NUM_DEATHS);
         this.total_kills = _loc2_.getVarInt("tot_kills");
         this.total_minutes = _loc2_.getVarInt(SagaVar.VAR_SURVIVAL_ELAPSED_SEC) / 60;
         this.total_recruits = _loc2_.getVarInt(SagaVar.VAR_SURVIVAL_NUM_RECRUITS);
         this.renown = _loc2_.getVarInt(SagaVar.VAR_RENOWN);
      }
      
      public function storeParty(param1:IBattleBoard) : void
      {
         var _loc2_:IBattleParty = param1.getPartyById("0");
         this.fromParty(_loc2_);
      }
      
      public function storeEnemies(param1:IBattleBoard) : void
      {
         var _loc2_:IBattleParty = param1.getPartyById("npc");
         this.fromParty(_loc2_);
      }
      
      public function fromParty(param1:IBattleParty) : void
      {
         var _loc2_:Vector.<SagaSurvivalRecord_Ent> = null;
         var _loc4_:IBattleEntity = null;
         var _loc5_:SagaSurvivalRecord_Ent = null;
         if(param1.isPlayer)
         {
            _loc2_ = this.party;
         }
         else
         {
            if(!param1.isEnemy)
            {
               throw new ArgumentError("no");
            }
            if(this.enemies.length)
            {
               _loc2_ = this.enemies2;
            }
            else
            {
               _loc2_ = this.enemies;
            }
         }
         var _loc3_:int = 0;
         while(_loc3_ < param1.numMembers)
         {
            _loc4_ = param1.getMember(_loc3_);
            if(_loc4_.alive)
            {
               _loc5_ = new SagaSurvivalRecord_Ent().fromEntDef(_loc4_.def);
               _loc2_.push(_loc5_);
            }
            _loc3_++;
         }
      }
   }
}
