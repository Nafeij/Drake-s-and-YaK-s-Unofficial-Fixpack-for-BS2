package engine.core.pref
{
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.saga.save.SaveManager;
   import flash.events.Event;
   
   public class SagaPrefBag extends PrefBag
   {
       
      
      private var saveManager:SaveManager;
      
      public function SagaPrefBag(param1:String, param2:int, param3:AppInfo, param4:ILogger, param5:SaveManager, param6:Array)
      {
         this.saveManager = param5;
         super(param1,param2,param3,param4,param6);
         param5.addEventListener(SaveManager.EVENT_INITIALIZED,this.handleSaveManagerInitialized);
      }
      
      private function handleSaveManagerInitialized() : void
      {
         this.loadPrefs();
      }
      
      override protected function loadPrefs() : void
      {
         var _loc1_:Object = null;
         if(Boolean(this.saveManager) && this.saveManager.initialized)
         {
            _loc1_ = this.saveManager.loadPrefs(path);
            if(_loc1_)
            {
               prefs = _loc1_;
               loadDefaults();
            }
            dirty = false;
            loaded = true;
            dispatchEvent(new Event(EVENT_LOADED));
         }
      }
      
      override public function savePrefs() : void
      {
         if(!ALLOW_LOAD)
         {
            return;
         }
         if(!loaded)
         {
            logger.info("SagaPrefBag::savePrefs - can\'t save before being loaded!");
            return;
         }
         this.setPref(VERSION,latestVersion);
         if(dirty)
         {
            logger.info("PrefBag::savePrefs - Saving Preferences to disk");
            dirty = false;
            this.saveManager.savePrefs(path,prefs);
         }
      }
      
      override public function setPref(param1:String, param2:*) : *
      {
         if(!loaded)
         {
            logger.info("SagaPrefBag::setPref - can\'t set pref " + param1 + " before being loaded!");
            return;
         }
         return super.setPref(param1,param2);
      }
      
      override public function getPref(param1:String, param2:* = undefined) : *
      {
         if(!loaded)
         {
            logger.info("SagaPrefBag::getPref - can\'t get pref " + param1 + " before being loaded!");
            return undefined;
         }
         return super.getPref(param1,param2);
      }
   }
}
