package engine.battle.board.model
{
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.fsm.IBattleFsm;
   import engine.stat.def.StatType;
   import flash.utils.Dictionary;
   
   public class BattleSnapshot
   {
       
      
      public var url:String;
      
      public var boardId:String;
      
      public var entities:Dictionary;
      
      public var spawnerIndexesSpawned:Dictionary;
      
      private var entityOrder:Vector.<String>;
      
      public function BattleSnapshot(param1:BattleBoard)
      {
         var _loc2_:BattleEntity = null;
         var _loc3_:BattleBoard_Spawn = null;
         var _loc4_:* = null;
         var _loc5_:IBattleFsm = null;
         var _loc6_:BattleEntitySnapshot = null;
         var _loc7_:int = 0;
         this.entities = new Dictionary();
         this.spawnerIndexesSpawned = new Dictionary();
         this.entityOrder = new Vector.<String>();
         super();
         this.url = param1.def.sceneDef.url;
         this.boardId = param1.def.id;
         for each(_loc2_ in param1.entities)
         {
            _loc6_ = new BattleEntitySnapshot().makeSnapshot(_loc2_);
            this.entities[_loc2_.id] = _loc6_;
         }
         _loc3_ = param1._spawn;
         for(_loc4_ in _loc3_.spawnerIndexesSpawned)
         {
            _loc7_ = int(_loc4_);
            this.spawnerIndexesSpawned[_loc7_] = true;
         }
         _loc5_ = param1.fsm;
         if(_loc5_.order)
         {
            for each(_loc2_ in _loc5_.order.aliveOrder)
            {
               this.entityOrder.push(_loc2_.id);
            }
         }
      }
      
      public function applySnapshot(param1:BattleBoard) : void
      {
         var _loc3_:* = null;
         var _loc4_:Dictionary = null;
         var _loc5_:BattleEntitySnapshot = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         if(!param1)
         {
            return;
         }
         var _loc2_:BattleBoard_Spawn = param1._spawn;
         for(_loc3_ in this.spawnerIndexesSpawned)
         {
            _loc7_ = int(_loc3_);
            _loc2_.spawnerIndexesSpawned[_loc7_] = true;
         }
         _loc4_ = new Dictionary();
         for each(_loc6_ in this.entityOrder)
         {
            _loc5_ = this.entities[_loc6_];
            if(Boolean(_loc5_) && !_loc4_[_loc5_])
            {
               this.addEntity(param1,_loc5_);
               _loc4_[_loc5_] = _loc5_;
            }
         }
         for each(_loc5_ in this.entities)
         {
            if(!_loc4_[_loc5_])
            {
               this.addEntity(param1,_loc5_);
               _loc4_[_loc5_] = _loc5_;
            }
         }
      }
      
      private function addEntity(param1:BattleBoard, param2:BattleEntitySnapshot) : void
      {
         var _loc3_:BattleEntity = param1.addPartyMember(param2.partyName,param2.id,param2.partyId,param2.team,param2.deployment,param2.def,param2.partyType,0,param2.isAlly,param2.facing,param2.location,true) as BattleEntity;
         _loc3_.alive = param2.alive;
         _loc3_.enabled = true;
         _loc3_.active = true;
         _loc3_.deploymentReady = true;
         _loc3_.deploymentFinalized = true;
         if(_loc3_.stats.hasStat(StatType.STRENGTH))
         {
            _loc3_.stats.setBase(StatType.STRENGTH,param2.stat_str);
         }
         if(_loc3_.stats.hasStat(StatType.ARMOR))
         {
            _loc3_.stats.setBase(StatType.ARMOR,param2.stat_arm);
         }
         if(_loc3_.stats.hasStat(StatType.WILLPOWER))
         {
            _loc3_.stats.setBase(StatType.WILLPOWER,param2.stat_wil);
         }
      }
   }
}

import engine.battle.ability.effect.model.BattleFacing;
import engine.battle.board.model.BattlePartyType;
import engine.battle.entity.model.BattleEntity;
import engine.entity.def.EntityDef;
import engine.stat.def.StatType;
import engine.tile.Tile;
import engine.tile.def.TileLocation;

class BattleEntitySnapshot
{
    
   
   public var id:String;
   
   public var def:EntityDef;
   
   public var alive:Boolean;
   
   public var location:TileLocation;
   
   public var facing:BattleFacing;
   
   public var partyId:String;
   
   public var partyName:String;
   
   public var team:String;
   
   public var deployment:String;
   
   public var partyType:BattlePartyType;
   
   public var isAlly:Boolean;
   
   public var stat_str:int;
   
   public var stat_arm:int;
   
   public var stat_wil:int;
   
   public function BattleEntitySnapshot()
   {
      super();
   }
   
   public function makeSnapshot(param1:BattleEntity) : BattleEntitySnapshot
   {
      this.id = param1.id;
      var _loc2_:EntityDef = param1.def as EntityDef;
      if(_loc2_.spawner)
      {
         this.def = _loc2_.duplicate(_loc2_.id,param1.logger) as EntityDef;
      }
      else
      {
         this.def = _loc2_;
      }
      this.alive = param1.alive;
      var _loc3_:Tile = param1.tile;
      this.location = !!_loc3_ ? _loc3_.location : null;
      this.facing = param1.facing;
      this.partyId = param1.party.id;
      this.partyName = param1.party.partyName;
      this.team = param1.party.team;
      this.deployment = param1.party.deployment;
      this.partyType = param1.party.type;
      this.isAlly = param1.party.isAlly;
      this.stat_str = param1.stats.getValue(StatType.STRENGTH);
      this.stat_arm = param1.stats.getValue(StatType.ARMOR);
      this.stat_wil = param1.stats.getValue(StatType.WILLPOWER);
      return this;
   }
}
