package engine.entity.def
{
   import engine.stat.def.StatType;
   
   public interface IEntityListStatProvider
   {
       
      
      function getEntityStatValue(param1:String, param2:StatType) : int;
   }
}
