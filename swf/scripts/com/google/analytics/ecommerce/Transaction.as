package com.google.analytics.ecommerce
{
   import com.google.analytics.utils.Variables;
   
   public class Transaction
   {
       
      
      private var _items:Array;
      
      private var _id:String;
      
      private var _affiliation:String;
      
      private var _total:String;
      
      private var _tax:String;
      
      private var _shipping:String;
      
      private var _city:String;
      
      private var _state:String;
      
      private var _country:String;
      
      private var _vars:Variables;
      
      public function Transaction(param1:String, param2:String, param3:String, param4:String, param5:String, param6:String, param7:String, param8:String)
      {
         super();
         this._id = param1;
         this._affiliation = param2;
         this._total = param3;
         this._tax = param4;
         this._shipping = param5;
         this._city = param6;
         this._state = param7;
         this._country = param8;
         this._items = new Array();
      }
      
      public function toGifParams() : Variables
      {
         var _loc1_:Variables = new Variables();
         _loc1_.URIencode = true;
         _loc1_.utmt = "tran";
         _loc1_.utmtid = this.id;
         _loc1_.utmtst = this.affiliation;
         _loc1_.utmtto = this.total;
         _loc1_.utmttx = this.tax;
         _loc1_.utmtsp = this.shipping;
         _loc1_.utmtci = this.city;
         _loc1_.utmtrg = this.state;
         _loc1_.utmtco = this.country;
         _loc1_.post = ["utmtid","utmtst","utmtto","utmttx","utmtsp","utmtci","utmtrg","utmtco"];
         return _loc1_;
      }
      
      public function addItem(param1:String, param2:String, param3:String, param4:String, param5:String) : void
      {
         var _loc6_:Item = null;
         _loc6_ = this.getItem(param1);
         if(_loc6_ == null)
         {
            _loc6_ = new Item(this._id,param1,param2,param3,param4,param5);
            this._items.push(_loc6_);
         }
         else
         {
            _loc6_.name = param2;
            _loc6_.category = param3;
            _loc6_.price = param4;
            _loc6_.quantity = param5;
         }
      }
      
      public function getItem(param1:String) : Item
      {
         var _loc2_:Number = NaN;
         _loc2_ = 0;
         while(_loc2_ < this._items.length)
         {
            if(this._items[_loc2_].sku == param1)
            {
               return this._items[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      public function getItemsLength() : Number
      {
         return this._items.length;
      }
      
      public function getItemFromArray(param1:Number) : Item
      {
         return this._items[param1];
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get affiliation() : String
      {
         return this._affiliation;
      }
      
      public function get total() : String
      {
         return this._total;
      }
      
      public function get tax() : String
      {
         return this._tax;
      }
      
      public function get shipping() : String
      {
         return this._shipping;
      }
      
      public function get city() : String
      {
         return this._city;
      }
      
      public function get state() : String
      {
         return this._state;
      }
      
      public function get country() : String
      {
         return this._country;
      }
      
      public function set id(param1:String) : void
      {
         this._id = param1;
      }
      
      public function set affiliation(param1:String) : void
      {
         this._affiliation = param1;
      }
      
      public function set total(param1:String) : void
      {
         this._total = param1;
      }
      
      public function set tax(param1:String) : void
      {
         this._tax = param1;
      }
      
      public function set shipping(param1:String) : void
      {
         this._shipping = param1;
      }
      
      public function set city(param1:String) : void
      {
         this._city = param1;
      }
      
      public function set state(param1:String) : void
      {
         this._state = param1;
      }
      
      public function set country(param1:String) : void
      {
         this._country = param1;
      }
   }
}
