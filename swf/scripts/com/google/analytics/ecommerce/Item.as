package com.google.analytics.ecommerce
{
   import com.google.analytics.utils.Variables;
   
   public class Item
   {
       
      
      private var _id:String;
      
      private var _sku:String;
      
      private var _name:String;
      
      private var _category:String;
      
      private var _price:String;
      
      private var _quantity:String;
      
      public function Item(param1:String, param2:String, param3:String, param4:String, param5:String, param6:String)
      {
         super();
         this._id = param1;
         this._sku = param2;
         this._name = param3;
         this._category = param4;
         this._price = param5;
         this._quantity = param6;
      }
      
      public function toGifParams() : Variables
      {
         var _loc1_:Variables = new Variables();
         _loc1_.URIencode = true;
         _loc1_.post = ["utmt","utmtid","utmipc","utmipn","utmiva","utmipr","utmiqt"];
         _loc1_.utmt = "item";
         _loc1_.utmtid = this._id;
         _loc1_.utmipc = this._sku;
         _loc1_.utmipn = this._name;
         _loc1_.utmiva = this._category;
         _loc1_.utmipr = this._price;
         _loc1_.utmiqt = this._quantity;
         return _loc1_;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get sku() : String
      {
         return this._sku;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get category() : String
      {
         return this._category;
      }
      
      public function get price() : String
      {
         return this._price;
      }
      
      public function get quantity() : String
      {
         return this._quantity;
      }
      
      public function set id(param1:String) : void
      {
         this._id = param1;
      }
      
      public function set sku(param1:String) : void
      {
         this._sku = param1;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function set category(param1:String) : void
      {
         this._category = param1;
      }
      
      public function set price(param1:String) : void
      {
         this._price = param1;
      }
      
      public function set quantity(param1:String) : void
      {
         this._quantity = param1;
      }
   }
}
