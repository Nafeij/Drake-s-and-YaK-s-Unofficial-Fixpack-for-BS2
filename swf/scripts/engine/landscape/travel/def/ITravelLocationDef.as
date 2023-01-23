package engine.landscape.travel.def
{
   import engine.scene.def.ISceneDef;
   
   public interface ITravelLocationDef
   {
       
      
      function get travelDef() : ITravelDef;
      
      function get sceneDef() : ISceneDef;
      
      function get id() : String;
   }
}
