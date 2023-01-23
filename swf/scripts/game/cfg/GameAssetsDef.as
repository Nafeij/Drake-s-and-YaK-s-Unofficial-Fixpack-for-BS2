package game.cfg
{
   import engine.battle.BattleAssetsDef;
   
   public class GameAssetsDef
   {
      
      public static var dialogClazz:Class;
       
      
      private var config:GameConfig;
      
      public var battle:BattleAssetsDef;
      
      public function GameAssetsDef(param1:GameConfig)
      {
         this.battle = new BattleAssetsDef();
         super();
         this.config = param1;
      }
   }
}
