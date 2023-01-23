package engine.battle.ability.effect.op.def
{
   import engine.core.util.Enum;
   
   public class EffectDirectionalFlag extends Enum
   {
      
      public static const N:EffectDirectionalFlag = new EffectDirectionalFlag("N",1);
      
      public static const NE:EffectDirectionalFlag = new EffectDirectionalFlag("NE",2);
      
      public static const E:EffectDirectionalFlag = new EffectDirectionalFlag("E",4);
      
      public static const SE:EffectDirectionalFlag = new EffectDirectionalFlag("SE",8);
      
      public static const S:EffectDirectionalFlag = new EffectDirectionalFlag("S",16);
      
      public static const SW:EffectDirectionalFlag = new EffectDirectionalFlag("SW",32);
      
      public static const W:EffectDirectionalFlag = new EffectDirectionalFlag("W",64);
      
      public static const NW:EffectDirectionalFlag = new EffectDirectionalFlag("NW",128);
      
      public static const ALL:EffectDirectionalFlag = new EffectDirectionalFlag("ALL",256);
      
      public static var cardinals:Array = [EffectDirectionalFlag.N,EffectDirectionalFlag.S,EffectDirectionalFlag.E,EffectDirectionalFlag.W];
       
      
      public var bit:int;
      
      private var isCardinals:Array;
      
      public var isE:Boolean;
      
      public var isW:Boolean;
      
      public var isN:Boolean;
      
      public var isS:Boolean;
      
      public function EffectDirectionalFlag(param1:String, param2:int)
      {
         this.isCardinals = [false,false,false,false];
         super(param1,enumCtorKey);
         this.bit = param2;
         this.setupFlags();
      }
      
      private function setupFlags() : void
      {
         if(name.charAt(0) == "S")
         {
            this.isS = true;
            this.isCardinals[1] = true;
         }
         else if(name.charAt(0) == "N")
         {
            this.isN = true;
            this.isCardinals[0] = true;
         }
         var _loc1_:int = name.length - 1;
         if(name.charAt(_loc1_) == "W")
         {
            this.isW = true;
            this.isCardinals[3] = true;
         }
         else if(name.charAt(_loc1_) == "E")
         {
            this.isE = true;
            this.isCardinals[2] = true;
         }
      }
      
      public function findCommonCardinal(param1:EffectDirectionalFlag) : EffectDirectionalFlag
      {
         if(param1 == this)
         {
            return this;
         }
         var _loc2_:int = 0;
         while(_loc2_ < 4)
         {
            if(Boolean(this.isCardinals[_loc2_]) && Boolean(param1.isCardinals[_loc2_]))
            {
               return cardinals[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
   }
}
