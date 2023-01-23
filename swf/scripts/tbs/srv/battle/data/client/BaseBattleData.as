package tbs.srv.battle.data.client
{
   import avmplus.getQualifiedClassName;
   import engine.core.logging.ILogger;
   
   public class BaseBattleData
   {
       
      
      public var user_id:int;
      
      public var battle_id:String;
      
      public function BaseBattleData()
      {
         super();
      }
      
      public function setupBattleData(param1:int, param2:String) : void
      {
         this.user_id = param1;
         this.battle_id = param2;
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.user_id = param1.user_id;
         this.battle_id = param1.battle_id;
      }
      
      public function toString() : String
      {
         return getQualifiedClassName(this) + " [user=" + this.user_id + " battle=" + this.battle_id + "]";
      }
   }
}
