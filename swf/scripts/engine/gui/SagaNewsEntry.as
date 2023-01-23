package engine.gui
{
   import com.stoicstudio.platform.Platform;
   import engine.core.logging.ILogger;
   import engine.core.pref.PrefBag;
   import engine.core.util.StringUtil;
   
   public class SagaNewsEntry
   {
      
      public static var NEWS_SEEN_PREFIX:String = "news_seen_";
       
      
      public var id:String;
      
      public var text:SagaNewsEntryText;
      
      public var image:SagaNewsEntryImage;
      
      public var hoverUrl:String;
      
      public var hyperlink:String;
      
      public var dialog:SagaNewsEntry;
      
      public var seen:Boolean;
      
      public var platforms:Object;
      
      public var buttons:Array;
      
      public var platformsString:String = "";
      
      public function SagaNewsEntry()
      {
         this.platforms = new Object();
         super();
      }
      
      public function cleanup() : void
      {
      }
      
      public function toString() : String
      {
         if(this.platformsString)
         {
            return this.id + "/" + this.platformsString;
         }
         return this.id;
      }
      
      public function translateUrl(param1:String, param2:String) : String
      {
         if(StringUtil.startsWith(param1,"http://") || StringUtil.startsWith(param1,"file://"))
         {
            return param1;
         }
         return param2 + param1;
      }
      
      public function getText(param1:String) : String
      {
         return this.text.getText(param1);
      }
      
      public function get isValidForPlatform() : Boolean
      {
         if(!this.platforms)
         {
            return true;
         }
         return this.platforms[Platform.id];
      }
      
      public function getPrefId(param1:String) : String
      {
         var _loc2_:String = null;
         if(param1)
         {
            _loc2_ = NEWS_SEEN_PREFIX + param1 + this.id;
         }
         else
         {
            _loc2_ = NEWS_SEEN_PREFIX + this.id;
         }
         return _loc2_;
      }
      
      public function markSeen(param1:PrefBag, param2:String) : void
      {
         var _loc3_:String = this.getPrefId(param2);
         this.seen = true;
         param1.setPref(_loc3_,true);
      }
      
      public function checkSeen(param1:PrefBag, param2:String) : void
      {
         var _loc3_:String = this.getPrefId(param2);
         this.seen = param1.getPref(_loc3_);
         if(this.dialog)
         {
            this.dialog.checkSeen(param1,this.id);
         }
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaNewsEntry
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:* = null;
         this.id = param1.id;
         if(!param1.text)
         {
            param2.error("SagaNewsEntry.fromJson No text for entry " + this.id);
            return this;
         }
         this.platforms = param1.platforms;
         for(_loc5_ in this.platforms)
         {
            if(this.platformsString)
            {
               this.platformsString += ",";
            }
            this.platformsString += _loc5_ + ":" + this.platforms[_loc5_];
            _loc4_++;
         }
         if(!_loc4_)
         {
            this.platforms = null;
         }
         this.text = new SagaNewsEntryText().fromJson(param1.text,param2);
         this.image = new SagaNewsEntryImage().fromJson(param1.image,param2);
         this.hoverUrl = param1.hoverUrl;
         this.hyperlink = param1.hyperlink;
         this.buttons = param1.buttons;
         if(param1.dialog)
         {
            this.dialog = new SagaNewsEntry().fromJson(param1.dialog,param2);
         }
         return this;
      }
   }
}
