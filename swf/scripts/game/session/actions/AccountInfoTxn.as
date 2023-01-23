package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.entity.def.IEntityDef;
   import game.cfg.AccountInfoDefVars;
   import game.cfg.GameConfig;
   
   public class AccountInfoTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/account/info";
       
      
      public var config:GameConfig;
      
      private var initialized:Boolean;
      
      public function AccountInfoTxn(param1:Function, param2:GameConfig)
      {
         super(PATH + param2.fsm.credentials.urlCred,HttpRequestMethod.GET,null,param1,param2.logger);
         this.config = param2;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         var ac:AccountInfoDefVars = null;
         var i:int = 0;
         var ent:IEntityDef = null;
         if(jsonObject)
         {
            consumedTxn = true;
            try
            {
               ac = new AccountInfoDefVars(jsonObject,this.config);
               if(ac.legend.roster.numEntityDefs > 0)
               {
                  i = 0;
                  while(i < ac.legend.roster.numEntityDefs)
                  {
                     ent = ac.legend.roster.getEntityDef(i);
                     if(this.config.runMode.isClassAvailable(ent.entityClass.id))
                     {
                        i++;
                     }
                     else
                     {
                        logger.info("AccountInfoTxn PRUNING " + ent);
                        ac.legend.roster.removeEntityDef(ent);
                        ac.legend.party.removeMember(ent.id);
                     }
                  }
                  if(this.config.stashed_account_info)
                  {
                     this.config.stashed_account_info = ac;
                  }
                  else
                  {
                     this.config.accountInfo = ac;
                  }
                  if(this.config.options.partyOverride)
                  {
                     ac.legend.party.reset(this.config.options.partyOverride);
                  }
               }
            }
            catch(e:Error)
            {
               config.logger.error("AccountInfoAction fail: " + e.getStackTrace());
            }
         }
         else
         {
            this.config.accountInfo = null;
         }
      }
   }
}
