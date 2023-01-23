package engine.ability.def
{
   public class StringNumberPair
   {
       
      
      public var id:String;
      
      public var value:Number = 0;
      
      private var valueDefault:int = 0;
      
      private var _delim:String;
      
      public function StringNumberPair()
      {
         super();
      }
      
      public function toString() : String
      {
         return this.save(!!this._delim ? this._delim : "/");
      }
      
      public function clone() : StringNumberPair
      {
         var _loc1_:StringNumberPair = new StringNumberPair();
         _loc1_.id = this.id;
         _loc1_.value = this.value;
         return _loc1_;
      }
      
      public function parseString(param1:String, param2:Number, param3:String) : StringNumberPair
      {
         this._delim = param3;
         this.valueDefault = param2;
         var _loc4_:int = param1.indexOf(param3);
         if(_loc4_ < 0)
         {
            this.id = param1;
            this.value = param2;
         }
         else
         {
            this.id = param1.substring(0,_loc4_);
            this.value = Number(param1.substring(_loc4_ + 1));
         }
         return this;
      }
      
      public function save(param1:String) : String
      {
         if(this.valueDefault == this.value)
         {
            return this.id;
         }
         return this.id + param1 + this.value;
      }
   }
}
