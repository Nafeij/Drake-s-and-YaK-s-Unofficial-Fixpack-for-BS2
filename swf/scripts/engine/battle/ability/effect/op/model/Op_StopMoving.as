package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.tile.Tile;
   
   public class Op_StopMoving extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_StopMoving",
         "properties":{}
      };
       
      
      public function Op_StopMoving(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
      }
      
      override public function apply() : void
      {
         var _loc1_:Tile = null;
         target.mobility.stopMoving("Op_StopMoving: " + this);
         if(tile)
         {
            _loc1_ = target.board.tiles.getTile(target.x,target.y);
            target.setPos(_loc1_.x,_loc1_.y);
         }
      }
   }
}
