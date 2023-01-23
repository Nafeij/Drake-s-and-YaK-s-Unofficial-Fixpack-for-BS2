package engine.saga
{
   import engine.entity.def.ITitleListDef;
   import engine.saga.action.ActionDef;
   import engine.saga.happening.HappeningDef;
   
   public interface ISagaDef extends IVariableDefProvider
   {
       
      
      function findActionsForSceneUrl(param1:String, param2:Vector.<ActionDef>) : void;
      
      function findActionsForHappening(param1:HappeningDef, param2:Vector.<ActionDef>) : void;
      
      function get titleDefs() : ITitleListDef;
   }
}
