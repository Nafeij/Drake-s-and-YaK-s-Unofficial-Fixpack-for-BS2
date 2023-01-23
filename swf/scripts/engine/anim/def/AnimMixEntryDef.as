package engine.anim.def
{
   public class AnimMixEntryDef
   {
       
      
      public var anim:String;
      
      public var weight:int;
      
      public var lengthMinMs:int;
      
      public var lengthMaxMs:int;
      
      public var repeatsMax:int;
      
      public var repeatsMin:int;
      
      public function AnimMixEntryDef()
      {
         super();
      }
      
      public function get repeats() : int
      {
         if(this.repeatsMax > 0)
         {
            return this.repeatsMin + Math.round((this.repeatsMax - this.repeatsMin) * Math.random());
         }
         return 0;
      }
      
      public function get lengthMs() : int
      {
         if(this.lengthMaxMs > 0)
         {
            return this.lengthMinMs + Math.round((this.lengthMaxMs - this.lengthMinMs) * Math.random());
         }
         return 0;
      }
   }
}
