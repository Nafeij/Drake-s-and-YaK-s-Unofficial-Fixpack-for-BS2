package engine.battle.ability.phantasm.def
{
   public class PhantasmAnimTriggerDef
   {
       
      
      public var animTargetMode:PhantasmTargetMode;
      
      public var animId:String;
      
      public var animEventId:String;
      
      public var guaranteed:Boolean;
      
      public var deltaMs:int;
      
      public function PhantasmAnimTriggerDef()
      {
         super();
      }
      
      public static function getKey(param1:PhantasmTargetMode, param2:String, param3:String) : String
      {
         return param1.name + "_" + param2 + "_" + param3;
      }
      
      public function get key() : String
      {
         return getKey(this.animTargetMode,this.animId,this.animEventId);
      }
      
      public function toString() : String
      {
         return this.key;
      }
   }
}
