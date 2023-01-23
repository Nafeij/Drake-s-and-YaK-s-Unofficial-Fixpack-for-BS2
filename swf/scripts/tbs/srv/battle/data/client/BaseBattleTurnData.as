package tbs.srv.battle.data.client
{
   import engine.core.logging.ILogger;
   import flash.utils.getQualifiedClassName;
   
   public class BaseBattleTurnData extends BaseBattleData
   {
       
      
      public var turn:int;
      
      public var entity:String;
      
      public var ordinal:int;
      
      public function BaseBattleTurnData()
      {
         super();
      }
      
      public function setupBattleTurnData(param1:int, param2:String, param3:int, param4:String, param5:int) : void
      {
         setupBattleData(param1,param2);
         this.turn = param3;
         this.entity = param4;
         this.ordinal = param5;
      }
      
      override public function parseJson(param1:Object, param2:ILogger) : void
      {
         super.parseJson(param1,param2);
         this.turn = param1.turn;
         this.entity = param1.entity;
         this.ordinal = param1.ordinal;
      }
      
      override public function toString() : String
      {
         return getQualifiedClassName(this) + " [" + super.toString() + ", turn=" + this.turn + " entity=" + this.entity + "]";
      }
   }
}
