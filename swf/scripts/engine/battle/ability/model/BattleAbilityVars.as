package engine.battle.ability.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.def.PointVars;
   import engine.tile.Tile;
   import flash.geom.Point;
   import tbs.srv.battle.data.client.BattleActionData;
   
   public class BattleAbilityVars
   {
       
      
      public function BattleAbilityVars()
      {
         super();
      }
      
      public static function parse(param1:BattleActionData, param2:IBattleBoard, param3:ILogger, param4:IBattleAbilityManager) : BattleAbility
      {
         var _loc10_:Object = null;
         var _loc11_:Point = null;
         var _loc12_:Object = null;
         var _loc13_:String = null;
         var _loc14_:IBattleEntity = null;
         var _loc15_:Tile = null;
         var _loc5_:BattleAbilityDef = param4.getFactory.fetch(param1.action) as BattleAbilityDef;
         var _loc6_:int = int(param1.level);
         var _loc7_:BattleAbilityDef = _loc5_.getBattleAbilityDefLevel(_loc6_) as BattleAbilityDef;
         var _loc8_:IBattleEntity = param2.getEntity(param1.entity);
         var _loc9_:BattleAbility = new BattleAbility(_loc8_,_loc7_,param4);
         for each(_loc10_ in param1.target_ids)
         {
            _loc13_ = _loc10_ as String;
            _loc14_ = param2.getEntity(_loc13_);
            if(param1.target_ids.length == 1)
            {
               _loc9_.targetSet.setTarget(_loc14_);
            }
            else
            {
               _loc9_.targetSet.addTarget(_loc14_);
            }
         }
         _loc11_ = new Point();
         for each(_loc12_ in param1.tiles)
         {
            PointVars.parse(_loc12_,param3,_loc11_);
            _loc15_ = param2.tiles.getTile(_loc11_.x,_loc11_.y);
            _loc9_.targetSet.addTile(_loc15_);
         }
         _loc9_.internalSetexecutedId(param1.executed_id);
         return _loc9_;
      }
      
      public static function save(param1:IBattleAbility) : Object
      {
         var _loc3_:IBattleEntity = null;
         var _loc4_:Tile = null;
         var _loc5_:Point = null;
         var _loc2_:Object = {
            "action":param1.def.id,
            "level":param1.def.level,
            "entity":param1.caster.id,
            "targetIds":[],
            "tiles":[],
            "executedId":param1.executedId
         };
         for each(_loc3_ in param1.targetSet.targets)
         {
            _loc2_.targetIds.push(_loc3_.id);
         }
         for each(_loc4_ in param1.targetSet.tiles)
         {
            _loc5_ = new Point(_loc4_.x,_loc4_.y);
            _loc2_.tiles.push(PointVars.save(_loc5_));
         }
         return _loc2_;
      }
   }
}
