package engine.battle.ai.def
{
   import engine.battle.ai.phase.AiPhase_Plan;
   import engine.battle.ai.plan.AiPlanningModule;
   import engine.battle.ai.plan.AiPlanningModule_Stall;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class AiCtor
   {
      
      public static var clazzMap:Dictionary;
       
      
      public function AiCtor()
      {
         super();
      }
      
      public static function init() : void
      {
         if(clazzMap)
         {
            return;
         }
         clazzMap = new Dictionary();
         clazzMap[AiPlanningModuleDef_Stall] = AiPlanningModule_Stall;
      }
      
      public static function ctorPlanningModule(param1:AiPhase_Plan, param2:AiPlanningModuleDef) : AiPlanningModule
      {
         if(!clazzMap)
         {
            throw new IllegalOperationError("not init");
         }
         var _loc3_:Class = getDefinitionByName(getQualifiedClassName(param2)) as Class;
         var _loc4_:Class = clazzMap[_loc3_];
         if(_loc4_ == null)
         {
            throw new ArgumentError("unknown def " + param2 + " clazz " + _loc3_);
         }
         return new _loc4_(param1,param2);
      }
   }
}
