package engine.entity.def
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import flash.utils.Dictionary;
   
   public class TitleListDef implements ITitleListDef
   {
       
      
      protected var _titlesById:Dictionary;
      
      public var url:String;
      
      public var locale:Locale;
      
      public var logger:ILogger;
      
      public function TitleListDef(param1:Locale, param2:ILogger)
      {
         this._titlesById = new Dictionary();
         super();
         this.locale = param1;
         this.logger = param2;
      }
      
      public function addTitleDef(param1:TitleDef) : void
      {
         if(param1 == null)
         {
            throw new ArgumentError("TitleListDef.addTitleDef called with null title:TitleDef");
         }
         if(param1.id == null || param1.id == "")
         {
            throw new ArgumentError("TitleListDef.addTitleDef invalid title id: " + param1.id);
         }
         if(this.getTitleDef(param1.id))
         {
            throw new ArgumentError("TitleListDef.addTitleDef duplicate title def: " + param1.id);
         }
         this._titlesById[param1.id] = param1;
      }
      
      public function getTitleDef(param1:String) : ITitleDef
      {
         var _loc2_:Object = this._titlesById[param1];
         return _loc2_ != null ? _loc2_ as ITitleDef : null;
      }
      
      public function getTitleDict() : Dictionary
      {
         return this._titlesById;
      }
      
      public function changeLocale(param1:Locale) : void
      {
         var _loc2_:TitleDef = null;
         for each(_loc2_ in this._titlesById)
         {
            _loc2_.changeLocale(param1);
         }
      }
   }
}
