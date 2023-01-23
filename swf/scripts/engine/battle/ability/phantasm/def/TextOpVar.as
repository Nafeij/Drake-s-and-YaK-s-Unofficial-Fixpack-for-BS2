package engine.battle.ability.phantasm.def
{
   public class TextOpVar
   {
       
      
      public var path:String;
      
      public var opName:String;
      
      public var opVar:String;
      
      public function TextOpVar(param1:String)
      {
         super();
         this.path = param1;
         var _loc2_:Array = param1.split(".");
         if(_loc2_.length != 2)
         {
            throw new ArgumentError("fuck that: " + param1);
         }
         this.opName = _loc2_[0];
         this.opVar = _loc2_[1];
      }
   }
}
