package game.cfg
{
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.entity.def.EntityListDefVars;
   import engine.entity.def.PartyDefVars;
   import tbs.srv.data.PurchasableUnitsData;
   import tbs.srv.util.PurchaseCountData;
   import tbs.srv.util.UnlockData;
   
   public class AccountInfoDefVars extends AccountInfoDef
   {
      
      public static const schema:Object = {
         "name":"AccountInfoDefVars",
         "type":"object",
         "properties":{
            "roster":{"type":EntityListDefVars.schema},
            "party":{"type":PartyDefVars.schema},
            "renown":{"type":"number"},
            "purchasable_units":{"type":PurchasableUnitsData.schema},
            "daily_login_streak":{"type":"number"},
            "daily_login_bonus":{"type":"number"},
            "unlocks":{
               "type":"array",
               "items":UnlockData.schema
            },
            "purchases":{
               "type":"array",
               "items":PurchaseCountData.schema
            },
            "roster_rows":{"type":"number"},
            "iap_sandbox":{
               "type":"boolean",
               "optional":true
            },
            "server_time":{
               "type":"number",
               "optional":true
            },
            "completed_tutorial":{
               "type":"boolean",
               "optional":true
            },
            "login_count":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public function AccountInfoDefVars(param1:Object, param2:GameConfig)
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:UnlockData = null;
         var _loc7_:PurchaseCountData = null;
         super(param2);
         EngineJsonDef.validateThrow(param1,schema,logger);
         legend.roster = new EntityListDefVars(param2.context.locale,logger).fromJson(param1.roster,logger,param2.abilityFactory,param2.classes,param2,true,param2.itemDefs);
         legend.party = new PartyDefVars(param1.party,legend.roster,logger);
         legend.renown = param1.renown;
         var _loc3_:PurchasableUnitsData = new PurchasableUnitsData();
         _loc3_.parseJson(param1.purchasable_units,logger);
         daily_login_streak = param1.daily_login_streak;
         daily_login_bonus = param1.daily_login_bonus;
         param2.purchasableUnits.update(_loc3_);
         for each(_loc4_ in param1.unlocks)
         {
            _loc6_ = new UnlockData();
            _loc6_.parseJson(_loc4_,logger);
            setUnlock(_loc6_);
         }
         for each(_loc5_ in param1.purchases)
         {
            _loc7_ = new PurchaseCountData();
            _loc7_.parseJson(_loc5_,logger);
            purchases.addPurchase(_loc7_);
         }
         legend.rosterRowCount = param1.roster_rows;
         iap_sandbox = param1.iap_sandbox;
         if(param1.server_time != undefined)
         {
            server_delta_time = param1.server_time - new Date().time;
            logger.info("AccountInfoDefVars server_delta_time=" + server_delta_time);
         }
         completed_tutorial = BooleanVars.parse(param1.completed_tutorial,false);
         if(param1.login_count != undefined)
         {
            login_count = param1.login_count;
         }
      }
   }
}
