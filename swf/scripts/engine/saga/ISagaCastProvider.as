package engine.saga
{
   import engine.entity.def.IEntityDef;
   
   public interface ISagaCastProvider
   {
       
      
      function getCastMember(param1:String) : IEntityDef;
   }
}
