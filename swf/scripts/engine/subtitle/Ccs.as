package engine.subtitle
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   
   public class Ccs
   {
       
      
      public var subtitle:SubtitleManager;
      
      public var supertitle:SubtitleManager;
      
      public function Ccs(param1:ILogger)
      {
         super();
         this.subtitle = new SubtitleManager("  sub",param1);
         this.supertitle = new SubtitleManager("super",param1);
      }
      
      public function reset() : void
      {
         this.subtitle.sequence = null;
         this.supertitle.sequence = null;
      }
      
      public function set locale(param1:Locale) : void
      {
         this.subtitle.locale = param1;
         this.supertitle.locale = param1;
      }
      
      public function update(param1:int) : void
      {
         if(this.subtitle)
         {
            this.subtitle.update(param1);
         }
         if(this.supertitle)
         {
            this.supertitle.update(param1);
         }
      }
   }
}
