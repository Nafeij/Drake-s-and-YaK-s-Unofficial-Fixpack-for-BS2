package engine.entity
{
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.entity.def.ItemListDef;
   import engine.entity.def.ItemListDefVars;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefWrangler;
   
   public class ItemListDefWrangler extends DefWrangler
   {
       
      
      public var itemDefs:ItemListDef;
      
      private var locale:Locale;
      
      private var abilities:BattleAbilityDefFactory;
      
      public function ItemListDefWrangler(param1:String, param2:ILogger, param3:Locale, param4:BattleAbilityDefFactory, param5:ResourceManager, param6:Function)
      {
         this.locale = param3;
         this.abilities = param4;
         super(param1,param2,param5,param6);
      }
      
      override protected function handleDefrComplete() : Boolean
      {
         try
         {
            this.itemDefs = new ItemListDefVars(this.locale,logger).fromJson(vars,this.abilities,logger);
         }
         catch(e:Error)
         {
            logger.error("Failed to parse vars: " + e.getStackTrace());
         }
         return true;
      }
   }
}
