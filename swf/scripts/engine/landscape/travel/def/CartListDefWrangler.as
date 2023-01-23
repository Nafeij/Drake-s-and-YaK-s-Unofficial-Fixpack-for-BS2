package engine.landscape.travel.def
{
   import engine.core.logging.ILogger;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefWrangler;
   
   public class CartListDefWrangler extends DefWrangler
   {
       
      
      public var cartDefs:CartListDef;
      
      public function CartListDefWrangler(param1:String, param2:ILogger, param3:ResourceManager, param4:Function)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function handleDefrComplete() : Boolean
      {
         try
         {
            this.cartDefs = new CartListDef(logger).fromJson(vars);
         }
         catch(e:Error)
         {
            logger.error("Failed to parse vars: " + e.getStackTrace());
         }
         return true;
      }
   }
}
