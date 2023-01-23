package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class TourneyJoinTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/tourney/join";
       
      
      public var tourney_id:int;
      
      public function TourneyJoinTxn(param1:Credentials, param2:Function, param3:ILogger, param4:int)
      {
         this.tourney_id = param4;
         var _loc5_:Object = {"tourney_id":param4};
         super(PATH + param1.urlCred,HttpRequestMethod.POST,_loc5_,param2,param3);
         this.resendOnFail = true;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
         if(success)
         {
         }
      }
   }
}
