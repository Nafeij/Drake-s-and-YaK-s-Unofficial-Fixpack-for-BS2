package engine.battle.entity.model
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.sound.ISoundDriver;
   
   public class BattleEntityFactory
   {
       
      
      public function BattleEntityFactory()
      {
         super();
      }
      
      public static function create(param1:BattleBoard, param2:String, param3:IEntityDef, param4:IBattleParty, param5:ISoundDriver, param6:ILogger) : BattleEntity
      {
         if(!param3 || !param1)
         {
            throw new ArgumentError("BattleEntityFactory null def or board: def=" + param3 + ", board=" + param1 + " for id=" + param2);
         }
         return new BattleEntity(param3,param2,param1,param5,param6,param4);
      }
   }
}
