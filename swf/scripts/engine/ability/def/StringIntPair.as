package engine.ability.def
{
   public class StringIntPair
   {
       
      
      public var id:String;
      
      public var value:int;
      
      private var valueDefault:int;
      
      public function StringIntPair()
      {
         super();
      }
      
      public function toString() : String
      {
         return this.save();
      }
      
      public function clone() : StringIntPair
      {
         var _loc1_:StringIntPair = new StringIntPair();
         _loc1_.id = this.id;
         _loc1_.value = this.value;
         return _loc1_;
      }
      
      public function parseString(param1:String, param2:int) : StringIntPair
      {
         this.valueDefault = param2;
         var _loc3_:int = param1.indexOf("/");
         if(_loc3_ < 0)
         {
            this.id = param1;
            this.value = param2;
         }
         else
         {
            this.id = param1.substring(0,_loc3_);
            this.value = int(param1.substring(_loc3_ + 1));
         }
         return this;
      }
      
      public function save() : String
      {
         if(this.valueDefault == this.value)
         {
            return this.id;
         }
         return this.id + "/" + this.value;
      }
   }
}
