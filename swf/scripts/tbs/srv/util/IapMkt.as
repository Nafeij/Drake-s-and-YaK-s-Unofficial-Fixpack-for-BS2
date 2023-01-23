package tbs.srv.util
{
   import engine.core.locale.Locale;
   
   public class IapMkt
   {
       
      
      public var categories:Vector.<IapMktCat>;
      
      public var boosts:Vector.<String>;
      
      public var special:String;
      
      public function IapMkt(param1:Object, param2:Locale)
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:IapMktCat = null;
         this.categories = new Vector.<IapMktCat>();
         this.boosts = new Vector.<String>();
         super();
         for each(_loc3_ in param1.categories)
         {
            _loc5_ = new IapMktCat(_loc3_,param2);
            this.categories.push(_loc5_);
         }
         for each(_loc4_ in param1.boosts)
         {
            this.boosts.push(_loc4_);
         }
         this.special = param1.special;
      }
      
      public function findPageForItem(param1:String) : IapMktCatPage
      {
         var _loc2_:IapMktCat = null;
         var _loc3_:IapMktCatPage = null;
         for each(_loc2_ in this.categories)
         {
            _loc3_ = _loc2_.findPageForItem(param1);
            if(_loc3_)
            {
               return _loc3_;
            }
         }
         return null;
      }
   }
}
