package engine.saga
{
   public class SagaIapProduct
   {
       
      
      protected var _dlc:String;
      
      protected var _price:String;
      
      protected var _title:String;
      
      protected var _description:String;
      
      public function SagaIapProduct()
      {
         super();
      }
      
      public function setProperties(param1:String, param2:String, param3:String, param4:String) : void
      {
         this._dlc = param1;
         this._price = param2;
         this._title = param3;
         this._description = param4;
      }
      
      public function get dlc() : String
      {
         return this._dlc;
      }
      
      public function get price() : String
      {
         return this._price;
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      public function get description() : String
      {
         return this._description;
      }
   }
}
