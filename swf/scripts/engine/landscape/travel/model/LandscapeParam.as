package engine.landscape.travel.model
{
   import engine.landscape.travel.def.LandscapeParamDef;
   
   public class LandscapeParam
   {
       
      
      public var def:LandscapeParamDef;
      
      public var control:LandscapeParamControl;
      
      public var lastOrdinal:int;
      
      public function LandscapeParam(param1:LandscapeParamDef, param2:LandscapeParamControl)
      {
         super();
         if(!param2)
         {
            throw new ArgumentError("Null control for param " + param1);
         }
         this.def = param1;
         this.control = param2;
         this.lastOrdinal = param2.ordinal - 1;
      }
   }
}
