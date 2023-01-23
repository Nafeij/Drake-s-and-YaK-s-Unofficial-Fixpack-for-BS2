package engine.battle.fsm.txn
{
   import engine.battle.fsm.BattleFsm;
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   
   public class BattleTxn_Base extends HttpJsonAction
   {
       
      
      public var fsm:BattleFsm;
      
      public function BattleTxn_Base(param1:String, param2:HttpRequestMethod, param3:Object, param4:Function, param5:BattleFsm, param6:ILogger)
      {
         super(param1,param2,param3,param4,param6);
         this.fsm = param5;
         resendOnFail = true;
      }
   }
}
