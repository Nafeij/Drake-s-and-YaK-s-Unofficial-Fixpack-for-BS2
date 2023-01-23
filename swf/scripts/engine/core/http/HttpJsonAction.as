package engine.core.http
{
   import engine.core.logging.ILogger;
   
   public class HttpJsonAction extends HttpAction
   {
       
      
      protected var m_jsonObject:Object;
      
      public var message:String;
      
      public function HttpJsonAction(param1:String, param2:HttpRequestMethod, param3:Object, param4:Function, param5:ILogger)
      {
         super(param1,param2,param3,param4,param5);
      }
      
      public function get jsonObject() : Object
      {
         return this.m_jsonObject;
      }
      
      override protected function handleResponseProcessing() : void
      {
         var f:String = null;
         if(response)
         {
            f = response.charAt(0);
            if(f == "{" || f == "[")
            {
               try
               {
                  this.m_jsonObject = JSON.parse(response);
               }
               catch(e:Error)
               {
                  logger.error("HttpJsonAction " + this + " Failed to process JSON response: " + response + "\n" + e.message);
               }
            }
            else
            {
               this.message = response;
               if(!success)
               {
                  logger.error("HttpJsonAction " + this + " Server Error: " + responseCode + ": " + this.message);
               }
               else
               {
                  logger.error("HttpJsonAction " + this + " Server Response: " + responseCode + ": " + this.message);
               }
            }
         }
         try
         {
            this.handleJsonResponseProcessing();
         }
         catch(e:Error)
         {
            logger.error("HttpJsonAction " + this + " Failed to handle JSON processing: " + e + ": " + e.getStackTrace());
         }
      }
      
      protected function handleJsonResponseProcessing() : void
      {
      }
   }
}
