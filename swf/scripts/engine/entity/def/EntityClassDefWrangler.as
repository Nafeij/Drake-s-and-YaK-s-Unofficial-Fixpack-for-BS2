package engine.entity.def
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefWrangler;
   
   public class EntityClassDefWrangler extends DefWrangler
   {
       
      
      public var manager:EntityClassDefList;
      
      private var locale:Locale;
      
      public function EntityClassDefWrangler(param1:String, param2:ILogger, param3:ResourceManager, param4:Locale, param5:Function)
      {
         if(param2.isDebugEnabled)
         {
            param2.debug("EntityClassDefWrangler ctor " + param1);
         }
         this.locale = param4;
         if(!param4)
         {
            param2.error("No logger provided to EntityClassDefWrangler " + param1);
         }
         super(param1,param2,param3,param5);
      }
      
      override protected function handleDefrComplete() : Boolean
      {
         super.handleDefrComplete();
         if(logger.isDebugEnabled)
         {
            logger.debug("EntityClassDefWrangler.handleDefrComplete PARSING");
         }
         this.manager = new EntityClassDefListVars().fromJson(vars,logger,this.locale);
         if(logger.isDebugEnabled)
         {
            logger.debug("EntityClassDefWrangler.handleDefrComplete PARSED");
         }
         return true;
      }
   }
}
