package engine.saga.happening
{
   public interface IHappeningProvider
   {
       
      
      function executeHappeningById(param1:String, param2:IHappeningDefProvider, param3:*, param4:Boolean = true) : IHappening;
      
      function preExecuteHappeningDef(param1:HappeningDef, param2:*) : IHappening;
      
      function getHappeningDefById(param1:String, param2:IHappeningDefProvider, param3:Boolean = true) : HappeningDef;
      
      function executeHappeningDef(param1:HappeningDef, param2:*) : IHappening;
      
      function gotoBookmark(param1:String, param2:Boolean) : void;
   }
}
