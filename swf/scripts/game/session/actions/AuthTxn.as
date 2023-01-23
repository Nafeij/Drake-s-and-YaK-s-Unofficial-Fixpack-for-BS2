package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   
   public class AuthTxn extends HttpJsonAction
   {
       
      
      public var credentials:Credentials;
      
      public var buildNumber:String;
      
      public function AuthTxn(param1:Credentials, param2:String, param3:Function, param4:ILogger)
      {
         this.credentials = param1;
         var _loc5_:Object = {
            "username":param1.vbb_name,
            "password":param1.password,
            "child_number":param1.childNumber,
            "steam_id":param1.steamId,
            "steam_auth_ticket":param1.steamAuthTicket,
            "display_name":param1.displayName,
            "client_config":new ClientConfigData(param2)
         };
         super("services/auth/login/" + param1.protocolVersion,HttpRequestMethod.POST,_loc5_,param3,param4);
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         if(jsonObject)
         {
            consumedTxn = true;
            if(!jsonObject.session_key)
            {
               logger.error("AuthAction no sessionKey for " + this.credentials.vbb_name);
            }
            if(!jsonObject.user_id)
            {
               logger.error("AuthAction no userId for " + this.credentials.vbb_name);
            }
            this.credentials.userId = jsonObject.user_id;
            this.credentials.vbb_name = jsonObject.vbb_name;
            this.credentials.displayName = jsonObject.display_name;
            this.credentials.sessionKey = jsonObject.session_key;
            this.buildNumber = jsonObject.build_number;
            logger.info("Assigned SessionKey " + this.credentials.sessionKey);
         }
      }
      
      public function get steamCredentials() : String
      {
         return jsonObject.steamCredentials;
      }
   }
}
