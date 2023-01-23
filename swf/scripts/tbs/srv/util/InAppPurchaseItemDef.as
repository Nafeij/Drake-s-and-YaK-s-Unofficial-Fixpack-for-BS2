package tbs.srv.util
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.def.BooleanVars;
   
   public class InAppPurchaseItemDef
   {
       
      
      public var id:String;
      
      public var name:String;
      
      public var category:String;
      
      public var label:String;
      
      public var icon:String = "auto";
      
      public var usd_cents:int;
      
      public var enabled:Boolean;
      
      public var days:int;
      
      public var sale:Boolean;
      
      public var sale_usd_cents:int;
      
      public var limit:int;
      
      public var renown:int;
      
      public var unlocks:Array;
      
      public var units:Array;
      
      public var roster_rows:int;
      
      public function InAppPurchaseItemDef(param1:Object, param2:Locale)
      {
         this.unlocks = [];
         this.units = [];
         super();
         this.id = param1.id;
         this.usd_cents = param1.usd_cents;
         this.enabled = param1.enabled;
         this.category = param1.category;
         this.renown = param1.renown;
         this.sale = BooleanVars.parse(param1.sale);
         this.sale_usd_cents = param1.sale_usd_cents;
         if(param1.unlocks != undefined)
         {
            this.unlocks = param1.unlocks;
         }
         if(param1.units != undefined)
         {
            this.units = param1.units;
         }
         this.limit = param1.limit;
         this.roster_rows = param1.roster_rows;
         if(param1.icon != undefined)
         {
            this.icon = param1.icon;
         }
         this.days = this.days;
         this.name = param2.translate(LocaleCategory.IAP,this.id);
         this.label = param2.translate(LocaleCategory.IAP,this.id + "_label");
      }
   }
}
