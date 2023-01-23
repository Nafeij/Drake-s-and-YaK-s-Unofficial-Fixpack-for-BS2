package tbs.srv.battle.data.client
{
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.tile.Tile;
   import engine.tile.TileLocationVars;
   import engine.tile.def.TileLocation;
   import flash.geom.Point;
   
   public class BattleActionData extends BaseBattleTurnData
   {
       
      
      public var level:int;
      
      public var action:String;
      
      public var tiles:Vector.<TileLocation>;
      
      public var target_ids:Vector.<String>;
      
      public var executed_id:int;
      
      public var terminator:Boolean;
      
      public function BattleActionData()
      {
         this.tiles = new Vector.<TileLocation>();
         this.target_ids = new Vector.<String>();
         super();
      }
      
      override public function toString() : String
      {
         return super.toString() + ", [level=" + this.level + ", action=" + this.action + ", id=" + this.executed_id + ", target_ids=" + this.target_ids + ", tiles=" + this.tiles + "]";
      }
      
      public function setupBattleActionData(param1:int, param2:int, param3:String, param4:IBattleAbility, param5:int, param6:Boolean) : void
      {
         var _loc7_:IBattleEntity = null;
         var _loc8_:Tile = null;
         var _loc9_:Point = null;
         setupBattleTurnData(param1,param3,param2,param4.caster.id,param5);
         this.action = param4.def.id;
         this.level = param4.def.level;
         entity = param4.caster.id;
         this.executed_id = param4.executedId;
         this.terminator = param6;
         for each(_loc7_ in param4.targetSet.targets)
         {
            this.target_ids.push(_loc7_.id);
         }
         for each(_loc8_ in param4.targetSet.tiles)
         {
            _loc9_ = new Point(_loc8_.x,_loc8_.y);
            this.tiles.push(_loc8_.location);
         }
      }
      
      override public function parseJson(param1:Object, param2:ILogger) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         super.parseJson(param1,param2);
         for each(_loc3_ in param1.tiles)
         {
            this.tiles.push(TileLocationVars.parse(_loc3_,param2));
         }
         for each(_loc4_ in param1.target_ids)
         {
            this.target_ids.push(_loc4_ as String);
         }
         this.action = param1.action;
         this.level = param1.level;
         ordinal = param1.ordinal;
         this.terminator = param1.terminator;
      }
   }
}
