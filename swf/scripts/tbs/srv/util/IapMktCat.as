package tbs.srv.util
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   
   public class IapMktCat
   {
       
      
      public var id:String;
      
      public var title:String = "";
      
      public var pages:Vector.<IapMktCatPage>;
      
      public function IapMktCat(param1:Object, param2:Locale)
      {
         var _loc3_:Object = null;
         var _loc4_:IapMktCatPage = null;
         this.pages = new Vector.<IapMktCatPage>();
         super();
         this.id = param1.id;
         if(!this.id)
         {
            throw new ArgumentError("id is required to be nonempty");
         }
         if(this.id)
         {
            this.title = param2.translate(LocaleCategory.IAP,this.id);
         }
         for each(_loc3_ in param1.pages)
         {
            _loc4_ = new IapMktCatPage(_loc3_,param2);
            this.pages.push(_loc4_);
         }
      }
      
      public function findPageForItem(param1:String) : IapMktCatPage
      {
         var _loc2_:IapMktCatPage = null;
         for each(_loc2_ in this.pages)
         {
            if(_loc2_.items.indexOf(param1) >= 0)
            {
               return _loc2_;
            }
         }
         return null;
      }
   }
}
