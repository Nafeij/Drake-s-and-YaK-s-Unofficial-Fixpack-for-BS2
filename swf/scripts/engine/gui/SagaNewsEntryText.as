package engine.gui
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.def.RectangleVars;
   import flash.geom.Rectangle;
   
   public class SagaNewsEntryText
   {
       
      
      public var rect:Rectangle;
      
      public var opaqueBackground;
      
      public var multiline:Boolean;
      
      public var css:Array;
      
      public var glow:Object;
      
      public var langs:Object;
      
      public function SagaNewsEntryText()
      {
         this.rect = new Rectangle(-336,0,672,200);
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaNewsEntryText
      {
         var _loc3_:Object = null;
         this.langs = param1.langs;
         if(this.langs.en == undefined)
         {
            throw new ArgumentError("no english for entry");
         }
         this.opaqueBackground = param1.opaque;
         this.multiline = param1.multiline;
         this.css = param1.css;
         this.glow = param1.glow;
         RectangleVars.parseString(param1.rect,this.rect,param2);
         return this;
      }
      
      public function getText(param1:String) : String
      {
         var _loc2_:* = this.langs[param1];
         if(_loc2_ == undefined)
         {
            return this.langs[Locale.en_id];
         }
         return _loc2_;
      }
   }
}
