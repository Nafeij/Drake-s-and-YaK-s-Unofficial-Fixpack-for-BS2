package tbs.srv.util
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   
   public class IapMktCatPage
   {
       
      
      public var id:String;
      
      public var title:String = "";
      
      public var items:Vector.<String>;
      
      public var menus:Vector.<String>;
      
      public function IapMktCatPage(param1:Object, param2:Locale)
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         this.items = new Vector.<String>();
         this.menus = new Vector.<String>();
         super();
         this.id = param1.id;
         if(this.id)
         {
            this.title = param2.translate(LocaleCategory.IAP,this.id + "_label");
         }
         for each(_loc3_ in param1.items)
         {
            this.items.push(_loc3_);
         }
         for each(_loc4_ in param1.menus)
         {
            this.menus.push(_loc4_);
         }
      }
   }
}
