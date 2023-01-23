package engine.battle.board.def
{
   import engine.ability.def.StringIntPair;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.tile.def.TileLocationArea;
   
   public class BattleDeploymentArea
   {
       
      
      public var id:String;
      
      public var facing:BattleFacing;
      
      public var area:TileLocationArea;
      
      public var execAbilityId:StringIntPair;
      
      public function BattleDeploymentArea()
      {
         this.facing = BattleFacing.SW;
         this.area = new TileLocationArea();
         super();
      }
      
      public function clone() : BattleDeploymentArea
      {
         var _loc1_:BattleDeploymentArea = new BattleDeploymentArea();
         _loc1_.id = this.id;
         _loc1_.facing = this.facing;
         _loc1_.area = this.area.clone();
         _loc1_.execAbilityId = !!this.execAbilityId ? this.execAbilityId.clone() : null;
         return _loc1_;
      }
      
      public function toString() : String
      {
         return this.id + ":" + this.facing + (!!this.execAbilityId ? "execAbilityId=" + this.execAbilityId : "");
      }
      
      public function parseExecAbilityId(param1:String) : void
      {
         if(param1)
         {
            this.execAbilityId = new StringIntPair().parseString(param1,1);
         }
         else
         {
            this.execAbilityId = null;
         }
      }
   }
}
