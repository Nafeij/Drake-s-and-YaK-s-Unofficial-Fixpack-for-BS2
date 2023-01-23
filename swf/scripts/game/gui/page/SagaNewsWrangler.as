package game.gui.page
{
   import engine.core.logging.ILogger;
   import engine.core.pref.PrefBag;
   import engine.gui.SagaNews;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefWrangler;
   
   public class SagaNewsWrangler extends DefWrangler
   {
       
      
      public var news:SagaNews;
      
      private var prefs:PrefBag;
      
      public function SagaNewsWrangler(param1:String, param2:ILogger, param3:ResourceManager, param4:Function, param5:PrefBag)
      {
         this.prefs = param5;
         super(param1,param2,param3,param4);
      }
      
      override protected function handleDefrComplete() : Boolean
      {
         try
         {
            this.news = new SagaNews(this.prefs);
            this.news.fromJson(url,vars,logger);
            return true;
         }
         catch(e:Error)
         {
            logger.error("Failed to load the news from json via [" + url + "]");
            return false;
         }
      }
   }
}
