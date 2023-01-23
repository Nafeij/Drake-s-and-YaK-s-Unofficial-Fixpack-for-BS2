package engine.entity
{
   import engine.core.logging.ILogger;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefWrangler;
   
   public class UnitStatCostsWrangler extends DefWrangler
   {
       
      
      public var statCosts:UnitStatCosts;
      
      public function UnitStatCostsWrangler(param1:String, param2:ILogger, param3:ResourceManager, param4:Function)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function handleDefrComplete() : Boolean
      {
         try
         {
            this.statCosts = new UnitStatCostsVars(vars,logger);
         }
         catch(e:Error)
         {
            logger.error("Failed to parse vars: " + e.getStackTrace());
         }
         return true;
      }
   }
}
