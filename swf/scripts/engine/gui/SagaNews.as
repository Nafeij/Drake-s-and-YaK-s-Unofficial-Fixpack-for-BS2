package engine.gui
{
   import engine.core.logging.ILogger;
   import engine.core.pref.PrefBag;
   import engine.core.util.StableJson;
   import flash.utils.Dictionary;
   
   public class SagaNews
   {
       
      
      public var baseUrl:String;
      
      public var url:String;
      
      public var entries:Vector.<SagaNewsEntry>;
      
      public var prefs:PrefBag;
      
      public var disabledPlatforms:Dictionary;
      
      public function SagaNews(param1:PrefBag)
      {
         this.entries = new Vector.<SagaNewsEntry>();
         this.disabledPlatforms = new Dictionary();
         super();
         this.prefs = param1;
      }
      
      public function cleanup() : void
      {
         var _loc1_:SagaNewsEntry = null;
         for each(_loc1_ in this.entries)
         {
            _loc1_.cleanup();
         }
         this.entries = null;
         this.prefs = null;
      }
      
      public function fromJson(param1:String, param2:Object, param3:ILogger) : SagaNews
      {
         var o:Object = null;
         var dpk:String = null;
         var e:SagaNewsEntry = null;
         var url:String = param1;
         var json:Object = param2;
         var logger:ILogger = param3;
         this.url = url;
         if(json.disabledPlatforms)
         {
            for(dpk in json.disabledPlatforms)
            {
               this.disabledPlatforms[dpk] = true;
            }
         }
         this.baseUrl = url.match(/.*\//)[0];
         if(!json.entries)
         {
            logger.error("No entries for News?");
            return this;
         }
         for each(o in json.entries)
         {
            try
            {
               e = new SagaNewsEntry();
               e.fromJson(o,logger);
               this.entries.push(e);
            }
            catch(e:Error)
            {
               logger.error("Unable to load news entry:\nJSON:\n" + StableJson.stringifyObject(o,"  ") + "\nSTACK:\n" + e.getStackTrace());
            }
         }
         this.checkSeen(this.prefs);
         return this;
      }
      
      public function checkSeen(param1:PrefBag) : void
      {
         var _loc2_:SagaNewsEntry = null;
         for each(_loc2_ in this.entries)
         {
            _loc2_.checkSeen(param1,null);
         }
      }
   }
}
