package engine.entity.def
{
   public interface ITitleDef
   {
       
      
      function getName(param1:String) : String;
      
      function getDescription(param1:String) : String;
      
      function get name_m() : String;
      
      function get name_f() : String;
      
      function get description_m() : String;
      
      function get description_f() : String;
      
      function get id() : String;
      
      function getRank(param1:uint) : ItemDef;
      
      function get numRanks() : int;
      
      function get icon() : String;
      
      function get minRank() : int;
      
      function get iconBuffUrl() : String;
      
      function get unlockVarName() : String;
   }
}
