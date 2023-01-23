package engine.saga
{
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.def.IEntityDef;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.Stats;
   
   public class SagaSurvivalRecord_Ent
   {
       
      
      public var id:String;
      
      public var item:String;
      
      public var stats:Object;
      
      public function SagaSurvivalRecord_Ent()
      {
         this.stats = {};
         super();
      }
      
      public function fromBattleEnt(param1:IBattleEntity) : SagaSurvivalRecord_Ent
      {
         this.id = param1.def.id;
         this.item = !!param1.item ? param1.item.defid : null;
         this.recordStats(param1.def.stats);
         return this;
      }
      
      public function fromEntDef(param1:IEntityDef) : SagaSurvivalRecord_Ent
      {
         this.id = param1.id;
         this.item = !!param1.defItem ? param1.defItem.defid : null;
         this.recordStats(param1.stats);
         return this;
      }
      
      public function recordStats(param1:Stats) : void
      {
         this.recordStat(param1.getStat(StatType.STRENGTH));
         this.recordStat(param1.getStat(StatType.ARMOR));
         this.recordStat(param1.getStat(StatType.ARMOR_BREAK));
         this.recordStat(param1.getStat(StatType.WILLPOWER));
         this.recordStat(param1.getStat(StatType.RANK));
         this.recordStat(param1.getStat(StatType.EXERTION));
      }
      
      private function recordStat(param1:Stat) : void
      {
         this.stats[param1.type.abbrev] = param1.base;
      }
      
      public function fromJson(param1:Object) : SagaSurvivalRecord_Ent
      {
         this.id = param1.id;
         this.item = param1.item;
         this.stats = param1.stats;
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {
            "id":this.id,
            "stats":this.stats
         };
         if(this.item)
         {
            _loc1_.item = this.item;
         }
         return _loc1_;
      }
   }
}
