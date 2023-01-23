package engine.saga.action
{
   import engine.core.util.StringUtil;
   import engine.saga.Saga;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class Action_OpenUrl extends Action
   {
       
      
      public function Action_OpenUrl(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(!def.url)
         {
            return;
         }
         if(!StringUtil.startsWith(def.url,"http://") && !StringUtil.startsWith(def.url,"https://"))
         {
            return;
         }
         var _loc1_:URLRequest = new URLRequest(def.url);
         navigateToURL(_loc1_);
         end();
      }
   }
}
