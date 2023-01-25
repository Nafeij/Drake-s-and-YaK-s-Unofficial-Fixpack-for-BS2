package engine.core.util
{
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   
   public class CloudSaveSynchronizer extends EventDispatcher
   {
      
      public static var EVENT_PULL_COMPLETE:String = "CloudSaveSynchronizer.EVENT_PULL_COMPLETE";
      
      public static var EVENT_PUSH_COMPLETE:String = "CloudSaveSynchronizer.EVENT_PUSH_COMPLETE";
       
      
      public var folders:Vector.<CloudSave>;
      
      private var pull_waits:int;
      
      private var push_waits:int;
      
      private var logger:ILogger;
      
      public function CloudSaveSynchronizer(param1:ILogger)
      {
         this.folders = new Vector.<CloudSave>();
         super();
         this.logger = param1;
      }
      
      public function registerCloudSave(param1:CloudSave) : void
      {
         if(!param1)
         {
            return;
         }
         this.folders.push(param1);
         param1.addEventListener(CloudSaveEvent.EVENT_PULL_COMPLETE,this.CloudSavePullCompleteHandler);
         param1.addEventListener(CloudSaveEvent.EVENT_PUSH_COMPLETE,this.CloudSavePushCompleteHandler);
      }
      
      public function pullFolders(param1:RegExp) : void
      {
         var rf:CloudSave = null;
         var filter:RegExp = param1;
         if(this.pull_waits)
         {
            this.logger.i("SAVE","Already pulling folders!");
         }
         this.pull_waits = this.folders.length;
         if(!this.pull_waits)
         {
            this.logger.i("SAVE","CloudSaveSynchronizer: No folders registered.");
            setTimeout(function():void
            {
               dispatchEvent(new Event(EVENT_PULL_COMPLETE));
            },1);
            return;
         }
         for each(rf in this.folders)
         {
            if(rf.enabled)
            {
               rf.pullFolder(filter);
            }
            else
            {
               this.logger.i("SAVE","CloudSaveSynchronizer: Skipping pull from disabled folder " + rf.id);
               --this.pull_waits;
            }
         }
         if(this.pull_waits == 0)
         {
            this.logger.i("SAVE","CloudSaveSynchronizer: No folders to pull");
            setTimeout(function():void
            {
               dispatchEvent(new Event(EVENT_PULL_COMPLETE));
            },1);
         }
      }
      
      public function pushFolders() : void
      {
         var _loc1_:CloudSave = null;
         this.push_waits = this.folders.length;
         for each(_loc1_ in this.folders)
         {
            if(_loc1_.enabled)
            {
               _loc1_.pushFolder();
            }
            else
            {
               --this.push_waits;
            }
         }
         if(this.push_waits == 0)
         {
            dispatchEvent(new Event(EVENT_PUSH_COMPLETE));
         }
      }
      
      public function saveGame(param1:String, param2:ByteArray, param3:ByteArray) : void
      {
         var _loc4_:CloudSave = null;
         var _loc5_:int = 0;
         for each(_loc4_ in this.folders)
         {
            if(_loc4_.enabled)
            {
               _loc5_ = !!param3 ? int(param3.length) : 0;
               this.logger.i("SAVE","Saving game " + param1 + " size: " + param2.length + " screenshot: " + _loc5_);
               _loc4_.saveGame(param1,param2,param3);
            }
            else
            {
               this.logger.i("SAVE","Skipping cloud save of " + param1 + " to " + _loc4_.id + " : disabled.");
            }
         }
      }
      
      public function deleteGame(param1:String) : void
      {
         var _loc2_:CloudSave = null;
         for each(_loc2_ in this.folders)
         {
            if(_loc2_.enabled)
            {
               _loc2_.deleteSavedGame(param1);
            }
         }
      }
      
      private function CloudSavePullCompleteHandler(param1:Event) : void
      {
         --this.pull_waits;
         if(this.pull_waits == 0)
         {
            dispatchEvent(new Event(EVENT_PULL_COMPLETE));
         }
      }
      
      private function CloudSavePushCompleteHandler(param1:Event) : void
      {
         --this.push_waits;
         if(this.push_waits == 0)
         {
            dispatchEvent(new Event(EVENT_PUSH_COMPLETE));
         }
      }
   }
}
