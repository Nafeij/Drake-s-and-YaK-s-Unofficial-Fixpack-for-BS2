package engine.saga.convo.def
{
   import engine.core.logging.ILogger;
   
   public class ConvoLinkDefVars extends ConvoLinkDef
   {
      
      public static var CHECK_LINK_PATHS:Boolean;
       
      
      public function ConvoLinkDefVars(param1:ConvoDef)
      {
         super(param1);
      }
      
      public function fromOptionJson(param1:Object, param2:ILogger) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         path = param1.linkPath;
         if(!path)
         {
            if(CHECK_LINK_PATHS)
            {
               param2.error("Convo Link Option [" + param1.option + "] has no link path");
            }
         }
         if(param1.notIfConditions)
         {
            for each(_loc3_ in param1.notIfConditions)
            {
               conditions.addNotIfCondition(_loc3_.notIfCondition);
            }
         }
         if(param1.ifConditions)
         {
            for each(_loc4_ in param1.ifConditions)
            {
               conditions.addIfCondition(_loc4_.ifCondition);
            }
         }
      }
      
      public function fromDivertJson(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         for(_loc2_ in param1)
         {
            _loc3_ = param1[_loc2_];
            if(_loc2_ == "divert")
            {
               path = _loc3_ as String;
            }
            else if(_loc2_ == "notIfCondition")
            {
               if(!conditions)
               {
                  conditions = new ConvoConditionsDef();
               }
               conditions.addNotIfCondition(_loc3_ as String);
            }
            else if(_loc2_ == "ifCondition")
            {
               if(!conditions)
               {
                  conditions = new ConvoConditionsDef();
               }
               conditions.addIfCondition(_loc3_ as String);
            }
         }
      }
   }
}
