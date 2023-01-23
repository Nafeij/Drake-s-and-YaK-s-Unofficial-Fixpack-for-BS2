package engine.subtitle
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class SubtitleManager extends EventDispatcher
   {
      
      public static const EVENT_CURRENT:String = "SubtitleManager.EVENT_CURRENT";
       
      
      private var _sequence:SubtitleSequence;
      
      public var current:String;
      
      public var logger:ILogger;
      
      private var _locale:Locale;
      
      private var name:String;
      
      public function SubtitleManager(param1:String, param2:ILogger)
      {
         super();
         this.name = param1;
         this._locale = this.locale;
         this.logger = param2;
      }
      
      public function get locale() : Locale
      {
         return this._locale;
      }
      
      public function set locale(param1:Locale) : void
      {
         this._locale = param1;
      }
      
      public function get sequence() : SubtitleSequence
      {
         return this._sequence;
      }
      
      public function stopSequence(param1:SubtitleSequence) : void
      {
         if(param1 == this._sequence)
         {
            this.sequence = null;
         }
      }
      
      public function set sequence(param1:SubtitleSequence) : void
      {
         if(this._sequence)
         {
            this._sequence.stop();
            this._sequence.removeEventListener(SubtitleSequence.EVENT_CURRENT,this.sequenceCurrentHandler);
         }
         this._sequence = param1;
         if(this._sequence)
         {
            this._sequence.addEventListener(SubtitleSequence.EVENT_CURRENT,this.sequenceCurrentHandler);
            this._sequence.startSubtitles();
         }
      }
      
      private function sequenceCurrentHandler(param1:Event) : void
      {
         var _loc2_:String = null;
         this.current = Boolean(this._sequence) && Boolean(this._sequence.current) ? this._sequence.current.text : null;
         if(Boolean(this.locale) && StringUtil.startsWith(this.current,"$"))
         {
            _loc2_ = this.current.substr(1);
            this.current = this.locale.translate(LocaleCategory.SUBTITLE,_loc2_);
            this.logger.info(this.name + " SUBTITLE NOW [$" + _loc2_ + "]=[" + this.current + "]");
         }
         else
         {
            this.logger.info(this.name + " SUBTITLE NOW [" + this.current + "]");
         }
         dispatchEvent(new Event(EVENT_CURRENT));
      }
      
      public function update(param1:int) : void
      {
         if(this._sequence)
         {
            this._sequence.update(param1);
         }
      }
   }
}
